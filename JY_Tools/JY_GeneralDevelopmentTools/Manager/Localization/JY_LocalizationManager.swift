//
//  JY_JY_LocalizationManager.swift
//  JY_GeneralDevelopmentTools
//
//  Created by JYYQLin on 2025/12/24.
//

import Foundation

// MARK: - 语言枚举（语义化命名 + 扩展解耦显示名称）
/// 多语言枚举（rawValue对应lproj文件夹名称）
public enum Language: String, CaseIterable {
    // 英语系列
    case english = "en"
    case englishAustralia = "en-AU"
    case englishUK = "en-GB"
    case englishCA = "en-CA"
    
    // 法语
    case french = "fr-FR"
    
    // 日语/韩语
    case japanese = "ja-JP"
    case korean = "ko-KR"
    
    // 中文系列
    case chineseSimplified = "zh"
    case chineseTraditional = "zh-Hant"
    case chineseTraditionalHK = "zh-HK"
    case chineseTraditionalTW = "zh-TW"
    
    //  西语系列
    case spanish = "es"
    case portuguesePT = "pt-PT"
    case portugueseBR = "pt-BR"
    
    // MARK: - 扩展：获取语言显示名称（解耦硬编码）
    /// 获取语言的本地化显示名称
    var displayName: String {
        switch self {
        case .english: return "English"
        case .englishAustralia: return "English（Australia）"
        case .englishUK: return "English（UK）"
        case .englishCA: return "English（CA）"
        case .french: return "French"
        case .japanese: return "日语"
        case .korean: return "韩语"
        case .chineseSimplified: return "简体中文"
        case .chineseTraditional: return "繁體中文"
        case .chineseTraditionalHK: return "繁體中文（香港）"
        case .chineseTraditionalTW: return "繁體中文（台湾）"
            
        case .spanish: return "España"
        case .portuguesePT: return "Portugal"
        case .portugueseBR: return "Portugal"
        }
    }
    
    var intValue: Int {
        switch self {
        case .english: return 1
        case .englishAustralia: return 1
        case .englishUK: return 1
        case .englishCA: return 1
            
        case .chineseSimplified: return 2
        case .chineseTraditional: return 2
        case .chineseTraditionalHK: return 2
        case .chineseTraditionalTW: return 2
            
        case .spanish: return 3
            
        case .portuguesePT: return 4
        case .portugueseBR: return 4
            
        case .french: return 1
        case .japanese: return 1
        case .korean: return 1
        }
    }
    
    /// 从原始值安全初始化（兜底返回简体中文）
    static func safeInit(rawValue: String?) -> Language {
        guard let rawValue = rawValue, let language = Language(rawValue: rawValue) else {
            return .chineseSimplified
        }
        return language
    }
}

public extension Notification.Name {
    static let JY_LanguageDidChangeNotification = Notification.Name("JY_LocalizationManager + JY_LanguageDidChangeNotification")
}

// MARK: - 本地化管理单例（核心逻辑封装）
/// 多语言本地化管理工具（单例模式）
public final class JY_LocalizationManager {
    // MARK: - 常量定义（语义化 + 统一管理）
    /// 用户默认值存储Key
    private enum UserDefaultsKey: String {
        case currentLanguage = "JY_Current_Language_Key"
    }
    
    /// 通知名称常量
    public static let languageDidChangeNotification = NSNotification.Name.JY_LanguageDidChangeNotification
    
    // MARK: - 单例（线程安全）
    public static let shared = JY_LocalizationManager()
    private init() {
        // 初始化当前语言（从UserDefaults读取，兜底简体中文）
        let savedRawValue = UserDefaults.standard.string(forKey: UserDefaultsKey.currentLanguage.rawValue)
        currentLanguage = Language.safeInit(rawValue: savedRawValue)
    }
    
