//
//  JY_ProjectTool.swift
//  JY_GeneralDevelopmentTools
//
//  Created by JYYQLin on 2025/12/24.
//

import Foundation

/// App信息工具类（获取项目名称、版本号、构建版本等）
public final class JY_ProjectTool {
    
    
    private static let firstLaunchKey = JY_ProjectTool.getProjectName() + "JY_ProjectTool_FirstLaunchKey"
    private static let installTimeKey = JY_ProjectTool.getProjectName() + "JY_ProjectTool_InstallTimeKey"
    private static let lastVersionKey = JY_ProjectTool.getProjectName() + "JY_ProjectTool_LastVersionKey"
    
    private static let userDefaults = UserDefaults.standard
    
    /// 私有获取Info.plist字典的方法（统一容错）
    private static var infoDictionary: [String: Any]? {
        return Bundle.main.infoDictionary
    }
    
    // MARK: 1. 获取当前项目名称（优先显示名称，无则取bundle名称）
    /// - Returns: 项目名称（空则返回"Unknown App"）
    static func getAppName() -> String {
        // CFBundleDisplayName：App显示名称（用户看到的）；CFBundleName：项目bundle名称
        let displayName = infoDictionary?["CFBundleDisplayName"] as? String
        return displayName ?? getProjectName()
    }
    
    static func getProjectName() -> String {
        // CFBundleDisplayName：App显示名称（用户看到的）；CFBundleName：项目bundle名称
        let bundleName = infoDictionary?["CFBundleName"] as? String
        return bundleName ?? "Unknown App"
    }
    
    /// 获取当前BundleID
    static func getBundleIDdentifier() -> String {
        guard let bundleIdentifier = Bundle.main.infoDictionary!["CFBundleIdentifier"] as? String else {return "命名空间错误"}
        return bundleIdentifier
    }
    
    // MARK: 2. 获取当前项目版本号（CFBundleShortVersionString）
    /// - Returns: 版本号（如"1.0.1"，空则返回"0.0.0"）
    static func getAppVersion() -> String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String
        return version ?? "0.0.0"
    }
    
    // MARK: 3. 将版本号转为Int类型（适配语义化版本号，如1.0.1 → 10001）
    /// 转换规则：
    /// - 拆分版本号为【主版本.次版本.修订版】，不足补0
    /// - 主版本×10000 + 次版本×100 + 修订版（如1.2 → 10200，1.0.1 → 10001）
    /// - 非标准版本号返回0
    /// - Returns: 版本号对应的Int值
    static func appVersionToInt() -> Int {
        let versionStr = getAppVersion()
        // 拆分版本号（按点分割）
        let versionComponents = versionStr.components(separatedBy: ".")
            .compactMap { Int($0) } // 过滤非数字部分
        
        // 补零到3位（主、次、修订）
        let major = versionComponents.count > 0 ? versionComponents[0] : 0
        let minor = versionComponents.count > 1 ? versionComponents[1] : 0
        let patch = versionComponents.count > 2 ? versionComponents[2] : 0
        
        // 防止版本号过大导致Int溢出（限制主版本≤99，次/修订≤99）
        guard major <= 99, minor <= 99, patch <= 99 else {
            return 0
        }
        return major * 10000 + minor * 100 + patch
    }
    
    // MARK: 4. 获取当前项目的构建版本（CFBundleVersion）
    /// - Returns: 构建版本（如"12"，空则返回"0"）
    static func getBuildVersion() -> String {
        let build = infoDictionary?["CFBundleVersion"] as? String
        return build ?? "0"
    }
    
    // MARK: 5. 快速获取版本+构建版本组合字符串（格式：1.0.1（12））
    /// - Returns: 组合字符串（如"1.0.1（12）"，异常则返回"0.0.0（0）"）
    static func getVersionAndBuildString() -> String {
        let version = getAppVersion()
        let build = getBuildVersion()
        return "\(version)（\(build)）"
    }
    
    /// 6. Bundle ID（应用唯一标识，如com.xxx.jizhangzhu）
    static func getBundleID() -> String {
        Bundle.main.bundleIdentifier ?? "unknown.bundle.id"
    }
    
    /// 7. Documents目录路径（文件存储核心路径）
    static func getDocumentsPath() -> String {
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
    }
    
}

public extension JY_ProjectTool {
    /// 1. 是否是调试版（Debug）
    static func isDebugMode() -> Bool {
#if DEBUG
        return true
#else
        return false
#endif
    }
    
    /// 2. 是否是TestFlight安装（非App Store正式版）
    static func isTestFlightVersion() -> Bool {
        let receiptURL = Bundle.main.appStoreReceiptURL
        return receiptURL?.path.contains("sandboxReceipt") ?? false
    }
    
    /// 3. 是否是App Store正式版
    static func isAppStoreVersion() -> Bool {
        !isDebugMode() && !isTestFlightVersion() && !isJailbroken()
    }
    
