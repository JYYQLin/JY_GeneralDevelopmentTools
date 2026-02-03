//
//  JY_DateTool.swift
//  JY_GeneralDevelopmentTools
//
//  Created by JYYQLin on 2025/12/24.
//

import Foundation

/// 日期组件模型（存储Int类型的年月日时分秒）
public struct DateComponentsInt {
    let year: Int?
    let month: Int?
    let day: Int?
    let hour: Int?
    let minute: Int?
    let second: Int?
}

/// 日期处理工具类（全静态方法，无需实例化）
public final class JY_DateTool {
    /// 私有日历实例（统一管理时区，避免重复创建）
    private static let calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone.current // 使用当前时区，避免时区偏移问题
        return cal
    }()
    
    // MARK: 1. 传入年月，返回该月总天数（重点处理2月闰年）
    /// - Parameters:
    ///   - year: 年份（如2025）
    ///   - month: 月份（1-12）
    /// - Returns: 该月天数，非法年月返回0
    static func daysInMonth(year: Int, month: Int) -> Int {
        guard (1...12).contains(month), year > 0 else { return 0 }
        
        // 闰年判断规则：能被4整除且不能被100整除，或能被400整除
        let isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
        
        // 各月份天数映射
        let monthDaysMap: [Int: Int] = [
            1: 31, 2: isLeapYear ? 29 : 28, 3: 31, 4: 30, 5: 31, 6: 30,
            7: 31, 8: 31, 9: 30, 10: 31, 11: 30, 12: 31
        ]
        return monthDaysMap[month] ?? 0
    }
    
    // MARK: 2. 快速返回当前月总天数（修复Int转换警告）
    static func daysInCurrentMonth() -> Int {
        let now = Date()
        // 修复：component返回Int，无需as? Int转换
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        return daysInMonth(year: year, month: month)
    }
    
    // MARK: 3. 日期组件解析（核心方法+重载）
    /// 核心方法：从Date中解析年月日时分秒（Int类型）
    /// - Parameter date: 目标日期
    /// - Returns: 日期组件模型
    static func parseDateComponents(from date: Date) -> DateComponentsInt {
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        return DateComponentsInt(
            year: components.year,
            month: components.month,
            day: components.day,
            hour: components.hour,
            minute: components.minute,
            second: components.second
        )
    }
    
    /// 3.a 快速返回当天的年月日时分秒
    static func parseTodayComponents() -> DateComponentsInt {
        return parseDateComponents(from: Date())
    }
    
    /// 3.b 从时间戳解析年月日时分秒
    /// - Parameter timestamp: 时间戳（秒级，如1735065600）
    /// - Returns: 日期组件模型（时间戳非法返回空值）
    static func parseDateComponents(from timestamp: TimeInterval) -> DateComponentsInt {
        let date = Date(timeIntervalSince1970: timestamp)
        return parseDateComponents(from: date)
    }
    
    /// 3.c 从格式化字符串解析年月日时分秒
    /// - Parameters:
    ///   - dateString: 日期字符串（如"2025-12-24"）
    ///   - format: 日期格式（如"yyyy-MM-dd"）
    /// - Returns: 日期组件模型（解析失败返回空值）
    static func parseDateComponents(from dateString: String, format: String) -> DateComponentsInt {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "zh_CN") // 适配中文环境
        
        guard let date = formatter.date(from: dateString) else {
            return DateComponentsInt(year: nil, month: nil, day: nil, hour: nil, minute: nil, second: nil)
        }
        return parseDateComponents(from: date)
    }
    
    // MARK: 4. 日期差计算（核心方法+重载）
    /// 核心方法：计算两个Date的日期差（仅比较日期，忽略时分秒）
    /// - Parameters:
    ///   - date1: 日期1
    ///   - date2: 日期2
    /// - Returns: 天数差（date1 - date2的结果，正数表示date1在date2之后）
    static func daysBetween(date1: Date, date2: Date) -> Int {
        // 忽略时分秒，只比较年月日
        let startDate = calendar.startOfDay(for: date1)
        let endDate = calendar.startOfDay(for: date2)
        let components = calendar.dateComponents([.day], from: endDate, to: startDate)
        return components.day ?? 0
    }
    
    /// 4.a 计算两个时间戳的日期差
    /// - Parameters:
    ///   - timestamp1: 时间戳1（秒级）
    ///   - timestamp2: 时间戳2（秒级）
    /// - Returns: 天数差
    static func daysBetween(timestamp1: TimeInterval, timestamp2: TimeInterval) -> Int {
        let date1 = Date(timeIntervalSince1970: timestamp1)
        let date2 = Date(timeIntervalSince1970: timestamp2)
        return daysBetween(date1: date1, date2: date2)
    }
    
    /// 4.b 计算两个格式化字符串的日期差
    /// - Parameters:
    ///   - dateStr1: 日期字符串1
    ///   - dateStr2: 日期字符串2
    ///   - format: 日期格式（两个字符串格式需一致）
    /// - Returns: 天数差（解析失败返回0）
    static func daysBetween(dateStr1: String, dateStr2: String, format: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "zh_CN")
        
        guard let date1 = formatter.date(from: dateStr1),
              let date2 = formatter.date(from: dateStr2) else {
            return 0
        }
        return daysBetween(date1: date1, date2: date2)
    }
    
    // MARK: 5. 快速返回当前月剩余天数（修复Int转换警告）
    static func remainingDaysInCurrentMonth(includeToday: Bool) -> Int {
        let now = Date()
        // 修复：component返回Int，无需as? Int转换
        let currentDay = calendar.component(.day, from: now)
        let totalDays = daysInCurrentMonth()
        let remaining = totalDays - currentDay
        return includeToday ? (remaining + 1) : remaining
    }
    
    // MARK: 6. 快速获取前一天的日期
    /// - Parameter date: 基准日期（默认当前日期）
    /// - Returns: 前一天的日期（自动处理1月1日边界）
    static func previousDay(for date: Date = Date()) -> Date {
        return calendar.date(byAdding: .day, value: -1, to: date) ?? date
    }
    
    // MARK: 7. 快速获取后一天的日期
    /// - Parameter date: 基准日期（默认当前日期）
    /// - Returns: 后一天的日期（自动处理12月31日边界）
    static func nextDay(for date: Date = Date()) -> Date {
        return calendar.date(byAdding: .day, value: 1, to: date) ?? date
    }
    
    // MARK: 8. 格式化字符串转时间戳
    /// - Parameters:
    ///   - dateString: 日期字符串
    ///   - format: 日期格式
    /// - Returns: 时间戳（秒级，解析失败返回0）
    static func timestamp(from dateString: String, format: String) -> TimeInterval {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "zh_CN")
        
        guard let date = formatter.date(from: dateString) else {
            return 0
        }
        return date.timeIntervalSince1970
    }
    
    /// 将「年-月」格式的字符串转为Date
    /// - Parameter yearMonthStr: 格式如 "2024-12" 的字符串
    /// - Returns: 转换后的Date（默认当月1日0点），转换失败返回nil
    static func convertYearMonthStringToDate(_ yearMonthStr: String) -> Date? {
        let formatter = DateFormatter()
        // 1. 关键：格式字符串必须和输入完全匹配（yyyy-MM 对应 2024-12）
        formatter.dateFormat = "yyyy-MM"
        // 2. 设置locale为en_US_POSIX（避免系统地区/语言影响格式解析，比如中文环境下的“年/月”格式干扰）
        formatter.locale = Locale(identifier: "zh_CN")
        // 3. 设置时区（可选，建议显式设置，避免时区偏移导致日期错误）
        formatter.timeZone = TimeZone.current
        
        return formatter.date(from: yearMonthStr)
    }
    
    /// 将「yyyy-MM」格式的日期字符串转换为自定义格式的字符串
    /// - Parameters:
    ///   - originalDateString: 原始日期字符串（必须是 yyyy-MM 格式，如 "2024-12"）
    ///   - newFormat: 目标格式（如 "yyyy年MM月"、"MM/yyyy" 等）
    /// - Returns: 转换后的字符串，转换失败返回 nil（如原始字符串格式错误、新格式不合法）
    static func convertYearMonthString(
        originalDateString: String, oldFormat: String = "yyyy-MM",
        toNewFormat newFormat: String
    ) -> String {
        // 1. 第一步：解析原始字符串为 Date（固定解析格式 yyyy-MM）
        let parseFormatter = DateFormatter()
        parseFormatter.dateFormat = oldFormat // 原始字符串的固定格式
        parseFormatter.locale = Locale(identifier: "en_US_POSIX") // 关键：避免地区/语言干扰解析
        parseFormatter.timeZone = TimeZone(identifier: "GMT") // 固定时区，避免偏移
        
        guard let parsedDate = parseFormatter.date(from: originalDateString) else {
            print("转换失败：原始日期字符串格式错误，需为 yyyy-MM 格式（如 2024-12）")
            return originalDateString
        }
        
        // 2. 第二步：将 Date 格式化为新格式的字符串
        let formatFormatter = DateFormatter()
        formatFormatter.dateFormat = newFormat // 自定义新格式
        formatFormatter.locale = Locale(identifier: "zh_CN") // 中文环境建议设为 zh_CN（可选）
        formatFormatter.timeZone = TimeZone(identifier: "GMT") // 和解析时保持时区一致
        
        return formatFormatter.string(from: parsedDate)
    }
    
    // 判断两个日期是否为同一天
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}

