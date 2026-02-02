//
//  JY_String.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/24.
//

import UIKit

//  MARK: 字符串提取
extension String {
    /// 提取URL中最后一个斜杠后的部分
    /// - Returns: 最后一个路径组件，如果没有斜杠则返回原始字符串
    func lastPathComponent() -> String {
        // 处理空字符串
        guard !isEmpty else { return "" }
        
        // 使用Foundation的URL类处理标准URL格式
        if let url = URL(string: self) {
            return url.lastPathComponent
        }
        
        // 手动处理非标准URL格式（例如缺少协议的路径）
        let components = split(separator: "/").map(String.init)
        return components.last ?? self
    }
    
    /// 提取URL中文件扩展名（如果有）
    /// - Returns: 文件扩展名（不带点），如果没有则返回空字符串
    func pathExtension() -> String {
        // 处理空字符串
        guard !isEmpty else { return "" }
        
        // 使用Foundation的URL类处理标准URL格式
        if let url = URL(string: self) {
            return url.pathExtension
        }
        
        // 手动处理非标准URL格式
        let lastComponent = lastPathComponent()
        let extComponents = lastComponent.split(separator: ".").map(String.init)
        return extComponents.count > 1 ? extComponents.last! : ""
    }
}

//  MARK: 手机号脱敏
extension String {
    /// 手机号脱敏：中间四位替换为****（适配11位手机号，非11位返回原字符串）
    /// - Parameter filterNonDigit: 是否过滤非数字字符（默认true，如处理"138-1234-5678"这类格式）
    /// - Returns: 脱敏后的手机号字符串
    func maskMobileNumber(filterNonDigit: Bool = true) -> String {
        // 步骤1：预处理 - 过滤非数字字符（可选）
        let pureMobile = filterNonDigit ? self.filter { $0.isNumber } : self
        
        // 步骤2：校验是否为11位纯数字手机号
        guard pureMobile.count == 11 else {
            return self // 非11位返回原字符串（也可根据需求返回空/提示）
        }
        
        // 步骤3：截取前3位 + **** + 后4位
        let startIndex = pureMobile.startIndex
        let prefix = pureMobile[startIndex..<pureMobile.index(startIndex, offsetBy: 3)]
        let suffix = pureMobile[pureMobile.index(startIndex, offsetBy: 7)..<pureMobile.endIndex]
        
        return "\(prefix)****\(suffix)"
    }
    
    /// 【进阶版】正则表达式实现（支持更灵活的匹配）
    func maskMobileByRegex() -> String {
        // 正则匹配11位手机号（前3位+任意4位+后4位）
        let regex = try! NSRegularExpression(pattern: "(\\d{3})\\d{4}(\\d{4})", options: .caseInsensitive)
        let range = NSRange(location: 0, length: self.utf16.count)
        
        // 替换中间4位为****
        return regex.stringByReplacingMatches(
            in: self,
            range: range,
            withTemplate: "$1****$2"
        )
    }
}


import UIKit
import Foundation

// MARK: - String 核心扩展
extension String {
    // MARK: 1. 高亮指定文字数组，生成富文本
    /**
     高亮指定文字数组，生成带颜色的富文本
     - Parameters:
       - highlightTexts: 需要高亮的文字数组（空数组则返回全正常色）
       - normalColor: 正常文字颜色
       - highlightColor: 高亮文字颜色
     - Returns: 带高亮效果的 NSAttributedString
     - Note: 支持重复高亮文字，自动匹配所有出现的位置
     */
    func attributedStringWithHighlight(
        highlightTexts: [String],
        normalColor: UIColor,
        highlightColor: UIColor
    ) -> NSAttributedString {
        // 初始化富文本，默认正常颜色
        let attributedStr = NSMutableAttributedString(string: self)
        attributedStr.addAttribute(
            .foregroundColor,
            value: normalColor,
            range: NSRange(location: 0, length: self.count)
        )
        
        // 空高亮数组，直接返回
        guard !highlightTexts.isEmpty else { return attributedStr }
        
        // 遍历高亮文字，设置对应颜色
        for text in highlightTexts {
            guard !text.isEmpty else { continue }
            // 转换 Swift Range 为 NSRange，匹配所有出现的位置
            let nsRangeArray = self.ranges(of: text).map { NSRange($0, in: self) }
            nsRangeArray.forEach { range in
                guard range.location != NSNotFound else { return }
                attributedStr.addAttribute(
                    .foregroundColor,
                    value: highlightColor,
                    range: range
                )
            }
        }
        
        return attributedStr
    }
    
    // MARK: 2. 设置行间距，生成富文本
    /**
     设置字符串行间距，生成富文本
     - Parameter lineSpacing: 行间距（单位：pt）
     - Returns: 带指定行间距的 NSAttributedString
     */
    func attributedStringWithLineSpacing(_ lineSpacing: CGFloat) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineBreakMode = .byTruncatingTail // 默认换行模式
        
