//
//  JY_TimeTool.swift
//  JY_GeneralDevelopmentTools
//
//  Created by JYYQLin on 2025/12/24.
//

import Foundation

/// 时间处理工具类
final class JY_TimeTool {
    /// 私有化构造方法，避免实例化（工具类建议只使用静态方法）
    private init() {}
    
    /// 获取当前秒级时间戳（Int类型）
    /// - Returns: 秒级时间戳
    static func currentTimestamp() -> Int {
        // timeIntervalSince1970 返回的是Double类型（带毫秒），取整后得到秒级时间戳
        return Int(Date().timeIntervalSince1970)
    }
}

/// 给Int扩展时间格式转换方法
extension Int {
    /// 将秒数转换成 分:秒 或 时:分:秒 格式的字符串
    /// - Returns: 格式化后的时间字符串（例如：01:23 或 01:23:45）
    func toTimeString() -> String {
        // 处理负数情况，确保秒数非负
        let totalSeconds = Swift.max(self, 0)
        
        // 计算小时、分钟、秒
        let hours = totalSeconds / 3600
        let remainingSecondsAfterHours = totalSeconds % 3600
        let minutes = remainingSecondsAfterHours / 60
        let seconds = remainingSecondsAfterHours % 60
        
        // 补零格式化（确保两位数，例如 1秒显示为01，5分显示为05）
        let formattedMinutes = String(format: "%02d", minutes)
        let formattedSeconds = String(format: "%02d", seconds)
        
        // 根据小时数判断显示格式
        if hours > 0 {
            let formattedHours = String(format: "%02d", hours)
            return "\(formattedHours):\(formattedMinutes):\(formattedSeconds)"
        } else {
            return "\(formattedMinutes):\(formattedSeconds)"
        }
    }
}
