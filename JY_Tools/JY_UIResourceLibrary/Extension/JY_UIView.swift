//
//  JY_UIView.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/24.
//

import UIKit

// MARK: - UIView 生成图片扩展
extension UIView {
    // MARK: 核心方法 - 生成整个 View 的图片
    /**
     将当前 View 的完整内容生成为 UIImage（适配 Retina 屏、离屏渲染）
     - Parameters:
       - scale: 图片缩放因子（默认使用屏幕 scale，保证高清；传1.0则为非Retina）
       - isOpaque: 是否不透明（true 则背景为白色，false 保留透明通道）
       - afterScreenUpdates: 是否等待屏幕更新完成（true 保证捕获最新UI状态，false 更快但可能不及时）
     - Returns: 生成的图片（失败返回 nil）
     - Note: 支持包含 layer 特效（阴影、圆角、渐变）的 View，自动处理离屏渲染
     */
    func generateImage(
        scale: CGFloat = UIScreen.main.scale,
        isOpaque: Bool = false,
        afterScreenUpdates: Bool = true
    ) -> UIImage? {
        // 1. 参数校验：View 尺寸非法时返回 nil
        guard bounds.width > 0, bounds.height > 0 else {
            print("⚠️ 生成 View 图片失败：View 尺寸非法（bounds: \(bounds)）")
            return nil
        }
        
        // 2. 配置渲染格式（适配 Retina、透明/不透明）
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale          // 关键：设置 scale 保证高清
        format.opaque = isOpaque      // 透明通道控制
        format.preferredRange = .automatic // 自动适配色彩范围
        
        // 3. 使用现代渲染器生成图片（替代老旧 API，避免内存泄漏）
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
        return renderer.image { [weak self] context in
            guard let self = self else { return }
            // 绘制 View 内容（包含所有子视图、layer 特效）
            self.layer.render(in: context.cgContext)
        }
    }
    
    // MARK: 重载方法 - 生成 View 指定区域的图片
    /**
     生成 View 中指定区域的图片
     - Parameters:
       - rect: 要捕获的区域（相对于 View 的本地坐标系）
       - scale: 图片缩放因子（默认屏幕 scale）
       - isOpaque: 是否不透明
       - afterScreenUpdates: 是否等待屏幕更新
     - Returns: 裁剪后的指定区域图片（失败返回 nil）
     */
    func generateImage(
        for rect: CGRect,
        scale: CGFloat = UIScreen.main.scale,
        isOpaque: Bool = false,
        afterScreenUpdates: Bool = true
    ) -> UIImage? {
        // 1. 校验裁剪区域合法性（需在 View 范围内）
        guard rect.width > 0, rect.height > 0, bounds.contains(rect) else {
            print("⚠️ 生成指定区域图片失败：裁剪区域非法（rect: \(rect)，bounds: \(bounds)）")
            return nil
        }
        
        // 2. 先生成整个 View 的图片
        guard let fullImage = generateImage(scale: scale, isOpaque: isOpaque, afterScreenUpdates: afterScreenUpdates) else {
            return nil
        }
        
        // 3. 裁剪到指定区域（转换坐标系：UIKit 原点在左上角，CGImage 原点在左下角）
        let cgRect = CGRect(
            x: rect.origin.x * scale,
            y: (bounds.height - rect.maxY) * scale,
            width: rect.width * scale,
            height: rect.height * scale
        )
        
        // 4. 裁剪 CGImage 并生成最终图片
        guard let cgImage = fullImage.cgImage?.cropping(to: cgRect) else {
            print("⚠️ 裁剪图片失败：指定区域超出图片范围")
            return nil
        }
        
        return UIImage(
            cgImage: cgImage,
            scale: scale,
            orientation: .up
        )
    }
    
    // MARK: 便捷方法 - 生成截图并保存到相册
    /**
     生成 View 图片并保存到系统相册（需配置 Info.plist 权限）
     - Parameters:
       - scale: 图片缩放因子
       - isOpaque: 是否不透明
       - completion: 保存结果回调（主线程执行）
     */
    func generateAndSaveToPhotoAlbum(
        scale: CGFloat = UIScreen.main.scale,
        isOpaque: Bool = false,
        completion: @escaping (_ success: Bool, _ error: Error?) -> Void
    ) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(false, NSError(domain: "UIView.GenerateImage", code: -1, userInfo: [NSLocalizedDescriptionKey: "View 对象已释放"]))
                }
                return
            }
            
            // 生成图片
            guard let viewImage = self.generateImage(scale: scale, isOpaque: isOpaque) else {
                DispatchQueue.main.async {
                    completion(false, NSError(domain: "UIView.GenerateImage", code: -2, userInfo: [NSLocalizedDescriptionKey: "生成 View 图片失败"]))
                }
                return
            }
            
            // 保存到相册（复用之前的 UIImage 保存扩展）
            viewImage.saveToPhotoAlbum { success, error in
                DispatchQueue.main.async {
                    completion(success, error)
                }
            }
        }
    }
}