// MARK: - 新增：秒数拆分结果模型
/// 存储天、时、分、秒的组件模型
public struct TimeIntervalComponents {
    public let days: Int
    public let hours: Int
    public let minutes: Int
    public let seconds: Int
}

// MARK: 新增方法 1 - 时间戳差值计算
public extension JY_DateTool {
    /// 1.1 传入未来时间戳，返回与当前时间的秒差（若≤当前时间，返回0）
    static func secondsDifference(fromFutureTimestamp timestamp: TimeInterval) -> TimeInterval {
        let currentTimestamp = Date().timeIntervalSince1970
        let difference = timestamp - currentTimestamp
        return max(difference, 0) // 仅返回非负数（未来时间差）
    }
    
    /// 1.2 将秒数拆分为【天、时、分、秒】
    static func splitSecondsIntoComponents(seconds: TimeInterval) -> TimeIntervalComponents {
        let totalSeconds = Int(seconds)
        let days = totalSeconds / 86400 // 24*60*60 = 86400秒/天
        let remainingAfterDays = totalSeconds % 86400
        let hours = remainingAfterDays / 3600 // 60*60 = 3600秒/小时
        let remainingAfterHours = remainingAfterDays % 3600
        let minutes = remainingAfterHours / 60 // 60秒/分钟
        let seconds = remainingAfterHours % 60
        return TimeIntervalComponents(days: days, hours: hours, minutes: minutes, seconds: seconds)
    }
    
