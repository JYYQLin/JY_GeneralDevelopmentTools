//
//  JY_UIColor.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/24.
//

import UIKit

// MARK: - UIColor 扩展（合并所有功能，优化逻辑）
extension UIColor {
    // MARK: 1. 便捷创建 RGB 颜色（0-255 范围）
    /**
     通过 RGB 值创建 UIColor（简化 0-255 范围转换）
     - Parameters:
       - red: 红色值（0-255）
       - green: 绿色值（0-255）
       - blue: 蓝色值（0-255）
       - alpha: 透明度（默认 1.0）
     - Returns: UIColor 实例
     - Note: 自动将 RGB 值除以 255 适配 UIColor 原生范围
     */
    public static func yq_color(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        // 边界校验：限制 RGB 值在 0-255 范围，避免非法值
        let clampedRed = max(0, min(255, red))
        let clampedGreen = max(0, min(255, green))
        let clampedBlue = max(0, min(255, blue))
        return UIColor(
            red: clampedRed / 255.0,
            green: clampedGreen / 255.0,
            blue: clampedBlue / 255.0,
            alpha: alpha
        )
    }
    
    // MARK: 2. 生成随机颜色
    /**
     生成随机 RGB 颜色（透明度 1.0）
     - Returns: 随机 UIColor 实例
     - Note: 适配 iOS 10+ 原生 Random API，替代不安全的 arc4random()
     */
    public static func yq_random() -> UIColor {
        // Swift 原生随机数 API（更安全、易读，iOS 10+ 支持）
        let r = CGFloat(UInt32.random(in: 0...255))
        let g = CGFloat(UInt32.random(in: 0...255))
        let b = CGFloat(UInt32.random(in: 0...255))
        return .yq_color(red: r, green: g, blue: b)
    }
    
    // MARK: 3. 通过十六进制字符串创建颜色（支持 #RRGGBB/0XRRGGBB/RRGGBB，可选 alpha）
    /**
     通过十六进制字符串创建 UIColor
     - Parameter hexString: 十六进制字符串（支持格式：#RRGGBB、0XRRGGBB、RRGGBB、#RRGGBBAA、0XRRGGBBAA、RRGGBBAA）
     - Returns: UIColor 实例（解析失败返回 clear）
     - Note: 自动忽略空格/换行，大小写不敏感，支持 alpha 通道
     */
    public static func yq_color(hexString: String) -> UIColor {
        // 便捷初始化：失败返回 clear（兼容原逻辑）
        return UIColor(yq_hex: hexString) ?? .clear
    }
    
    // MARK: 4. 便捷初始化（推荐）：十六进制字符串创建颜色（失败返回 nil）
    /**
     安全的十六进制字符串初始化方法（失败返回 nil）
     - Parameters:
       - hex: 十六进制字符串（支持 #RRGGBB、0XRRGGBB、RRGGBB、#RRGGBBAA、0XRRGGBBAA、RRGGBBAA）
       - alpha: 自定义透明度（默认 nil，优先使用字符串中的 alpha 通道）
     - Note: 比 yq_color(hexString:) 更安全，推荐使用
     */
    public convenience init?(yq_hex hex: String, alpha: CGFloat? = nil) {
        // 预处理：移除空格/换行，转大写，统一格式
        let cleanedHex = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        
        // 提取纯十六进制字符（移除 #/0X 前缀）
        let pureHex: String
        if cleanedHex.hasPrefix("#") {
            pureHex = String(cleanedHex.dropFirst())
        } else if cleanedHex.hasPrefix("0X") {
            pureHex = String(cleanedHex.dropFirst(2))
        } else {
            pureHex = cleanedHex
        }
        
        // 校验长度：仅支持 6 位（RGB）或 8 位（RGBA）
        guard [6, 8].contains(pureHex.count) else { return nil }
        
        // 校验字符合法性：仅允许 0-9/A-F
        guard pureHex.allSatisfy({ "0123456789ABCDEF".contains($0) }) else { return nil }
        
        // 抽取 RGB 组件
        let rComponent = String(pureHex.prefix(2))
        let gComponent = String(pureHex.dropFirst(2).prefix(2))
        let bComponent = String(pureHex.dropFirst(4).prefix(2))
        
        // 转换为 CGFloat（0-255）
        guard let r = Self.yq_hexComponentToFloat(rComponent),
              let g = Self.yq_hexComponentToFloat(gComponent),
              let b = Self.yq_hexComponentToFloat(bComponent) else { return nil }
        
        // 处理 Alpha 通道
        let finalAlpha: CGFloat
        if pureHex.count == 8 {
            // 8 位格式：最后 2 位为 Alpha
            let aComponent = String(pureHex.suffix(2))
            guard let a = Self.yq_hexComponentToFloat(aComponent) else { return nil }
            finalAlpha = alpha ?? (a / 255.0)
        } else {
            // 6 位格式：使用自定义 alpha 或默认 1.0
            finalAlpha = alpha ?? 1.0
        }
        
        // 初始化 UIColor
        self.init(
            red: r / 255.0,
            green: g / 255.0,
            blue: b / 255.0,
            alpha: finalAlpha
        )
    }
    
    // MARK: 私有辅助方法：十六进制组件（2 位）转 Float（0-255）
    /**
     将 2 位十六进制字符串转换为 0-255 的 CGFloat
     - Parameter component: 2 位十六进制字符串（如 "FF"、"1A"）
     - Returns: 转换后的值（nil=转换失败）
     */
    private static func yq_hexComponentToFloat(_ component: String) -> CGFloat? {
        // 校验长度：必须为 2 位
        guard component.count == 2 else { return nil }
        
        var sum: UInt32 = 0
        // 遍历字符，转换为十六进制数值
        for char in component.uppercased() {
            guard let scalar = char.unicodeScalars.first else { return nil }
            let value: UInt32
            
            // 0-9：48-57
            if scalar.value >= 48 && scalar.value <= 57 {
                value = scalar.value - 48
            }
            // A-F：65-70
            else if scalar.value >= 65 && scalar.value <= 70 {
                value = scalar.value - 55 // A=10, B=11...F=15
            }
            // 非法字符
            else {
                return nil
            }
            
            sum = sum * 16 + value
        }
        
        // 限制范围在 0-255
        return CGFloat(min(sum, 255))
    }
}
