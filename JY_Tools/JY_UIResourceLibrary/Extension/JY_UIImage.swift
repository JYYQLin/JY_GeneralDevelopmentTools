//
//  JY_UIImage.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/24.
//

import UIKit
import Accelerate
import MobileCoreServices

//  MARK: 生成虚线
public extension UIImage {
    /// 虚线方向枚举（简化命名）
    enum DashDirection {
        case horizontal  // 水平虚线
        case vertical    // 垂直虚线
    }
    
    /// 生成自定义虚线图片（通用版：支持矩形虚线框）
    /// - Parameters:
    ///   - size: 图片整体尺寸
    ///   - color: 虚线颜色
    ///   - lineWidth: 虚线的线宽
    ///   - dashPattern: 虚线样式数组（例：[8,4] 表示 8pt 实线 + 4pt 空白，循环），默认[8,4]
    ///   - cornerRadius: 图片圆角（默认0）
    ///   - lineCap: 线条端点样式（默认平角，可选圆角/方角）
    ///   - lineJoin: 线条拐角样式（默认斜角，可选圆角/斜角）
    ///   - phase: 虚线起始偏移量（默认0）
    /// - Returns: 生成的虚线图片（失败返回nil）
    class func dashedRectImage(
        with size: CGSize,
        color: UIColor,
        lineWidth: CGFloat,
        dashPattern: [CGFloat] = [8, 4],
        cornerRadius: CGFloat = 0,
        lineCap: CGLineCap = .butt,
        lineJoin: CGLineJoin = .miter,
        phase: CGFloat = 0
    ) -> UIImage? {
        // 校验参数合法性
        guard size.width > 0, size.height > 0, lineWidth > 0 else {
            print("⚠️ 虚线图片参数不合法：尺寸/线宽不能为0")
            return nil
        }
        guard !dashPattern.isEmpty, dashPattern.allSatisfy({ $0 >= 0 }) else {
            print("⚠️ 虚线样式数组不合法：不能为空且不能包含负数")
            return nil
        }
        
        // 创建 Retina 适配的图片渲染器
        let rendererConfig = UIGraphicsImageRendererFormat()
        rendererConfig.scale = UIScreen.main.scale  // 自动适配屏幕缩放
        let renderer = UIGraphicsImageRenderer(size: size, format: rendererConfig)
        
        return renderer.image { context in
            // 路径向内偏移lineWidth/2：避免线宽超出图片边界被裁切
            let insetRect = CGRect(
                x: lineWidth / 2,
                y: lineWidth / 2,
                width: size.width - lineWidth,
                height: size.height - lineWidth
            )
            // 安全圆角：避免圆角值超过矩形最短边的一半导致绘制失败
            let safeCornerRadius = min(cornerRadius, min(insetRect.width, insetRect.height) / 2)
            
            // 1. 创建虚线路径（圆角矩形）
            let path = UIBezierPath(roundedRect: insetRect, cornerRadius: safeCornerRadius)
            
            // 2. 设置虚线样式
            path.lineWidth = lineWidth
            path.lineCapStyle = lineCap
            path.lineJoinStyle = lineJoin
            path.setLineDash(dashPattern, count: dashPattern.count, phase: phase)
            
            // 3. 绘制虚线
            color.setStroke()
            path.stroke()
        }
    }
    
    /// 快速生成单条虚线（简化版：水平/垂直）
    /// - Parameters:
    ///   - length: 虚线总长度
    ///   - direction: 虚线方向
    ///   - color: 虚线颜色
    ///   - lineWidth: 虚线线宽
    ///   - dashPattern: 虚线样式数组，默认[8,4]
    ///   - lineCap: 线条端点样式（默认圆角，更美观）
    /// - Returns: 生成的单条虚线图片
    class func singleDashedLineImage(
        with length: CGFloat,
        direction: DashDirection,
        color: UIColor,
        lineWidth: CGFloat,
        dashPattern: [CGFloat] = [8, 4],
        lineCap: CGLineCap = .round
    ) -> UIImage? {
        // 校验参数
        guard length > 0, lineWidth > 0 else {
            print("⚠️ 单条虚线参数不合法：长度/线宽不能为0")
            return nil
        }
        guard !dashPattern.isEmpty, dashPattern.allSatisfy({ $0 >= 0 }) else {
            print("⚠️ 虚线样式数组不合法：不能为空且不能包含负数")
            return nil
        }
        
        // 计算图片尺寸
        let size: CGSize = {
            switch direction {
            case .horizontal:
                return CGSize(width: length, height: lineWidth)
            case .vertical:
                return CGSize(width: lineWidth, height: length)
            }
        }()
        
        // 单独绘制单条线路径
        let rendererConfig = UIGraphicsImageRendererFormat()
        rendererConfig.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: rendererConfig)
        
