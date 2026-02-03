//
//  JY_NetworkManager.swift
//  JY_GeneralDevelopmentTools
//
//  Created by JYYQLin on 2025/11/6.
//

import Foundation
import Combine

// MARK: - 沙盒目录枚举
public enum SandboxDirectory: String, CaseIterable {
    case documents  // 应用文档目录
    case library    // 应用库目录
    case cache      // 缓存目录
    case temp       // 临时文件目录
}

// MARK: - 自定义沙盒操作错误
public enum SandboxError: LocalizedError {
    case invalidPath              // 无效路径
    case fileDoesNotExist         // 文件/文件夹不存在
    case notAFile                 // 路径不是文件
    case notAFolder               // 路径不是文件夹
    case fileOperationFailed(String) // 文件操作失败
    case permissionDenied(String) // 权限不足
    
    var errorDescription: String? {
        switch self {
        case .invalidPath:
            return "无效的沙盒路径"
        case .fileDoesNotExist:
            return "目标文件/文件夹不存在"
        case .notAFile:
            return "指定路径指向的不是文件"
        case .notAFolder:
            return "指定路径指向的不是文件夹"
        case .fileOperationFailed(let message):
            return "文件操作失败：\(message)"
        case .permissionDenied(let path):
            return "权限不足，无法操作：\(path)"
        }
    }
}

// MARK: - 沙盒操作工具类（单例模式）
public final class JY_SandboxManager {
    // 单例实例
    static let shared = JY_SandboxManager()
    private init() {} // 私有化初始化，防止外部创建
    
    // 文件管理器
    private let fileManager = FileManager.default
    // 全局并发队列（IO操作使用utility优先级）
    private let fileQueue = DispatchQueue.global(qos: .utility)
    
    // MARK: 1. 获取沙盒基础路径
    func path(for directory: SandboxDirectory) -> String? {
        switch directory {
        case .documents:
            return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.path
        case .library:
            return fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first?.path
        case .cache:
            return fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?.path
        case .temp:
            return NSTemporaryDirectory()
        }
    }
    
    // MARK: 2. 拼接文件名与沙盒路径
    func fullPath(for fileName: String, in directory: SandboxDirectory) -> String? {
        guard let basePath = path(for: directory) else { return nil }
        return (basePath as NSString).appendingPathComponent(fileName)
    }
    
