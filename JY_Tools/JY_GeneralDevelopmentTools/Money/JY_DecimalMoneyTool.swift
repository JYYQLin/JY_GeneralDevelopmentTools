//
//  JY_DecimalMoneyTool.swift
//  JY_GeneralDevelopmentTools
//
//  Created by JYYQLin on 2026/1/4.
//

import Foundation

/// 高精度金额工具类（支持分/元双单位传入，默认分单位；支持万/亿单位格式化）
public struct JY_DecimalMoneyTool {
    // 金额单位枚举（明确区分分/元，避免歧义）
    public enum MoneyUnit {
        case fen // 分单位
        case yuan // 元单位
    }
    
    // MARK: - 1. 功能1：金额String → 标准价格格式（保留两位小数，可选千分位/货币符号）
    /// 将分/元单位字符串金额，转换为标准元单位价格字符串
    /// - Parameters:
    ///   - moneyString: 金额字符串（数字格式，如"1234"）
    ///   - unit: 金额单位（默认.fen，分单位）
    ///   - showThousandSeparator: 是否显示千分位分隔符（默认true）
    ///   - currencySymbol: 货币符号（如"¥"、"$"，传nil不显示，默认nil）
    ///   - defaultText: 异常场景兜底文本（默认"0.00"）
    /// - Returns: 格式化后的标准价格字符串
    public static func formatFenToNormalPrice(
        moneyString: String?,
        unit: MoneyUnit = .fen,
        showThousandSeparator: Bool = true,
        currencySymbol: String? = nil,
        defaultText: String = "0.00"
    ) -> String {
        // 转换为元单位Decimal（根据传入单位自动适配）
        let yuanDecimal = convertMoneyStringToYuanDecimal(moneyString: moneyString, unit: unit)
        // 格式化标准价格
        return formatYuanDecimalToNormalPrice(
            yuanDecimal: yuanDecimal,
            showThousandSeparator: showThousandSeparator,
            currencySymbol: currencySymbol,
            defaultText: defaultText
        )
    }
    
    // MARK: - 2. 功能2：两个金额String（总额-被减数）→ 余额（标准价格格式）
    /// 计算总额与被减数的余额（高精度计算，元单位格式化）
    /// - Parameters:
    ///   - totalMoneyString: 总额（数字格式字符串）
    ///   - subtractMoneyString: 被减数（数字格式字符串）
    ///   - unit: 金额单位（默认.fen，分单位；两个金额需统一单位）
    ///   - showThousandSeparator: 是否显示千分位（默认true）
    ///   - currencySymbol: 货币符号（默认nil）
    ///   - defaultText: 异常兜底文本（默认"0.00"）
    /// - Returns: 格式化后的余额价格字符串
    public static func calculateBalance(
        totalMoneyString: String?,
        subtractMoneyString: String?,
        unit: MoneyUnit = .fen,
        showThousandSeparator: Bool = true,
        currencySymbol: String? = nil,
        defaultText: String = "0.00"
    ) -> String {
        // 转为统一单位的Decimal（避免单位不一致导致计算错误）
        let totalDecimal = convertMoneyStringToDecimal(moneyString: totalMoneyString, unit: unit)
        let subtractDecimal = convertMoneyStringToDecimal(moneyString: subtractMoneyString, unit: unit)
        // 计算余额（统一单位内计算，无精度丢失）
        let balanceDecimal = totalDecimal - subtractDecimal
        // 转换为元单位Decimal
        let balanceYuanDecimal = convertToYuanDecimal(from: balanceDecimal, unit: unit)
        // 格式化标准价格
        return formatYuanDecimalToNormalPrice(
            yuanDecimal: balanceYuanDecimal,
            showThousandSeparator: showThousandSeparator,
            currencySymbol: currencySymbol,
            defaultText: defaultText
        )
    }
    