        return renderer.image { context in
            let path = UIBezierPath()
            // 起点/终点：居中绘制，避免线宽裁切
            let startPoint: CGPoint = {
                switch direction {
                case .horizontal:
                    return CGPoint(x: 0, y: size.height / 2)
                case .vertical:
                    return CGPoint(x: size.width / 2, y: 0)
                }
            }()
            let endPoint: CGPoint = {
                switch direction {
                case .horizontal:
                    return CGPoint(x: length, y: size.height / 2)
                case .vertical:
                    return CGPoint(x: size.width / 2, y: length)
                }
            }()
            
            // 创建单条线路径
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            
            // 设置样式
            path.lineWidth = lineWidth
            path.lineCapStyle = lineCap
            path.setLineDash(dashPattern, count: dashPattern.count, phase: 0)
            
            // 绘制
            color.setStroke()
            path.stroke()
        }
    }
}


//  MARK: 生成圆角图片
import UIKit

public extension UIImage {
    /// 生成纯色圆角图片
    /// - Parameters:
    ///   - color: 图片填充颜色（UIColor，支持透明色）
    ///   - imageSize: 图片尺寸（CGSize，宽高不可为0）
    ///   - cornerRadius: 圆角大小（CGFloat，默认0，无圆角）
    ///   - roundingCorners: 圆角位置（默认.allCorners，可指定单个/多个角）
    /// - Returns: 纯色圆角图片（UIImage，失败返回空图片）
    static func yq_solidColorImage(
        color: UIColor,
        imageSize: CGSize,
        cornerRadius: CGFloat = 0,
        roundingCorners: UIRectCorner = .allCorners
    ) -> UIImage {
        // 前置校验：避免无效参数导致崩溃
        guard imageSize.width > 0, imageSize.height > 0 else {
            return UIImage()
        }
        
        // 1. 创建高清位图上下文（适配Retina屏，支持透明背景）
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        
        // 2. 创建图片矩形区域
        let imageRect = CGRect(origin: .zero, size: imageSize)
        
        // 3. 处理圆角并绘制纯色背景
        if cornerRadius > 0 {
            // 创建指定圆角位置和大小的路径
            let cornerPath = UIBezierPath(
                roundedRect: imageRect,
                byRoundingCorners: roundingCorners,
                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
            )
            // 裁剪上下文（仅保留圆角路径内的绘制区域）
            cornerPath.addClip()
        }
        
        // 4. 填充纯色背景
        color.setFill()
        context.fill(imageRect)
        
        // 5. 从上下文中提取图片
        let solidImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        
        // 6. 释放上下文
        UIGraphicsEndImageContext()
        
        return solidImage
    }
}

// MARK: - 渐变方向枚举（对应你需要的四种方向，清晰无歧义）
public enum GradientDirection {
    case topToBottom  // 从上到下
    case leftToRight  // 从左到右
    case leftTopToRightBottom // 从左上到右下
    case rightTopToLeftBottom // 从右上到左下
}

// MARK: - 图片生成工具（可直接放在UIImage扩展中，方便调用）
public extension UIImage {
    /// 生成渐变圆角图片
    /// - Parameters:
    ///   - colors: 渐变颜色数组（不可为空，若为空返回空图片）
    ///   - direction: 渐变方向（四种可选）
    ///   - imageSize: 图片大小（CGSize，宽高不可为0）
    ///   - cornerRadius: 圆角大小（CGFloat，默认0，无圆角）
    ///   - roundingCorners: 圆角位置（默认.allCorners，可指定单个/多个角）
    /// - Returns: 渐变圆角图片（UIImage，失败返回空图片）
    static func yq_gradientImage(colorArray colors: [UIColor],
                                 gradientType direction: GradientDirection,
                                 imageSize: CGSize,
                                 cornerRadius: CGFloat = 0,
                                 roundingCorners: UIRectCorner = .allCorners
    ) -> UIImage {
        // 前置校验：避免无效参数导致崩溃
        guard !colors.isEmpty, imageSize.width > 0, imageSize.height > 0 else {
            return UIImage()
        }
        
        // 1. 创建基于位图的高清上下文（避免图片模糊）
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        
        // 2. 创建渐变层并配置属性
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: imageSize)
        // 转换颜色数组为CGColor（渐变层要求的颜色格式）
        gradientLayer.colors = colors.map { $0.cgColor }
        // 根据渐变方向设置起始点和结束点
        let (startPoint, endPoint) = gradientPoints(for: direction)
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        // 3. 配置圆角蒙版（支持指定圆角位置和大小）
        if cornerRadius > 0 {
            // 创建对应圆角位置的路径
            let cornerPath = UIBezierPath(
                roundedRect: gradientLayer.bounds,
                byRoundingCorners: roundingCorners,
                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
            )
            // 创建形状图层作为蒙版
            let maskLayer = CAShapeLayer()
            maskLayer.path = cornerPath.cgPath
            gradientLayer.mask = maskLayer // 为渐变层添加圆角蒙版
        }
        