        return NSMutableAttributedString(
            string: self,
            attributes: [.paragraphStyle: paragraphStyle]
        )
    }
    
    // MARK: 3. 快速设置下划线/中划线，生成富文本
    /**
     设置下划线/中划线（删除线）样式
     - Parameters:
       - style: 线条样式（如单下划线、双下划线，默认单下划线）
       - color: 线条颜色（默认文字颜色）
       - isStrikethrough: true=中划线（删除线），false=下划线（默认）
     - Returns: 带线条样式的 NSAttributedString
     */
    func attributedStringWithLine(
        style: NSUnderlineStyle = .single,
        color: UIColor? = nil,
        isStrikethrough: Bool = false
    ) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            isStrikethrough ? .strikethroughStyle : .underlineStyle: style.rawValue,
            isStrikethrough ? .strikethroughColor : .underlineColor: color ?? UIColor.black
        ]
        return NSMutableAttributedString(string: self, attributes: attributes)
    }
    
    // MARK: 4. 从指定第一个字符开始截取指定长度
    /**
     从第一个匹配的字符开始截取指定长度
     - Parameters:
       - startChar: 起始字符（找不到则返回 nil）
       - length: 要截取的长度
     - Returns: 截取后的字符串（nil=未找到起始字符/参数非法）
     */
    func substring(fromFirst startChar: Character, length: Int) -> String? {
        // 边界校验
        guard length > 0, !isEmpty else { return nil }
        // 找到第一个匹配字符的索引
        guard let startIndex = self.firstIndex(of: startChar) else { return nil }
        
        // 计算结束索引：剩余长度不足则取到末尾
        let endIndex = self.index(
            startIndex,
            offsetBy: length,
            limitedBy: self.endIndex
        ) ?? self.endIndex
        
        return String(self[startIndex..<endIndex])
    }
    
    // MARK: 5. 指定位置替换字符串
    /**
     从指定位置替换指定长度的字符串
     - Parameters:
       - start: 替换起始位置（从0开始，越界则返回原字符串）
       - length: 要替换的长度（越界则取到字符串末尾）
       - replacement: 替换后的文字
     - Returns: 替换后的字符串
     */
    func replace(at start: Int, length: Int, with replacement: String) -> String {
        // 边界校验：起始位置越界，返回原字符串
        guard start >= 0, start < self.count else { return self }
        
        let startIndex = self.index(self.startIndex, offsetBy: start)
        // 计算结束位置：避免越界
        let endIndex = self.index(
            startIndex,
            offsetBy: length,
            limitedBy: self.endIndex
        ) ?? self.endIndex
        
        var mutableStr = self
        mutableStr.replaceSubrange(startIndex..<endIndex, with: replacement)
        return mutableStr
    }
    
    // MARK: 6. 手机号脱敏（中间4位替换为****）
    /**
     手机号脱敏，中间4位替换为****
     - Parameter filterNonDigit: 是否过滤非数字字符（默认true，处理"138-1234-5678"）
     - Returns: 脱敏后的手机号（非11位数字则返回原字符串）
     */
    func phoneNumberDesensitization(filterNonDigit: Bool = true) -> String {
        // 过滤非数字字符
        let pureNumber = filterNonDigit ? self.filter { $0.isNumber } : self
        // 校验是否为11位手机号
        guard pureNumber.count == 11, pureNumber.allSatisfy({ $0.isNumber }) else {
            return self // 非11位数字，返回原字符串
        }
        // 替换第4-7位为****
        return pureNumber.replace(at: 3, length: 4, with: "****")
    }
    
    // MARK: 7. 格式校验：身份证/手机号/邮箱
    /// 判断是否为有效手机号（简单校验：11位数字，开头13/14/15/17/18/19）
    var isPhoneNumberValid: Bool {
        let phoneRegex = "^1[345789]\\d{9}$"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: self.filter { $0.isNumber })
    }
    
    /// 判断是否为有效邮箱
    var isEmailValid: Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    /// 判断是否为有效身份证（简单校验：18位，最后一位可X/x）
    var isIDCardValid: Bool {
        let idRegex = "^[1-9]\\d{5}(19|20)\\d{2}((0[1-9])|(1[0-2]))((0[1-9])|([12]\\d)|(3[01]))\\d{3}([0-9Xx])$"
        return NSPredicate(format: "SELF MATCHES %@", idRegex).evaluate(with: self)
    }
    
    // MARK: 辅助方法 - 匹配所有子串的Range
    private func ranges(of substring: String) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var startIndex = self.startIndex
        
        while let range = self.range(of: substring, range: startIndex..<self.endIndex) {
            ranges.append(range)
            startIndex = range.upperBound
        }
        return ranges
    }
}