    // MARK: - 新增：辅助方法 → 清理格式化字符串（去除千分位逗号、空白字符，保留纯数字+小数点）
    public static func cleanFormattedMoneyString(_ moneyString: String?) -> String {
        guard let str = moneyString, !str.trimmingCharacters(in: .whitespaces).isEmpty else {
            return "0"
        }
        // 去除千分位逗号（兼容不同地区分隔符，优先去除逗号，再去除其他非数字+小数点字符）
        var pureStr = str.replacingOccurrences(of: ",", with: "")
        // 过滤：只保留数字和小数点（避免货币符号、其他字符干扰）
        pureStr = pureStr.filter { character in
            character.isNumber || character == "."
        }
        return pureStr.isEmpty ? "0" : pureStr
    }
    
    // MARK: - 3. 功能3：两个金额String → 存入比（存入金额/总额，保留两位小数）
    /// 计算存入金额占总额的比例，保留两位小数
    /// - Parameters:
    ///   - totalMoneyString: 总额（数字格式字符串，不可为0）
    ///   - depositMoneyString: 存入金额（数字格式字符串）
    ///   - unit: 金额单位（默认.fen，分单位；两个金额需统一单位）
    ///   - defaultRatio: 异常兜底比例（默认"0.00"）
    /// - Returns: 保留两位小数的比例字符串（如"0.68"对应68%）
    public static func calculateDepositRatio(
        totalMoneyString: String?,
        depositMoneyString: String?,
        unit: MoneyUnit = .fen,
        defaultRatio: String = "0.00"
    ) -> String {
        // 转为统一单位的Decimal（消除单位影响，直接计算）
        let totalDecimal = convertMoneyStringToDecimal(moneyString: totalMoneyString, unit: unit)
        let depositDecimal = convertMoneyStringToDecimal(moneyString: depositMoneyString, unit: unit)
        
        // 除零保护
        guard totalDecimal != Decimal(0) else {
            return defaultRatio
        }
        
        // 计算比例
        let ratioDecimal = depositDecimal / totalDecimal
        
        // 格式化保留两位小数（四舍五入）
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.roundingMode = .halfUp
        
        // 直接将 Decimal 转为 NSNumber 传入，仅校验格式化结果
        guard let ratioString = formatter.string(from: ratioDecimal as NSNumber) else {
            return defaultRatio
        }
        
        return ratioString
    }
    
    // MARK: - 4. 功能4：金额String + Int天数 → 日均金额（Decimal，元单位，高精度）
    /// 金额字符串按天数均分，返回日均金额（Decimal，元单位）
    /// - Parameters:
    ///   - moneyString: 金额字符串（数字格式）
    ///   - unit: 金额单位（默认.fen，分单位）
    ///   - days: 天数（Int，不可为0）
    /// - Returns: 日均金额（Decimal，元单位，异常返回0）
    public static func calculateDailyAverage(
        moneyString: String?,
        unit: MoneyUnit = .fen,
        days: Int
    ) -> Decimal {
        // 转为对应单位的Decimal
        let moneyDecimal = convertMoneyStringToDecimal(moneyString: moneyString, unit: unit)
        // 调用Decimal重载方法
        return calculateDailyAverage(moneyDecimal: moneyDecimal, unit: unit, days: days)
    }
    
    // MARK: - 5. 功能5：金额Decimal + Int天数 → 日均金额（Decimal，元单位，高精度）
    /// 金额Decimal按天数均分，返回日均金额（Decimal，元单位）
    /// - Parameters:
    ///   - moneyDecimal: 金额（Decimal，对应传入的unit单位）
    ///   - unit: 金额单位（默认.fen，分单位）
    ///   - days: 天数（Int，不可为0）
    /// - Returns: 日均金额（Decimal，元单位，异常返回0）
    public static func calculateDailyAverage(
        moneyDecimal: Decimal,
        unit: MoneyUnit = .fen,
        days: Int
    ) -> Decimal {
        // 天数非零保护
        guard days > 0 else {
            return Decimal(0)
        }
        // 先转为元单位，再除以天数（高精度计算）
        let yuanDecimal = convertToYuanDecimal(from: moneyDecimal, unit: unit)
        let dailyAverageDecimal = yuanDecimal / Decimal(days)
        return dailyAverageDecimal
    }
    