    // MARK: 3. 计算单个文件大小（字节）
    func fileSize(at path: String) -> AnyPublisher<Int64, Error> {
        Future<Int64, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(SandboxError.fileOperationFailed("沙盒管理器已释放")))
                return
            }
            
            self.fileQueue.async {
                guard self.fileManager.fileExists(atPath: path) else {
                    promise(.failure(SandboxError.fileDoesNotExist))
                    return
                }
                
                var isDirectory: ObjCBool = false
                guard self.fileManager.fileExists(atPath: path, isDirectory: &isDirectory), !isDirectory.boolValue else {
                    promise(.failure(SandboxError.notAFile))
                    return
                }
                
                do {
                    let attrs = try self.fileManager.attributesOfItem(atPath: path)
                    guard let size = attrs[.size] as? Int64 else {
                        promise(.failure(SandboxError.fileOperationFailed("无法解析文件大小")))
                        return
                    }
                    promise(.success(size))
                } catch {
                    promise(.failure(SandboxError.fileOperationFailed(error.localizedDescription)))
                }
            }
        }
        .subscribe(on: fileQueue)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    // MARK: 4. 计算文件夹总大小（包含子文件夹）
    func folderSize(at path: String) -> AnyPublisher<Int64, Error> {
        Future<Int64, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(SandboxError.fileOperationFailed("沙盒管理器已释放")))
                return
            }
            
            self.fileQueue.async {
                guard self.fileManager.fileExists(atPath: path) else {
                    promise(.failure(SandboxError.fileDoesNotExist))
                    return
                }
                
                var isDirectory: ObjCBool = false
                guard self.fileManager.fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue else {
                    promise(.failure(SandboxError.notAFolder))
                    return
                }
                
                do {
                    let totalSize = try self.calculateFolderSizeRecursively(at: path)
                    promise(.success(totalSize))
                } catch {
                    promise(.failure(SandboxError.fileOperationFailed(error.localizedDescription)))
                }
            }
        }
        .subscribe(on: fileQueue)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    // 私有：递归计算文件夹大小
    private func calculateFolderSizeRecursively(at path: String) throws -> Int64 {
        var totalSize: Int64 = 0
        let contents = try fileManager.contentsOfDirectory(atPath: path)
        
        for item in contents {
            let itemPath = (path as NSString).appendingPathComponent(item)
            var isDirectory: ObjCBool = false
            
            guard fileManager.fileExists(atPath: itemPath, isDirectory: &isDirectory) else { continue }
            
            if isDirectory.boolValue {
                totalSize += try calculateFolderSizeRecursively(at: itemPath)
            } else {
                let attrs = try fileManager.attributesOfItem(atPath: itemPath)
                totalSize += attrs[.size] as? Int64 ?? 0
            }
        }
        return totalSize
    }
    
    // MARK: 5. 快速获取指定沙盒目录大小
    func documentsSize() -> AnyPublisher<Int64, Error> {
        guard let path = path(for: .documents) else {
            return Fail(error: SandboxError.invalidPath).eraseToAnyPublisher()
        }
        return folderSize(at: path)
    }
    
    func librarySize() -> AnyPublisher<Int64, Error> {
        guard let path = path(for: .library) else {
            return Fail(error: SandboxError.invalidPath).eraseToAnyPublisher()
        }
        return folderSize(at: path)
    }
    
    func cacheSize() -> AnyPublisher<Int64, Error> {
        guard let path = path(for: .cache) else {
            return Fail(error: SandboxError.invalidPath).eraseToAnyPublisher()
        }
        return folderSize(at: path)
    }
    
    func tempSize() -> AnyPublisher<Int64, Error> {
        guard let path = path(for: .temp) else {
            return Fail(error: SandboxError.invalidPath).eraseToAnyPublisher()
        }
        return folderSize(at: path)
    }
    
    // MARK: 6. 删除单个文件（修复权限问题）
    func deleteFile(at path: String) -> AnyPublisher<Bool, Error> {
        Future<Bool, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(SandboxError.fileOperationFailed("沙盒管理器已释放")))
                return
            }
            
            self.fileQueue.async {
                var isDirectory: ObjCBool = false
                guard self.fileManager.fileExists(atPath: path, isDirectory: &isDirectory), !isDirectory.boolValue else {
                    promise(.failure(SandboxError.notAFile))
                    return
                }
                
                // 核心修复1：先尝试修改文件权限为可写
                do {
                    try self.fileManager.setAttributes([.posixPermissions: 0o644], ofItemAtPath: path)
                } catch {
                    promise(.failure(SandboxError.permissionDenied(path)))
                    return
                }
                
                // 核心修复2：添加重试机制（处理文件占用）
                let maxRetryCount = 3
                var retryCount = 0
                var deleteSuccess = false
                
                while retryCount < maxRetryCount && !deleteSuccess {
                    do {
                        try self.fileManager.removeItem(atPath: path)
                        deleteSuccess = true
                    } catch {
                        retryCount += 1
                        if retryCount == maxRetryCount {
                            promise(.failure(SandboxError.fileOperationFailed("删除失败（重试\(maxRetryCount)次）：\(error.localizedDescription)")))
                            return
                        }
                        // 重试前短暂等待（避免频繁重试）
                        Thread.sleep(forTimeInterval: 0.1)
                    }
                }
                
                promise(.success(deleteSuccess))
            }
        }
        .subscribe(on: fileQueue)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    // MARK: 7. 删除文件夹（修复权限+递归删除）
    func deleteFolder(at path: String) -> AnyPublisher<Bool, Error> {
        Future<Bool, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(SandboxError.fileOperationFailed("沙盒管理器已释放")))
                return
            }
            
            self.fileQueue.async {
                var isDirectory: ObjCBool = false
                guard self.fileManager.fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue else {
                    promise(.failure(SandboxError.notAFolder))
                    return
                }
                
                // 核心修复：递归删除文件夹内所有内容（先删子项，再删文件夹）
                do {
                    try self.recursivelyDeleteFolder(at: path)
                    promise(.success(true))
                } catch {
                    if error.localizedDescription.contains("permission") {
                        promise(.failure(SandboxError.permissionDenied(path)))
                    } else {
                        promise(.failure(SandboxError.fileOperationFailed(error.localizedDescription)))
                    }
                }
            }
        }
        .subscribe(on: fileQueue)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    // MARK: 8. 快速删除沙盒目录下所有内容（保留目录本身）
    func deleteAllInDirectory(_ directory: SandboxDirectory) -> AnyPublisher<Bool, Error> {
        Future<Bool, Error> { [weak self] promise in
            guard let self = self, let basePath = self.path(for: directory) else {
                promise(.failure(SandboxError.invalidPath))
                return
            }
            
            self.fileQueue.async {
                do {
                    let contents = try self.fileManager.contentsOfDirectory(atPath: basePath)
                    // 遍历删除所有子项（使用修复后的递归删除逻辑）
                    for item in contents {
                        let itemPath = (basePath as NSString).appendingPathComponent(item)
                        try self.recursivelyDeleteFolder(at: itemPath)
                    }
                    promise(.success(true))
                } catch {
                    if error.localizedDescription.contains("permission") {
                        promise(.failure(SandboxError.permissionDenied(basePath)))
                    } else {
                        promise(.failure(SandboxError.fileOperationFailed(error.localizedDescription)))
                    }
                }
            }
        }
        .subscribe(on: fileQueue)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    // MARK: 私有核心方法：递归删除文件夹（处理权限+子项）
    private func recursivelyDeleteFolder(at path: String) throws {
        // 1. 先修改当前路径权限为可写可删
        try fileManager.setAttributes([.posixPermissions: 0o755], ofItemAtPath: path)
        
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else { return }
        
        if isDirectory.boolValue {
            // 2. 递归删除子文件/子文件夹
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            for item in contents {
                let itemPath = (path as NSString).appendingPathComponent(item)
                try recursivelyDeleteFolder(at: itemPath)
            }
            // 3. 删除空文件夹
            try fileManager.removeItem(atPath: path)
        } else {
            // 是文件则直接删除（先改权限）
            try fileManager.setAttributes([.posixPermissions: 0o644], ofItemAtPath: path)
            try fileManager.removeItem(atPath: path)
        }
    }
    
    // MARK: 闭包版本（兼容不熟悉Combine的场景）
    func fileSize(at path: String, completion: @escaping (Result<Int64, Error>) -> Void) {
        _ = fileSize(at: path).sink(
            receiveCompletion: { if case .failure(let e) = $0 { completion(.failure(e)) } },
            receiveValue: { completion(.success($0)) }
        )
    }
    
    func folderSize(at path: String, completion: @escaping (Result<Int64, Error>) -> Void) {
        _ = folderSize(at: path).sink(
            receiveCompletion: { if case .failure(let e) = $0 { completion(.failure(e)) } },
            receiveValue: { completion(.success($0)) }
        )
    }
    
    func deleteFile(at path: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        _ = deleteFile(at: path).sink(
            receiveCompletion: { if case .failure(let e) = $0 { completion(.failure(e)) } },
            receiveValue: { completion(.success($0)) }
        )
    }
    
    func deleteAllInDirectory(_ directory: SandboxDirectory, completion: @escaping (Result<Bool, Error>) -> Void) {
        _ = deleteAllInDirectory(directory).sink(
            receiveCompletion: { if case .failure(let e) = $0 { completion(.failure(e)) } },
            receiveValue: { completion(.success($0)) }
        )
    }
}