// MARK: - NSAttributedString 核心扩展
extension NSAttributedString {
    // MARK: 额外1. 快速修改行间距
    /**
     修改富文本的行间距
     - Parameter lineSpacing: 新的行间距
     - Returns: 修改后的 NSAttributedString
     */
    func withLineSpacing(_ lineSpacing: CGFloat) -> NSAttributedString {
        let mutableAttributed = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = NSMutableParagraphStyle()
        // 保留原有段落样式，仅修改行间距
        if let originalStyle = mutableAttributed.attribute(
            .paragraphStyle,
            at: 0,
            effectiveRange: nil
        ) as? NSParagraphStyle {
            paragraphStyle.setParagraphStyle(originalStyle)
        }
        paragraphStyle.lineSpacing = lineSpacing
        mutableAttributed.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: self.length)
        )
        return mutableAttributed
    }
    
    // MARK: 额外2. 快速修改下划线/中划线
    /**
     修改富文本的下划线/中划线样式
     - Parameters:
       - style: 线条样式
       - color: 线条颜色
       - isStrikethrough: true=中划线，false=下划线
     - Returns: 修改后的 NSAttributedString
     */
    func withLine(
        style: NSUnderlineStyle = .single,
        color: UIColor? = nil,
        isStrikethrough: Bool = false
    ) -> NSAttributedString {
        let mutableAttributed = NSMutableAttributedString(attributedString: self)
        let lineKey = isStrikethrough ? NSAttributedString.Key.strikethroughStyle : .underlineStyle
        let colorKey = isStrikethrough ? NSAttributedString.Key.strikethroughColor : .underlineColor
        
        mutableAttributed.addAttribute(
            lineKey,
            value: style.rawValue,
            range: NSRange(location: 0, length: self.length)
        )
        if let color = color {
            mutableAttributed.addAttribute(
                colorKey,
                value: color,
                range: NSRange(location: 0, length: self.length)
            )
        }
        return mutableAttributed
    }
    
    // MARK: 额外3. 快速修改字体
    /**
     修改富文本的字体
     - Parameter font: 新字体
     - Returns: 修改后的 NSAttributedString
     */
    func withFont(_ font: UIFont) -> NSAttributedString {
        let mutableAttributed = NSMutableAttributedString(attributedString: self)
        mutableAttributed.addAttribute(
            .font,
            value: font,
            range: NSRange(location: 0, length: self.length)
        )
        return mutableAttributed
    }
    
    // MARK: 额外4. 快速修改字体颜色
    /**
     修改富文本的字体颜色
     - Parameter color: 新颜色
     - Returns: 修改后的 NSAttributedString
     */
    func withTextColor(_ color: UIColor) -> NSAttributedString {
        let mutableAttributed = NSMutableAttributedString(attributedString: self)
        mutableAttributed.addAttribute(
            .foregroundColor,
            value: color,
            range: NSRange(location: 0, length: self.length)
        )
        return mutableAttributed
    }
}

extension String {
    /// 计算文字尺寸（适配单行/多行，自动处理像素取整）
    /// - Parameters:
    ///   - font: 文字字体（必填，包含字号+字体样式，默认系统字体17号）
    ///   - maxWidth: 最大宽度（默认无限大，即单行；设置具体值则自动换行）
    ///   - maxHeight: 最大高度（默认无限大，限制高度时文字会截断）
    ///   - lineBreakMode: 换行模式（默认.byTruncatingTail，仅限制尺寸时生效）
    /// - Returns: 文字实际占用的CGSize（宽度/高度均为向上取整，避免像素偏差）
    func calculateTextSize(
        font: UIFont = .systemFont(ofSize: 17),
        maxWidth: CGFloat = .greatestFiniteMagnitude,
        maxHeight: CGFloat = .greatestFiniteMagnitude,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail
    ) -> CGSize {
        // 空字符串直接返回0尺寸
        guard !isEmpty else { return .zero }
        
        // 1. 构建段落样式（核心修复：lineBreakMode属于NSParagraphStyle）
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = lineBreakMode // 设置换行模式
        paragraphStyle.lineSpacing = 0 // 重置行间距，避免默认行间距影响计算
        
        // 2. 构建文字属性字典（将段落样式加入属性）
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle // 正确设置换行模式
        ]
        
        // 3. 计算文字边界矩形（核心API，适配多行/行高）
        let boundingRect = self.boundingRect(
            with: CGSize(width: maxWidth, height: maxHeight),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        
        // 4. 向上取整（避免小数像素导致布局错位，UI布局需整数像素）
        let size = CGSize(
            width: ceil(boundingRect.width),
            height: ceil(boundingRect.height)
        )
        
        return size
    }
    
    // MARK: 便捷重载（仅传字体，单行计算）
    /// 快捷计算单行文字尺寸（仅需传入字体）
    func calculateSingleLineSize(font: UIFont) -> CGSize {
        return calculateTextSize(font: font, maxWidth: .greatestFiniteMagnitude)
    }
}