    /// 4. 是否是模拟器（适配调试）
    static func isSimulator() -> Bool {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }
    
    /// 5. 设备是否越狱（安全校验常用）
    static func isJailbroken() -> Bool {
        // 简单校验：存在越狱特征文件/可访问系统目录
        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/private/var/lib/cydia",
            "/private/var/stash",
            "/private/var/mobile/Library/SBSettings/Themes"
        ]
        for path in jailbreakPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    /// 6. 系统版本（如17.0）
    //    static func getSystemVersion() -> String {
    //        UIDevice.current.systemVersion
    //    }
    
}

// MARK: - 三、App生命周期（首次启动/安装/更新）
public extension JY_ProjectTool {
    /// 1. 是否是App首次启动（冷启动，卸载重装后重置）
    static func isFirstLaunch() -> Bool {
        guard !userDefaults.bool(forKey: firstLaunchKey) else { return false }
        userDefaults.set(true, forKey: firstLaunchKey)
        userDefaults.set(Date().timeIntervalSince1970, forKey: installTimeKey) // 记录安装时间
        userDefaults.set(getAppVersion(), forKey: lastVersionKey) // 记录首次安装版本
        userDefaults.synchronize()
        return true
    }
    
    /// 2. 获取App安装时间（秒级时间戳，首次启动时记录）
    static func getInstallTime() -> TimeInterval {
        userDefaults.double(forKey: installTimeKey)
    }
    
    /// 3. 是否是版本更新后首次启动（如从1.0.0升级到1.0.1）
    static func isFirstLaunchAfterUpdate() -> Bool {
        let lastVersion = userDefaults.string(forKey: lastVersionKey) ?? ""
        let currentVersion = getAppVersion()
        guard lastVersion != currentVersion else { return false }
        userDefaults.set(currentVersion, forKey: lastVersionKey)
        userDefaults.synchronize()
        return true
    }
    
}

// MARK: - 四、版本工具（扩展）和 系统设置
public extension JY_ProjectTool {
    /// 对比当前版本是否低于目标版本（如当前1.0.0 < 1.0.1 → true）
    /// - Parameter targetVersion: 目标版本（如"1.0.1"）
    /// - Returns: 是否低于目标版本
    static func isCurrentVersionLowerThan(_ targetVersion: String) -> Bool {
        let currentInt = appVersionToInt()
        // 目标版本转Int
        let targetComponents = targetVersion.components(separatedBy: ".")
            .compactMap { Int($0) }
        let targetMajor = targetComponents.count > 0 ? targetComponents[0] : 0
        let targetMinor = targetComponents.count > 1 ? targetComponents[1] : 0
        let targetPatch = targetComponents.count > 2 ? targetComponents[2] : 0
        let targetInt = targetMajor * 10000 + targetMinor * 100 + targetPatch
        return currentInt < targetInt
    }
    
    /// 1. 当前App语言（如zh-Hans、en）
    static func getAppLanguage() -> String {
        // 优先取App的首选语言（Bundle层面，最贴合App实际使用语言）
        if let bundleLang = Bundle.main.preferredLocalizations.first {
            return bundleLang
        }
        
        // 兜底：取系统语言（iOS13+可用的languageCode）
        if let systemLangCode = Locale.current.languageCode {
            // 补充：将简单语言码（如zh）转为完整码（zh-Hans），适配常见场景
            switch systemLangCode {
            case "zh":
                return "zh-Hans" // 默认简体中文
            case "en":
                return "en"
            default:
                return systemLangCode // 其他语言直接返回（如ja、ko等）
            }
        }
        
        // 最终兜底
        return "zh-Hans"
    }
    
    /// 2. 获取当前地区（如CN、US）
    /// - 兼容iOS 13+：改用regionCode（iOS13+可用），放弃iOS16+的Locale.current.region
    static func getRegion() -> String {
        // Locale.current.regionCode是iOS13+原生支持的API
        return Locale.current.regionCode ?? "CN"
    }
}

// MARK: - 便捷扩展（可选，快速调用）
public extension Bundle {
    // 基础信息
    var appName: String { JY_ProjectTool.getAppName() }
    var appVersion: String { JY_ProjectTool.getAppVersion() }
    var buildVersion: String { JY_ProjectTool.getBuildVersion() }
    var bundleID: String { JY_ProjectTool.getBundleID() }
    var versionAndBuild: String { JY_ProjectTool.getVersionAndBuildString() }
    var documentsPath: String { JY_ProjectTool.getDocumentsPath() }
    
    // 环境判断
    var isDebug: Bool { JY_ProjectTool.isDebugMode() }
    var isTestFlight: Bool { JY_ProjectTool.isTestFlightVersion() }
    var isAppStore: Bool { JY_ProjectTool.isAppStoreVersion() }
}