// MARK: - 扩展：字节大小格式化（方便阅读）
public extension Int64 {
    func formattedFileSize() -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: self)
    }
}


// MARK: - 扩展：字节大小格式化（强制英文输出，完全手动实现，兼容 iOS13+ / iOS16）
public extension Int64 {
    func yq_formattedFileSize() -> String {
        // 单位数组：仅保留 MB、GB、TB（最小单位为 MB）
        let englishUnits = ["MB", "GB", "TB"]
        let base: Double = 1024.0
        var currentByteCount = Double(self)
        
        // 先强制将字节数换算为 MB（跳过 Bytes → KB → MB 的步骤）
        currentByteCount /= (base * base) // 字节 → MB：除以 1024*1024
        var unitIndex = 0 // 初始索引对应 MB（数组第一个元素即为 MB）
        
        // 自动升级单位（MB → GB → TB，无需降级到 KB/Bytes）
        while currentByteCount >= base && unitIndex < englishUnits.count - 1 {
            currentByteCount /= base
            unitIndex += 1
        }
        
        // 格式化数值（保留1位小数，优化显示效果）
        let formattedNumber: String
        formattedNumber = String(format: "%.1f", currentByteCount)
        // 移除末尾的 .0（如 1.0 MB → 1 MB，更简洁）
        let cleanNumber = formattedNumber.replacingOccurrences(of: ".0", with: "")
        
        // 拼接 MB/GB/TB 单位，无 Bytes/KB 输出
        return "\(cleanNumber) \(englishUnits[unitIndex])"
    }
}
