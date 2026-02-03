//
//  JY_SandboxManager + Image.swift
//  JY_GeneralDevelopmentTools
//
//  Created by JYYQLin on 2025/12/24.
//

import Foundation
import UIKit
import Combine
import ImageIO

// 图片格式枚举
public enum ImageFormat: String {
    case png = "png"
    case jpeg = "jpeg"
    case heic = "heic"
}

// 图片保存进度
public enum SaveProgress {
    case preparing
    case writing(Double) // 0.0...1.0
    case completed
}

// MARK: - 图片沙盒管理工具类
public final class JY_ImageSandboxManager {
    // 单例实例
    static let shared = JY_ImageSandboxManager()
    private init() {}
    
    // 沙盒管理工具引用
    private let sandboxManager = JY_SandboxManager.shared
    // 操作队列
    private let operationQueue = DispatchQueue(label: "JY_ImageSandboxManager_com.jy.imageSandbox", attributes: .concurrent)
    
    // MARK: 保存图片到沙盒
    /// 保存图片到沙盒
    /// - Parameters:
    ///   - image: 要保存的图片
    ///   - directory: 保存目录，默认cache
    ///   - fileName: 自定义文件名(不含扩展名)，为nil则自动生成
    ///   - format: 图片格式，默认png
    ///   - quality: 图片质量(仅jpeg和heic有效)，0.0...1.0
    ///   - progress: 进度回调
    ///   - completion: 完成回调，返回保存的文件名和可能的错误
    func saveImage(
        _ image: UIImage,
        to directory: SandboxDirectory = .cache,
        fileName: String? = nil,
        format: ImageFormat = .png,
        quality: CGFloat = 0.8,
        progress: @escaping (SaveProgress) -> Void,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        operationQueue.async {
            // 通知开始准备
            DispatchQueue.main.async {
                progress(.preparing)
            }
            
            // 1. 生成或使用指定文件名
            let finalFileName = self.generateFileName(
                customName: fileName,
                directory: directory,
                format: format
            )
            
            // 2. 获取完整路径
            guard let fullPath = self.sandboxManager.fullPath(for: finalFileName, in: directory) else {
                DispatchQueue.main.async {
                    completion(.failure(SandboxError.invalidPath))
                }
                return
            }
            
            // 3. 转换图片为数据
            guard let imageData = self.imageData(from: image, format: format, quality: quality) else {
                DispatchQueue.main.async {
                    completion(.failure(SandboxError.fileOperationFailed("无法将图片转换为数据")))
                }
                return
            }
            
            // 4. 写入文件并报告进度
            do {
                // 分块写入以支持进度报告
                let chunkSize = 1024 * 1024 // 1MB块
                let totalChunks = (imageData.count + chunkSize - 1) / chunkSize
                var writtenBytes = 0
                
                try FileManager.default.createDirectory(
                    atPath: (fullPath as NSString).deletingLastPathComponent,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                
                let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: fullPath))
                
                while writtenBytes < imageData.count {
                    let endIndex = min(writtenBytes + chunkSize, imageData.count)
                    let chunk = imageData.subdata(in: writtenBytes..<endIndex)
                    
                    fileHandle.write(chunk)
                    writtenBytes = endIndex
                    
                    // 计算并报告进度
                    let progressValue = Double(writtenBytes) / Double(imageData.count)
                    DispatchQueue.main.async {
                        progress(.writing(progressValue))
                    }
                }
                
                fileHandle.closeFile()
                
                DispatchQueue.main.async {
                    progress(.completed)
                    completion(.success(finalFileName))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(SandboxError.fileOperationFailed(error.localizedDescription)))
                }
            }
        }
    }
    
    // MARK: 从沙盒读取图片
    /// 从沙盒读取图片
    /// - Parameters:
    ///   - fileName: 图片文件名
    ///   - directory: 保存目录，为nil则尝试从文件名解析
    ///   - completion: 完成回调，返回图片和可能的错误
    func getImage(
        fileName: String,
        from directory: SandboxDirectory? = nil,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        operationQueue.async {
            // 1. 解析目录
            let targetDirectory: SandboxDirectory
            if let directory = directory {
                targetDirectory = directory
            } else if let parsedDir = self.parseDirectory(from: fileName) {
                targetDirectory = parsedDir
            } else {
                DispatchQueue.main.async {
                    completion(.failure(SandboxError.invalidPath))
                }
                return
            }
            
            // 2. 获取完整路径
            guard let fullPath = self.sandboxManager.fullPath(for: fileName, in: targetDirectory) else {
                DispatchQueue.main.async {
                    completion(.failure(SandboxError.invalidPath))
                }
                return
            }
            
            // 3. 检查文件是否存在
            guard FileManager.default.fileExists(atPath: fullPath) else {
                DispatchQueue.main.async {
                    completion(.failure(SandboxError.fileDoesNotExist))
                }
                return
            }
            
            // 4. 读取图片数据
            guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: fullPath)),
                  let image = UIImage(data: imageData) else {
                DispatchQueue.main.async {
                    completion(.failure(SandboxError.fileOperationFailed("无法读取图片数据")))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(image))
            }
        }
    }
    
    // MARK: 删除沙盒中的图片
    /// 删除沙盒中的图片
    /// - Parameters:
    ///   - fileName: 图片文件名
    ///   - directory: 保存目录，为nil则尝试从文件名解析
    ///   - completion: 完成回调
    func deleteImage(
        fileName: String,
        from directory: SandboxDirectory? = nil,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        operationQueue.async {
            // 1. 解析目录
            let targetDirectory: SandboxDirectory
            if let directory = directory {
                targetDirectory = directory
            } else if let parsedDir = self.parseDirectory(from: fileName) {
                targetDirectory = parsedDir
            } else {
                DispatchQueue.main.async {
                    completion(.failure(SandboxError.invalidPath))
                }
                return
            }
            
            // 2. 获取完整路径
            guard let fullPath = self.sandboxManager.fullPath(for: fileName, in: targetDirectory) else {
                DispatchQueue.main.async {
                    completion(.failure(SandboxError.invalidPath))
                }
                return
            }
            
            // 3. 调用沙盒管理器删除文件
            self.sandboxManager.deleteFile(at: fullPath) { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    // MARK: 辅助方法 - 生成文件名
    private func generateFileName(
        customName: String?,
        directory: SandboxDirectory,
        format: ImageFormat
    ) -> String {
        if let customName = customName {
            return "\(customName).\(format.rawValue)"
        }
        
        // 自动生成格式: 时间戳_目录_随机字符串.格式
        let timestamp = Date().timeIntervalSince1970
        let directoryFlag = directory.rawValue
        let randomString = String(UUID().uuidString.prefix(8)) // 修复错误3：转换为String
        return String(format: "%.0f_%@_%@.%@", timestamp, directoryFlag, randomString, format.rawValue)
    }
    
    // MARK: 辅助方法 - 从文件名解析目录
    private func parseDirectory(from fileName: String) -> SandboxDirectory? {
        // 解析格式: 时间戳_目录_随机字符串.格式
        let components = fileName.components(separatedBy: "_")
        guard components.count >= 2 else { return nil }
        
        let directoryStr = components[1]
        return SandboxDirectory(rawValue: directoryStr)
    }
    
    // MARK: 辅助方法 - 转换图片为数据
    private func imageData(
        from image: UIImage,
        format: ImageFormat,
        quality: CGFloat
    ) -> Data? {
        switch format {
        case .png:
            return image.pngData()
        case .jpeg:
            return image.jpegData(compressionQuality: quality)
        case .heic:
            guard let cgImage = image.cgImage else { return nil }
            let ciImage = CIImage(cgImage: cgImage)
            let context = CIContext(options: [.useSoftwareRenderer: false])
            
            // 修复：将 CFString 显式转换为 String
            let qualityKey = kCGImageDestinationLossyCompressionQuality as String
            let options: [CIImageRepresentationOption: Any] = [
                .init(rawValue: qualityKey): quality
            ]
            
            guard let heicData = context.heifRepresentation(
                of: ciImage,
                format: .RGBA8,
                colorSpace: CGColorSpaceCreateDeviceRGB(),
                options: options
            ) else { return nil }
            
            return heicData
        }
    }
}

// MARK: - Combine版本方法
public extension JY_ImageSandboxManager {
    /// Combine版本：保存图片到沙盒
    func saveImage(
        _ image: UIImage,
        to directory: SandboxDirectory = .cache,
        fileName: String? = nil,
        format: ImageFormat = .png,
        quality: CGFloat = 0.8
    ) -> AnyPublisher<(progress: SaveProgress, fileName: String?), Error> {
        let subject = PassthroughSubject<(progress: SaveProgress, fileName: String?), Error>() // 修复错误2：添加元组标签
        
        saveImage(image, to: directory, fileName: fileName, format: format, quality: quality) { progress in
            subject.send((progress: progress, fileName: nil)) // 修复错误2：添加元组标签
        } completion: { result in
            switch result {
            case .success(let fileName):
                subject.send((progress: .completed, fileName: fileName)) // 修复错误2：添加元组标签
                subject.send(completion: .finished)
            case .failure(let error):
                subject.send(completion: .failure(error))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    /// Combine版本：从沙盒读取图片
    func getImage(
        fileName: String,
        from directory: SandboxDirectory? = nil
    ) -> AnyPublisher<UIImage, Error> {
        Future<UIImage, Error> { [weak self] promise in
            guard let self = self else { return }
            self.getImage(fileName: fileName, from: directory) { promise($0) }
        }
        .eraseToAnyPublisher()
    }
    
    /// Combine版本：删除沙盒中的图片
    func deleteImage(
        fileName: String,
        from directory: SandboxDirectory? = nil
    ) -> AnyPublisher<Bool, Error> {
        Future<Bool, Error> { [weak self] promise in
            guard let self = self else { return }
            self.deleteImage(fileName: fileName, from: directory) { promise($0) }
        }
        .eraseToAnyPublisher()
    }
}