        // 4. 将渐变层渲染到上下文
        gradientLayer.render(in: context)
        
        // 5. 从上下文中提取图片
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        
        // 6. 释放上下文
        UIGraphicsEndImageContext()
        
        return gradientImage
    }
    
    // MARK: - 私有辅助方法：根据渐变方向返回对应的起始点和结束点
    private static func gradientPoints(for direction: GradientDirection) -> (start: CGPoint, end: CGPoint) {
        switch direction {
        case .topToBottom:
            // 从上到下：起始点(0,0)，结束点(0,1)
            return (CGPoint(x: 0.5, y: 0), CGPoint(x: 0.5, y: 1))
        case .leftToRight:
            // 从左到右：起始点(0,0.5)，结束点(1,0.5)
            return (CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5))
        case .leftTopToRightBottom:
            // 从左上到右下：起始点(0,0)，结束点(1,1)
            return (CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1))
        case .rightTopToLeftBottom:
            // 从右上到左下：起始点(1,0)，结束点(0,1)
            return (CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1))
        }
    }
}


//  MARK: 压缩图片大小
import UIKit

public extension UIImage {
    /// 将图片压缩到指定KB大小（优先JPEG压缩，PNG无损则转JPEG）
    /// - Parameters:
    ///   - targetSizeInKB: 目标大小（单位：KB，需>0）
    ///   - compressionFormat: 压缩格式（默认JPEG，PNG为无损压缩，仅当图片本身小于目标大小时返回）
    /// - Returns: 压缩后的图片Data（失败返回nil）
    func compressToTargetSize(
        targetSizeInKB: CGFloat,
        compressionFormat: ImageCompressionFormat = .jpeg
    ) -> Data? {
        // 1. 参数校验：目标大小需>0
        guard targetSizeInKB > 0 else {
            print("⚠️ 图片压缩失败：目标大小必须大于0KB")
            return nil
        }
        let targetSizeInBytes = targetSizeInKB * 1024 // 转换为字节（1KB=1024字节）
        
        // 2. 先尝试直接转Data，判断是否已小于目标大小
        guard let initialData = self.convertToData(format: compressionFormat, quality: 1.0) else {
            print("⚠️ 图片压缩失败：无法将图片转为Data")
            return nil
        }
        let initialSizeInBytes = CGFloat(initialData.count)
        
        // 3. 若当前大小已小于目标，直接返回
        if initialSizeInBytes <= targetSizeInBytes {
            print("✅ 图片本身已小于目标大小（当前：\(String(format: "%.2f", initialSizeInBytes/1024))KB，目标：\(targetSizeInKB)KB）")
            return initialData
        }
        
        // 4. PNG格式为无损压缩，无法通过质量调整大小，提示并返回原数据
        if compressionFormat == .png {
            print("⚠️ PNG为无损压缩，无法压缩到更小尺寸（当前：\(String(format: "%.2f", initialSizeInBytes/1024))KB > 目标：\(targetSizeInKB)KB）")
            return initialData
        }
        
        // 5. 二分法调整JPEG压缩质量，高效逼近目标大小
        return compressWithBinarySearch(
            targetSizeInBytes: targetSizeInBytes,
            minQuality: 0.0,
            maxQuality: 1.0,
            precision: 0.01 // 精度：质量步长，越小越精准（0.01=1%）
        )
    }
    