    // MARK: - 6. 功能6：金额String → 智能价格格式（自动适配万/亿单位，保留两位小数，修复负数处理）
    /// 分/元单位字符串金额转为智能价格格式（>亿显亿，>万显万，否则显标准格式，支持负数）
    /// - Parameters:
    ///   - moneyString: 金额字符串（数字格式，支持负数，如"-123456"）
    ///   - unit: 金额单位（默认.fen，分单位）
    ///   - currencySymbol: 货币符号（如"¥"，传nil不显示，默认nil）
    ///   - defaultText: 异常兜底文本（默认"0.00"）
    /// - Returns: 智能格式化后的价格字符串（负数示例："-¥1.23万"、"-9999.00"）
    public static func formatFenToSmartPrice(
        moneyString: String?,
        unit: MoneyUnit = .fen,
        currencySymbol: String? = nil,
        defaultText: String = "0.00"
    ) -> String {
        // 转换为元单位Decimal（根据传入单位自动适配）
        let yuanDecimal = convertMoneyStringToYuanDecimal(moneyString: moneyString, unit: unit)
        
        // 1. 分离符号和绝对值（核心修复：处理负数）
        let isNegative = yuanDecimal < 0
        let absYuanDecimal = abs(yuanDecimal)
        
        let tenThousandYuan = Decimal(10000)
        let hundredMillionYuan = Decimal(100000000)
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.roundingMode = .halfUp
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false // 智能格式不显示千分位
        
        let symbol = currencySymbol ?? ""
        var resultStr = defaultText
        
        // 2. 处理绝对值的单位格式化
        if absYuanDecimal >= hundredMillionYuan {
            let hundredMillionDecimal = absYuanDecimal / hundredMillionYuan
            guard let numberStr = formatter.string(from: hundredMillionDecimal as NSNumber) else {
                return defaultText
            }
            resultStr = "\(symbol)\(numberStr)亿"
        } else if absYuanDecimal >= tenThousandYuan {
            let tenThousandDecimal = absYuanDecimal / tenThousandYuan
            guard let numberStr = formatter.string(from: tenThousandDecimal as NSNumber) else {
                return defaultText
            }
            resultStr = "\(symbol)\(numberStr)万"
        } else {
            // 小于万，使用标准格式（无千分位）
            resultStr = formatYuanDecimalToNormalPrice(
                yuanDecimal: absYuanDecimal,
                showThousandSeparator: false,
                currencySymbol: currencySymbol,
                defaultText: defaultText
            )
        }
        
        // 3. 补回负号（核心修复：负号放在最前面）
        if isNegative {
            resultStr = "-\(resultStr)"
        }
        
        return resultStr
    }
    
}

// MARK: - 私有辅助方法（工具内部复用，隐藏实现细节）
extension JY_DecimalMoneyTool {
    /// 金额String → Decimal（对应传入的单位，异常返回0）
    private static func convertMoneyStringToDecimal(moneyString: String?, unit: MoneyUnit) -> Decimal {
        guard let moneyStr = moneyString,
              !moneyStr.trimmingCharacters(in: .whitespaces).isEmpty else {
            return Decimal(0)
        }
        
        // 根据单位选择转换逻辑：分单位转Int，元单位转Double（支持小数）
        switch unit {
        case .fen:
            // 分单位必须是整数，转Int后再转Decimal
            guard let moneyInt = Int(moneyStr) else {
                return Decimal(0)
            }
            return Decimal(moneyInt)
        case .yuan:
            // 元单位支持小数，转Double后再转Decimal（兼容常规小数场景）
            guard let moneyDouble = Double(moneyStr) else {
                return Decimal(0)
            }
            return Decimal(moneyDouble)
        }
    }
    
    /// 金额String → Decimal（元单位，异常返回0）
    private static func convertMoneyStringToYuanDecimal(moneyString: String?, unit: MoneyUnit) -> Decimal {
        let moneyDecimal = convertMoneyStringToDecimal(moneyString: moneyString, unit: unit)
        return convertToYuanDecimal(from: moneyDecimal, unit: unit)
    }
    
