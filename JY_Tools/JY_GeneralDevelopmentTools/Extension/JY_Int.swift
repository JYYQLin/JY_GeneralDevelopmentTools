//
//  JY_Int.swift
//  JY_GeneralDevelopmentTools
//
//  Created by JYYQLin on 2026/1/12.
//

import Foundation

extension Int {
    /// 将数字转换为带有 K/M/G 等后缀的缩写字符串（支持自定义小数位数）
    /// - Parameter fractionDigits: 保留的小数位数（默认2位，小于0时自动修正为0）
    /// - Returns: 带单位的缩写字符串（如 1500 → 1.5K，1250000 → 1.25M）
    public func yq_to_unitString(fractionDigits: Int = 2) -> String {
        // 1. 处理零、负数（直接返回原值）
        guard self > 0 else {
            return "\(self)"
        }
        
        // 修复报错：明确调用 Swift 全局的 max 函数（避免作用域内同名变量覆盖）
        let validFractionDigits = Swift.max(fractionDigits, 0)
        
        // 2. 定义单位体系（SI 10^3 进制：K=千, M=百万, G=十亿...）
        struct UnitInfo {
            let suffix: String // 单位后缀
            let divisor: Double // 对应的除数（10^3, 10^6...）
        }
        let units = [
            UnitInfo(suffix: "K", divisor: 1e3),   // 千
            UnitInfo(suffix: "M", divisor: 1e6),   // 百万
            UnitInfo(suffix: "G", divisor: 1e9),   // 十亿
            UnitInfo(suffix: "T", divisor: 1e12),  // 万亿
            UnitInfo(suffix: "P", divisor: 1e15),  // 千万亿
            UnitInfo(suffix: "E", divisor: 1e18)   // 百亿亿
        ]
        
        // 3. 匹配最合适的单位（找最大的能整除的单位）
        let originalValue = Double(self)
        var targetValue = originalValue
        var targetUnit: UnitInfo?
        
        for unit in units {
            let convertedValue = originalValue / unit.divisor
            // 当转换后的值 ≥1 且 <1000 时，使用当前单位（避免跨级，如 999999 → 999.99K 而非 0.99M）
            if convertedValue >= 1 && convertedValue < 1000 {
                targetValue = convertedValue
                targetUnit = unit
                break
            }
        }
        
        // 4. 无匹配单位（数值 < 1000），直接返回原值
        guard let unit = targetUnit else {
            return "\(self)"
        }
        
        // 5. 格式化数值（按指定小数位数，自动省略末尾无效零）
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0       // 最少0位小数（如 1000 → 1K 而非 1.00K）
        formatter.maximumFractionDigits = validFractionDigits // 最多N位小数
        formatter.roundingMode = .halfUp          // 四舍五入（符合常规认知）
        
        // 6. 格式化失败时返回原值，否则返回「数值+单位」
        if let formattedValue = formatter.string(from: NSNumber(value: targetValue)) {
            return "\(formattedValue)\(unit.suffix)"
        } else {
            return "\(self)"
        }
    }
}