    /// 重载方法：直接返回压缩后的UIImage（方便调用）
    /// - Parameters:
    ///   - targetSizeInKB: 目标大小（KB）
    ///   - compressionFormat: 压缩格式
    /// - Returns: 压缩后的UIImage（失败返回nil）
    func compressedImage(
        targetSizeInKB: CGFloat,
        compressionFormat: ImageCompressionFormat = .jpeg
    ) -> UIImage? {
        guard let compressedData = self.compressToTargetSize(
            targetSizeInKB: targetSizeInKB,
            compressionFormat: compressionFormat
        ) else {
            return nil
        }
        return UIImage(data: compressedData)
    }
    
    /// 图片压缩格式
    enum ImageCompressionFormat {
        case jpeg // 可调整质量压缩（有损）
        case png  // 无损压缩（质量无影响）
    }
    
    /// 将UIImage转为指定格式的Data
    func convertToData(format: ImageCompressionFormat, quality: CGFloat) -> Data? {
        switch format {
        case .jpeg:
            return self.jpegData(compressionQuality: quality)
        case .png:
            return self.pngData()
        }
    }
    
    /// 二分法压缩JPEG图片（核心逻辑：修复let常量赋值问题）
    private func compressWithBinarySearch(
        targetSizeInBytes: CGFloat,
        minQuality: CGFloat,
        maxQuality: CGFloat,
        precision: CGFloat
    ) -> Data? {
        // 关键修复：将let改为var，允许动态调整
        var currentMinQuality = minQuality
        var currentMaxQuality = maxQuality
        var bestData: Data? = nil
        var bestQuality: CGFloat = 1.0
        
        // 二分法循环：直到质量步长小于精度
        while abs(currentMaxQuality - currentMinQuality) > precision {
            let currentQuality = (currentMinQuality + currentMaxQuality) / 2
            guard let currentData = self.jpegData(compressionQuality: currentQuality) else {
                continue // 生成Data失败则跳过当前质量
            }
            let currentSizeInBytes = CGFloat(currentData.count)
            
            // 记录最优数据（最接近目标且不超标）
            if currentSizeInBytes <= targetSizeInBytes {
                bestData = currentData
                bestQuality = currentQuality
                currentMinQuality = currentQuality // 提高质量，尝试更优效果
            } else {
                currentMaxQuality = currentQuality // 降低质量，缩小尺寸
            }
        }
        
        // 最终处理：若未找到达标数据，返回最小质量的压缩结果
        guard let finalData = bestData ?? self.jpegData(compressionQuality: 0.0) else {
            print("⚠️ 图片压缩失败：无法生成最小质量的JPEG数据")
            return nil
        }
        
        let finalSizeInKB = CGFloat(finalData.count) / 1024
        print("✅ 图片压缩完成（目标：\(targetSizeInBytes/1024)KB，实际：\(String(format: "%.2f", finalSizeInKB))KB，最终质量：\(String(format: "%.2f", bestQuality))）")
        
        return finalData
    }
}

/**
 使用示例：
  
 // 1. 基础用法：压缩图片到50KB（返回Data）
 if let originalImage = UIImage(named: "test_image") {
     if let compressedData = originalImage.compressToTargetSize(targetSizeInKB: 50) {
         // 保存/上传压缩后的Data
         let compressedSize = CGFloat(compressedData.count) / 1024
         print("压缩后大小：\(compressedSize)KB")
     }
 }

 // 2. 便捷用法：直接返回压缩后的UIImage
 if let originalImage = UIImage(named: "test_image"),
    let compressedImage = originalImage.compressedImage(targetSizeInKB: 50) {
     // 使用压缩后的UIImage（如显示在UIImageView）
     imageView.image = compressedImage
 }

 // 3. 指定PNG格式（仅当图片本身小于目标时生效）
 if let originalImage = UIImage(named: "test_image"),
    let compressedData = originalImage.compressToTargetSize(
        targetSizeInKB: 50,
        compressionFormat: .png
    ) {
     print("PNG压缩后大小：\(CGFloat(compressedData.count)/1024)KB")
 }
 
 */




//  MARK: 压缩图片尺寸
import UIKit