    // MARK: 新增方法 2 - 时间戳转格式化/相对时间
    /// 2.1 时间戳转指定格式的字符串
    static func formattedDate(from timestamp: TimeInterval, format: String) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    /// 2.2 时间戳转相对时间（几秒前/几分钟前等，参考市面通用规则）
    static func relativeTime(from timestamp: TimeInterval) -> String {
        let currentTimestamp = Date().timeIntervalSince1970
        let difference = currentTimestamp - timestamp // 差值≥0为过去时间，<0为未来时间
        
        // 时间单位定义（简化版，符合市面通用逻辑）
        let oneMinute: TimeInterval = 60
        let oneHour: TimeInterval = 60 * oneMinute
        let oneDay: TimeInterval = 24 * oneHour
        let oneMonth: TimeInterval = 30 * oneDay // 按30天简化算1个月
        let oneYear: TimeInterval = 12 * oneMonth // 按360天简化算1年
        
        // 未来时间：直接返回格式化时间（yyyy-MM-dd HH:mm）
        guard difference >= 0 else {
            return formattedDate(from: timestamp, format: "yyyy-MM-dd HH:mm")
        }
        
        // 过去时间：按规则返回相对时间
        switch difference {
        case 0..<oneMinute:
            return difference == 0 ? "刚刚" : "\(Int(difference))秒前"
        case oneMinute..<oneHour:
            return "\(Int(difference/oneMinute))分钟前"
        case oneHour..<oneDay:
            return "\(Int(difference/oneHour))小时前"
        case oneDay..<oneMonth:
            return "\(Int(difference/oneDay))天前"
        case oneMonth..<oneYear:
            return "\(Int(difference/oneMonth))个月前"
        default:
            // 超过1年：返回格式化日期（yyyy-MM-dd）
            return formattedDate(from: timestamp, format: "yyyy-MM-dd")
        }
    }
    