    /// 任意单位Decimal → 元单位Decimal（核心单位转换逻辑）
    private static func convertToYuanDecimal(from decimal: Decimal, unit: MoneyUnit) -> Decimal {
        switch unit {
        case .fen:
            // 分 → 元：除以100
            return decimal / Decimal(100)
        case .yuan:
            // 元 → 元：直接返回
            return decimal
        }
    }
    
    /// 元单位Decimal → 标准价格字符串
    private static func formatYuanDecimalToNormalPrice(
        yuanDecimal: Decimal,
        showThousandSeparator: Bool,
        currencySymbol: String?,
        defaultText: String
    ) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.usesGroupingSeparator = showThousandSeparator
        formatter.groupingSeparator = NumberFormatter().locale.groupingSeparator
        formatter.decimalSeparator = NumberFormatter().locale.decimalSeparator
        formatter.roundingMode = .halfUp
        
        // 配置货币符号
        if let symbol = currencySymbol, !symbol.isEmpty {
            formatter.numberStyle = .currency
            formatter.currencySymbol = symbol
        } else {
            formatter.numberStyle = .decimal
        }
        
        let yuanNumber = yuanDecimal as NSNumber
        guard let formattedPrice = formatter.string(from: yuanNumber) else {
            return defaultText
        }
        
        return formattedPrice
    }
}

// 先保留你的 JY_DecimalMoneyTool 主结构，这里只展示修正后的扩展
public extension JY_DecimalMoneyTool {
    
    /// 将字符串转为保留两位小数的 Decimal 类型，无法转换时返回 Decimal(0)
    /// - Parameter str: 待转换的字符串（支持整数、小数格式，如 "123"、"123.456"、"abc" 等）
    /// - Returns: 保留两位小数的 Decimal（四舍五入），转换失败返回 Decimal(0)
    static func stringToTwoDecimalPlaces(_ str: String?) -> Decimal {
        // 步骤1：前置校验与预处理（去除空白字符，处理空值）
        guard let inputStr = str, !inputStr.trimmingCharacters(in: .whitespaces).isEmpty else {
            return Decimal(-1)
        }
        let pureStr = inputStr.trimmingCharacters(in: .whitespaces)
        var originDecimal = Decimal(0)
        
        // 步骤2：优先直接转换（解决 "76" 这类整数/简单小数转换失败问题）
        // 2.1 先尝试转 Int（适配纯整数场景，如 "76"、"123"）
        if let intValue = Int(pureStr) {
            originDecimal = Decimal(intValue)
        }
        // 2.2 Int 转换失败，尝试转 Double（适配小数场景，如 "76.45"、"123.456"）
        else if let doubleValue = Double(pureStr) {
            originDecimal = Decimal(doubleValue)
        }
        // 2.3 前两者都失败，用 NumberFormatter 兜底（适配复杂数字格式）
        else {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.locale = Locale(identifier: "en_US")
            numberFormatter.maximumFractionDigits = 10
            numberFormatter.minimumFractionDigits = 0
            
            guard let number = numberFormatter.number(from: pureStr),
                  let formatterDecimal = number as? Decimal else {
                return Decimal(-1)
            }
            originDecimal = formatterDecimal
        }
        
        // 步骤3：将 Decimal 四舍五入，强制保留两位小数
        let roundedDecimal = roundDecimalToTwoPlaces(originDecimal)
        
        return roundedDecimal
    }
    
    /// 辅助方法：将 Decimal 四舍五入保留两位小数（核心高精度处理）
    /// - Parameter decimal: 原始 Decimal 值
    /// - Returns: 保留两位小数的 Decimal（四舍五入）
    private static func roundDecimalToTwoPlaces(_ decimal: Decimal) -> Decimal {
        // 配置舍入模式：四舍五入，保留两位小数（适配你的枚举）
        let roundingMode = NSDecimalNumber.RoundingMode.plain
        var resultDecimal = Decimal(0)
        var originalDecimal = decimal
        
        // 执行舍入操作（指定保留2位小数，无溢出）
        NSDecimalRound(&resultDecimal, &originalDecimal, 2, roundingMode)
        
        return resultDecimal
    }
}