public extension UIImage {
    /// 将图片压缩到指定尺寸（核心方法）
    /// - Parameters:
    ///   - targetSize: 目标尺寸（宽高需>0）
    ///   - keepAspectRatio: 是否保持图片宽高比（默认true，避免拉伸变形）
    ///   - cropIfNeeded: 保持比例时，是否裁剪多余部分（默认false，仅缩放不裁剪）
    ///   - scale: 图片缩放因子（默认屏幕scale，适配Retina屏）
    /// - Returns: 压缩后的图片（失败返回nil）
    func compressToTargetSize(
        _ targetSize: CGSize,
        keepAspectRatio: Bool = true,
        cropIfNeeded: Bool = false,
        scale: CGFloat = UIScreen.main.scale
    ) -> UIImage? {
        // 1. 核心参数校验
        guard targetSize.width > 0, targetSize.height > 0 else {
            print("⚠️ 图片尺寸压缩失败：目标尺寸宽/高不能为0")
            return nil
        }
        guard self.cgImage != nil || self.ciImage?.cgImage != nil else {
            print("⚠️ 图片尺寸压缩失败：图片无有效CGImage")
            return nil
        }
        let originalSize = self.size
        
        // 2. 计算最终绘制尺寸（处理比例/裁剪逻辑）
        let drawSize: CGSize
        let drawRect: CGRect
        if keepAspectRatio {
            // 保持比例：计算缩放因子
            let widthRatio = targetSize.width / originalSize.width
            let heightRatio = targetSize.height / originalSize.height
            let scaleFactor = cropIfNeeded ? max(widthRatio, heightRatio) : min(widthRatio, heightRatio)
            
            // 缩放后的尺寸
            let scaledSize = CGSize(
                width: originalSize.width * scaleFactor,
                height: originalSize.height * scaleFactor
            )
            
            if cropIfNeeded {
                // 裁剪模式：缩放后居中裁剪到目标尺寸
                drawSize = targetSize
                // 计算居中偏移
                let offsetX = (scaledSize.width - targetSize.width) / 2
                let offsetY = (scaledSize.height - targetSize.height) / 2
                drawRect = CGRect(
                    x: -offsetX,
                    y: -offsetY,
                    width: scaledSize.width,
                    height: scaledSize.height
                )
            } else {
                // 仅缩放模式：最终尺寸为缩放后尺寸（不超过目标尺寸）
                drawSize = scaledSize
                drawRect = CGRect(origin: .zero, size: scaledSize)
            }
        } else {
            // 不保持比例：直接拉伸到目标尺寸
            drawSize = targetSize
            drawRect = CGRect(origin: .zero, size: targetSize)
        }
        
        // 3. 现代绘图API（UIGraphicsImageRenderer，替代旧上下文）
        let rendererConfig = UIGraphicsImageRendererFormat()
        rendererConfig.scale = scale // 适配Retina屏，避免图片模糊
        let renderer = UIGraphicsImageRenderer(size: drawSize, format: rendererConfig)
        
        return renderer.image { context in
            // 绘制图片（裁剪/缩放）
            self.draw(in: drawRect)
        }
    }
    
    // MARK: 便捷重载方法
    /// 压缩到指定宽度（自动按比例计算高度）
    func compressToTargetWidth(_ targetWidth: CGFloat, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        guard targetWidth > 0 else { return nil }
        let ratio = targetWidth / self.size.width
        let targetHeight = self.size.height * ratio
        return self.compressToTargetSize(CGSize(width: targetWidth, height: targetHeight), scale: scale)
    }
    
    /// 压缩到指定高度（自动按比例计算宽度）
    func compressToTargetHeight(_ targetHeight: CGFloat, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        guard targetHeight > 0 else { return nil }
        let ratio = targetHeight / self.size.height
        let targetWidth = self.size.width * ratio
        return self.compressToTargetSize(CGSize(width: targetWidth, height: targetHeight), scale: scale)
    }
}



// MARK: 保存图片到相册
import UIKit
import Photos // 核心框架：处理相册权限/保存