    /// 将时间戳（秒级/毫秒级）分离为年、月、日、时、分、秒
     /// - Parameter isMillisecond: 时间戳是否为毫秒级（默认false，即秒级）
     /// - Returns: 元组 (year: 年, month: 月, day: 日, hour: 时, minute: 分, second: 秒)，无效时间戳返回 nil
    static func splitToYMDHMS(seconds time: TimeInterval, isMillisecond: Bool = false) -> (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int)? {
        // 1. 处理时间戳单位：毫秒级转为秒级（TimeInterval 本质是秒）
        let timeInterval = isMillisecond ? (time / 1000) : time
        
        // 2. 过滤无效时间戳（负数时间戳无意义）
        guard timeInterval >= 0 else {
            return nil
        }
        
        // 3. 生成 Date 对象
        let date = Date(timeIntervalSince1970: timeInterval)
        
        // 4. 获取当前时区的日历（避免时区偏移导致的时间误差）
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        // 5. 校验所有时间组件是否存在（避免无效 Date 导致的 nil）
        guard let year = dateComponents.year,
              let month = dateComponents.month,
              let day = dateComponents.day,
              let hour = dateComponents.hour,
              let minute = dateComponents.minute,
              let second = dateComponents.second else {
            return nil
        }
        
        // 6. 返回分离后的年月日时分秒
        return (year, month, day, hour, minute, second)
    }
}

// MARK: - 新增扩展：Int（秒数）
extension Int {
    /// 快速将秒数拆分为【天、时、分、秒】
    func splitIntoTimeComponents() -> TimeIntervalComponents {
        return JY_DateTool.splitSecondsIntoComponents(seconds: TimeInterval(self))
    }
    
    func relativeTime() -> String {
        return TimeInterval(self).relativeTime()
    }
}

// MARK: - 新增扩展：TimeInterval（时间戳/秒数）
extension TimeInterval {
    /// 快速计算与当前时间的秒差（作为未来时间戳）
    func secondsDifferenceFromNow() -> TimeInterval {
        return JY_DateTool.secondsDifference(fromFutureTimestamp: self)
    }
    
    /// 快速将秒数拆分为【天、时、分、秒】
    func splitIntoTimeComponents() -> TimeIntervalComponents {
        return JY_DateTool.splitSecondsIntoComponents(seconds: self)
    }
    
    /// 快速转指定格式字符串
    func formattedDate(format: String) -> String {
        return JY_DateTool.formattedDate(from: self, format: format)
    }
    
    /// 快速转相对时间（几秒前/几分钟前等）
    func relativeTime() -> String {
        return JY_DateTool.relativeTime(from: self)
    }
}


extension JY_DateTool {
    /// 获取当前时间的年、月、日
    /// - Returns: 包含年、月、日的元组 (year: Int, month: Int, day: Int)
    public static func yq_get_current_year_month_day() -> (year: Int, month: Int, day: Int) {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        let day = calendar.component(.day, from: currentDate)
        
        return (year, month, day)
    }
    
    /// 获取当前时间**前一天**的年、月、日（自动处理跨月/跨年场景，如1月1日的前一天是去年12月31日）
    /// - Returns: 包含前一天年、月、日的元组 (year: Int, month: Int, day: Int)
    public static func yq_get_yesterday_year_month_day() -> (year: Int, month: Int, day: Int) {
        let currentDate = Date()
        let calendar = Calendar.current
        
        // 1. 计算当前日期的前一天：给当前日期添加“-1天”的偏移
        // 注：Calendar的date(byAdding:)方法会自动处理跨月/跨年逻辑（如1月1日→12月31日）
        guard let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
            // 极端情况下（如系统时间异常）若计算失败，默认返回当前日期（避免崩溃）
            let fallback = yq_get_current_year_month_day()
            print("计算前一天日期失败，返回当前日期作为 fallback：\(fallback.year)-\(fallback.month)-\(fallback.day)")
            return fallback
        }
        
        // 2. 从“前一天日期”中提取年、月、日
        let year = calendar.component(.year, from: yesterdayDate)
        let month = calendar.component(.month, from: yesterdayDate)
        let day = calendar.component(.day, from: yesterdayDate)
        
        return (year, month, day)
    }
}