    // MARK: - 公开属性
    /// 当前选中的语言（线程安全）
    public private(set) var currentLanguage: Language {
        didSet {
            // 语言变更时自动保存到UserDefaults
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: UserDefaultsKey.currentLanguage.rawValue)
        }
    }
    
    // MARK: - 公开方法
    /// 设置当前语言并发送变更通知
    /// - Parameter language: 目标语言
    public func setCurrentLanguage(_ language: Language) {
        guard currentLanguage != language else { return } // 避免重复设置
        currentLanguage = language
        postLanguageChangeNotification()
    }
    
    /// 发送语言变更通知
    /// - Parameter object: 通知携带的附加对象
    public func postLanguageChangeNotification(object: Any? = nil) {
        NotificationCenter.default.post(
            name: JY_LocalizationManager.languageDidChangeNotification,
            object: object
        )
    }
    
    /// 添加语言变更通知监听
    /// - Parameters:
    ///   - observer: 监听者
    ///   - selector: 回调方法
    ///   - object: 过滤对象
    public static func addLanguageChangeObserver(
        _ observer: Any,
        selector: Selector,
        object: Any? = nil
    ) {
        // 先移除再添加，避免重复监听
        removeLanguageChangeObserver(observer, object: object)
        NotificationCenter.default.addObserver(
            observer,
            selector: selector,
            name: languageDidChangeNotification,
            object: object
        )
    }
    
    /// 移除语言变更通知监听
    /// - Parameters:
    ///   - observer: 监听者
    ///   - object: 过滤对象
    public static func removeLanguageChangeObserver(
        _ observer: Any,
        object: Any? = nil
    ) {
        NotificationCenter.default.removeObserver(
            observer,
            name: languageDidChangeNotification,
            object: object
        )
    }
}

// MARK: - String扩展：本地化字符串获取
public extension String {
    /// 获取本地化字符串
    /// - Parameters:
    ///   - tableName: 本地化表名（默认使用项目名称）
    ///   - language: 指定语言（默认使用当前设置的语言）
    ///   - customLanguageRawValue: 自定义语言rawValue（优先级高于language）
    /// - Returns: 本地化后的字符串
    func localized(
        tableName: String? = nil,
        language: Language? = nil,
        customLanguageRawValue: String? = nil
    ) -> String {
        // 1. 确定最终使用的语言rawValue
        let targetRawValue: String
        if let customRawValue = customLanguageRawValue {
            targetRawValue = customRawValue
        } else {
            let targetLanguage = language ?? JY_LocalizationManager.shared.currentLanguage
            targetRawValue = targetLanguage.rawValue
        }
        
        // 2. 确定本地化表名（兜底项目名称）
        let finalTableName = tableName ?? JY_ProjectTool.getProjectName()
        
        // 3. 安全获取语言对应的Bundle（兜底主Bundle）
        let languageBundle: Bundle = {
            guard let bundlePath = Bundle.main.path(forResource: targetRawValue, ofType: "lproj") else {
                print("⚠️ 未找到\(targetRawValue).lproj文件夹，使用主Bundle")
                return Bundle.main
            }
            guard let bundle = Bundle(path: bundlePath) else {
                print("⚠️ 无法加载\(targetRawValue).lproj对应的Bundle，使用主Bundle")
                return Bundle.main
            }
            return bundle
        }()
        
        // 4. 获取本地化字符串（兜底原字符串）
        return NSLocalizedString(
            self,
            tableName: finalTableName,
            bundle: languageBundle,
            value: self, // 兜底原字符串，避免空值
            comment: ""
        )
    }
}

// MARK: - 使用示例
/*
 // 1. 设置当前语言
 JY_LocalizationManager.shared.setCurrentLanguage(.englishUK)
 
 // 2. 监听语言变更
 JY_LocalizationManager.addLanguageChangeObserver(self, selector: #selector(languageDidChange(_:)))
 
 // 3. 获取本地化字符串
 let hello = "Hello".localized() // 使用当前语言
 let helloFR = "Hello".localized(language: .french) // 指定法语
 let helloCustom = "Hello".localized(customLanguageRawValue: "zh-HK") // 自定义香港繁体
 
 // 4. 获取语言显示名称
 let displayName = Language.chineseSimplified.displayName // 输出"简体中文"
 
 // 5. 移除通知监听
 deinit {
 JY_LocalizationManager.removeLanguageChangeObserver(self)
 }
 */