public extension UIImage {
    /// 保存图片到系统相册（核心方法）
    /// - Parameters:
    ///   - completion: 保存结果回调（主线程执行）
    ///                 - success: 是否保存成功
    ///                 - error: 失败原因（nil表示成功）
    func saveToPhotoAlbum(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        // 1. 检查系统版本（最低支持iOS 11.0）
        guard #available(iOS 11.0, *) else {
            let error = NSError(
                domain: "UIImage.SaveToAlbum",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "系统版本过低，不支持保存到相册（需iOS 11.0+）"]
            )
            completion(false, error)
            return
        }
        
        // 2. 检查并请求相册权限
        checkPhotoLibraryPermission { [weak self] granted, permissionError in
            guard let self = self else {
                completion(false, NSError(domain: "UIImage.SaveToAlbum", code: -2, userInfo: [NSLocalizedDescriptionKey: "图片对象已释放"]))
                return
            }
            
            // 权限请求失败/拒绝
            guard granted, permissionError == nil else {
                completion(false, permissionError ?? NSError(domain: "UIImage.SaveToAlbum", code: -3, userInfo: [NSLocalizedDescriptionKey: "相册权限被拒绝"]))
                return
            }
            
            // 3. 权限通过，执行保存操作
            PHPhotoLibrary.shared().performChanges({
                // 创建保存请求
                PHAssetCreationRequest.forAsset().addResource(
                    with: .photo,
                    data: self.jpegData(compressionQuality: 1.0) ?? self.pngData()!,
                    options: nil
                )
            }) { success, saveError in
                // 切回主线程回调（保证UI操作安全）
                DispatchQueue.main.async {
                    if success {
                        completion(true, nil)
                    } else {
                        let error = saveError ?? NSError(
                            domain: "UIImage.SaveToAlbum",
                            code: -4,
                            userInfo: [NSLocalizedDescriptionKey: "图片保存到相册失败"]
                        )
                        completion(false, error)
                    }
                }
            }
        }
    }
    
    /// 便捷重载：无回调（仅打印日志）
    func saveToPhotoAlbum() {
        saveToPhotoAlbum { success, error in
            if success {
                print("✅ 图片成功保存到相册")
            } else {
                print("❌ 图片保存失败：\(error?.localizedDescription ?? "未知错误")")
            }
        }
    }
}

// MARK: - 私有辅助方法：相册权限检查/请求
public extension UIImage {
    /// 检查并请求相册「添加」权限（iOS 14+ 区分添加/读取，保存仅需添加权限）
    private func checkPhotoLibraryPermission(completion: @escaping (_ granted: Bool, _ error: Error?) -> Void) {
        guard #available(iOS 14.0, *) else {
            // iOS 14以下：统一请求「所有」权限
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized, .limited: // limited仅iOS 14+，这里兼容处理
                        completion(true, nil)
                    case .denied, .restricted:
                        let error = NSError(
                            domain: "UIImage.SaveToAlbum",
                            code: -5,
                            userInfo: [NSLocalizedDescriptionKey: "相册权限被拒绝/受限，请在设置中开启"]
                        )
                        completion(false, error)
                    case .notDetermined:
                        completion(false, NSError(domain: "UIImage.SaveToAlbum", code: -6, userInfo: [NSLocalizedDescriptionKey: "相册权限未确定"]))
                    @unknown default:
                        completion(false, NSError(domain: "UIImage.SaveToAlbum", code: -7, userInfo: [NSLocalizedDescriptionKey: "未知的权限状态"]))
                    }
                }
            }
            return
        }
        
        // iOS 14+：精准请求「添加」权限（无需读取权限）
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized: // 添加权限已授权
                    completion(true, nil)
                case .denied, .restricted:
                    let error = NSError(
                        domain: "UIImage.SaveToAlbum",
                        code: -5,
                        userInfo: [NSLocalizedDescriptionKey: "相册添加权限被拒绝/受限，请在设置中开启"]
                    )
                    completion(false, error)
                case .notDetermined:
                    completion(false, NSError(domain: "UIImage.SaveToAlbum", code: -6, userInfo: [NSLocalizedDescriptionKey: "相册权限未确定"]))
                case .limited: // 仅读取权限（添加权限未授权）
                    let error = NSError(
                        domain: "UIImage.SaveToAlbum",
                        code: -8,
                        userInfo: [NSLocalizedDescriptionKey: "仅获取了相册有限读取权限，无添加权限"]
                    )
                    completion(false, error)
                @unknown default:
                    completion(false, NSError(domain: "UIImage.SaveToAlbum", code: -7, userInfo: [NSLocalizedDescriptionKey: "未知的权限状态"]))
                }
            }
        }
    }
}




// MARK: - UIImage 渲染/裁剪/旋转扩展
import UIKit

public extension UIImage {
    
    // MARK: 核心渲染方法 - 封装 UIGraphicsImageRenderer 实现图片绘制
    /**
     通用图片渲染方法（基于 UIGraphicsImageRenderer，适配 Retina 屏）
     - Parameters:
       - size: 渲染图片的目标尺寸（宽高需 > 0）
       - formatConfig: 渲染格式配置闭包（可选，用于自定义 scale、opaque 等）
       - imageActions: 绘图动作闭包（传入 CGContext，用于绘制内容）
     - Returns: 渲染后的 UIImage（若尺寸非法返回空图片）
     - Note: iOS 11+ 使用 preferred 格式，低版本使用 default 格式，保证兼容性
     */
    static func renderImage(
        size: CGSize,
        formatConfig: ((UIGraphicsImageRendererFormat) -> Void)? = nil,
        imageActions: ((CGContext) -> Void)
    ) -> UIImage {
        // 1. 参数校验：尺寸非法时返回空图片
        guard size.width > 0, size.height > 0 else {
            print("⚠️ 渲染图片失败：目标尺寸宽/高不能为0（size: \(size)）")
            return UIImage()
        }
        
        // 2. 初始化渲染格式（兼容 iOS 11+ 新特性）
        let format: UIGraphicsImageRendererFormat
        if #available(iOS 11.0, *) {
            format = .preferred() // iOS 11+ 优先使用系统推荐格式（适配深色模式等）
        } else {
            format = .default()   // 低版本使用默认格式
        }
        
        // 3. 自定义格式配置（如 scale、opaque 等）
        formatConfig?(format)
        
        // 4. 创建渲染器并执行绘图动作
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            imageActions(context.cgContext) // 将 CGContext 传入绘图闭包
        }
    }
    
    // MARK: 图片裁剪方法 - 支持旋转、圆形/矩形裁剪
    /**
     裁剪图片（支持旋转矫正、圆形裁剪、指定区域裁剪）
     - Parameters:
       - angle: 图片旋转角度（仅处理 90° 倍数的旋转，如 -90/-180/-270）
       - editRect: 裁剪的目标区域（相对于原图的矩形范围）
       - isCircle: 是否裁剪为圆形（true 则忽略矩形，按 editRect 尺寸生成圆形）
     - Returns: 裁剪后的图片（若参数非法返回原图）
     - Note: 旋转仅处理 -90/-180/-270°，其他角度不旋转；圆形裁剪基于 editRect 尺寸生成正圆
     */
    func clipImage(angle: CGFloat, editRect: CGRect, isCircle: Bool) -> UIImage {
        // 1. 参数校验：裁剪区域非法时返回原图
        guard editRect.width > 0, editRect.height > 0 else {
            print("⚠️ 裁剪图片失败：裁剪区域尺寸非法（editRect: \(editRect)）")
            return self
        }
        
        // 2. 归一化旋转角度（将角度转换为 -360~0 范围，仅处理 90° 倍数）
        let normalizedAngle = ((Int(angle) % 360) - 360) % 360
        // 根据归一化角度矫正图片方向
        var rotatedImage: UIImage = self
        switch normalizedAngle {
        case -90:
            rotatedImage = rotate(orientation: .left)    // 向左旋转90°
        case -180:
            rotatedImage = rotate(orientation: .down)    // 旋转180°
        case -270:
            rotatedImage = rotate(orientation: .right)   // 向右旋转90°
        default:
            rotatedImage = self // 非90°倍数角度，不旋转
        }
        
        // 3. 无需裁剪的场景：非圆形裁剪 且 裁剪区域等于旋转后图片尺寸
        guard isCircle || !editRect.size.equalTo(rotatedImage.size) else {
            return rotatedImage
        }
        
        // 4. 计算绘制偏移量（将原图对应裁剪区域绘制到新画布的原点）
        let drawOrigin = CGPoint(x: -editRect.minX, y: -editRect.minY)
        
        // 5. 渲染裁剪后的图片（圆形/矩形）
        let clippedRenderedImage = UIImage.renderImage(size: editRect.size) { format in
            // 继承原图的 scale，保证 Retina 屏清晰度
            format.scale = rotatedImage.scale
        } imageActions: { context in
            // 圆形裁剪：添加圆形路径并裁切
            if isCircle {
                let circlePath = CGRect(origin: .zero, size: editRect.size)
                context.addEllipse(in: circlePath) // 添加圆形路径
                context.clip() // 裁切：仅绘制圆形区域内的内容
            }
            // 绘制旋转后的图片到目标区域
            rotatedImage.draw(at: drawOrigin)
        }
        
        // 6. 转换为带 scale 的 UIImage（保证尺寸/清晰度匹配）
        guard let clippedCGImage = clippedRenderedImage.cgImage else {
            return clippedRenderedImage // 若 CGImage 为空，返回渲染后的图片
        }
        let finalClippedImage = UIImage(
            cgImage: clippedCGImage,
            scale: rotatedImage.scale,
            orientation: .up // 裁剪后重置为正向
        )
        
        return finalClippedImage
    }
    
    // MARK: 图片旋转方法 - 按指定方向旋转图片
    /**
     按指定方向旋转图片（适配 Retina 屏，替换老旧绘图 API）
     - Parameter orientation: 目标旋转方向（UIImage.Orientation）
     - Returns: 旋转后的图片（若旋转失败返回原图）
     - Note: 支持 90°/180°/270° 旋转及镜像旋转，适配所有方向
     */
    func rotate(orientation: UIImage.Orientation) -> UIImage {
        // 1. 校验 CGImage 有效性
        guard let imageRef = self.cgImage else {
            print("⚠️ 旋转图片失败：图片无有效 CGImage")
            return self
        }
        
        // 2. 原图尺寸（基于 CGImage，避免 orientation 影响）
        let originalRect = CGRect(
            origin: .zero,
            size: CGSize(width: CGFloat(imageRef.width), height: CGFloat(imageRef.height))
        )
        
        // 3. 计算旋转后的画布尺寸（宽高交换，如竖屏转横屏）
        var rotatedBounds = originalRect
        // 左右旋转时，宽高交换
        if [.left, .leftMirrored, .right, .rightMirrored].contains(orientation) {
            rotatedBounds = swapRectWidthAndHeight(rotatedBounds)
        }
        
        // 4. 构建旋转变换矩阵
        var rotationTransform = CGAffineTransform.identity
        switch orientation {
        case .up:
            return self // 正向，无需旋转
        case .upMirrored:
            // 向上镜像：水平翻转
            rotationTransform = rotationTransform.translatedBy(x: originalRect.width, y: 0)
            rotationTransform = rotationTransform.scaledBy(x: -1, y: 1)
        case .down:
            // 向下：旋转180°
            rotationTransform = rotationTransform.translatedBy(x: originalRect.width, y: originalRect.height)
            rotationTransform = rotationTransform.rotated(by: .pi)
        case .downMirrored:
            // 向下镜像：垂直翻转
            rotationTransform = rotationTransform.translatedBy(x: 0, y: originalRect.height)
            rotationTransform = rotationTransform.scaledBy(x: 1, y: -1)
        case .left:
            // 向左旋转90°
            rotationTransform = rotationTransform.translatedBy(x: 0, y: originalRect.width)
            rotationTransform = rotationTransform.rotated(by: CGFloat.pi * 3 / 2)
        case .leftMirrored:
            // 向左镜像旋转90°
            rotationTransform = rotationTransform.translatedBy(x: originalRect.height, y: originalRect.width)
            rotationTransform = rotationTransform.scaledBy(x: -1, y: 1)
            rotationTransform = rotationTransform.rotated(by: CGFloat.pi * 3 / 2)
        case .right:
            // 向右旋转90°
            rotationTransform = rotationTransform.translatedBy(x: originalRect.height, y: 0)
            rotationTransform = rotationTransform.rotated(by: CGFloat.pi / 2)
        case .rightMirrored:
            // 向右镜像旋转90°
            rotationTransform = rotationTransform.scaledBy(x: -1, y: 1)
            rotationTransform = rotationTransform.rotated(by: CGFloat.pi / 2)
        @unknown default:
            print("⚠️ 旋转图片失败：未知的旋转方向")
            return self
        }
        
        // 5. 使用 UIGraphicsImageRenderer 渲染旋转后的图片（替换老旧 API，适配 Retina）
        let rotatedImage = UIImage.renderImage(size: rotatedBounds.size) { format in
            // 继承原图的 scale，保证清晰度
            format.scale = self.scale
        } imageActions: { context in
            // 调整坐标系（CGContext 原点在左下角，需翻转Y轴）
            switch orientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                context.scaleBy(x: -1, y: 1)
                context.translateBy(x: -rotatedBounds.width, y: 0)
            default:
                context.scaleBy(x: 1, y: -1)
                context.translateBy(x: 0, y: -rotatedBounds.height)
            }
            
            // 应用旋转变换矩阵
            context.concatenate(rotationTransform)
            // 绘制原图到旋转后的画布
            context.draw(imageRef, in: originalRect)
        }
        
        return rotatedImage
    }
    
    // MARK: 辅助方法 - 交换矩形的宽高
    /**
     交换矩形的宽和高（用于旋转图片时调整画布尺寸）
     - Parameter rect: 原始矩形
     - Returns: 宽高交换后的新矩形
     */
    private func swapRectWidthAndHeight(_ rect: CGRect) -> CGRect {
        return CGRect(
            origin: rect.origin,
            size: CGSize(width: rect.height, height: rect.width)
        )
    }
}
