//
//  JY_DeviceTool.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/24.
//

import UIKit

/// JSON处理工具类（iOS开发通用）
final class JY_DeviceTool {
    
    // MARK: - 私有化构造器，禁止实例化
    private init() {}
    
    static func isIPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    static func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

// MARK: - JY_DeviceTool 扩展（快速获取设备信息）
extension JY_DeviceTool {
    /// 快速获取当前设备的JY_DeviceType
    static func currentDeviceType() -> JY_DeviceType {
        return UIDevice.currentDeviceType()
    }
}

// MARK: - UIDevice 扩展（设备尺寸相关计算）
public extension UIDevice {
    /// 获取当前设备的tabBar高度（考虑横竖屏和系统版本）
    func tabBarHeight() -> CGFloat {
        let deviceType = self.deviceType
        let isLandscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
        
        if #available(iOS 26.0, *) {
            return isLandscape ? deviceType.tabBarHeightLandscapeiOS26Later : deviceType.tabBarHeightPortraitiOS26Later
        } else {
            return isLandscape ? deviceType.tabBarHeightLandscape : deviceType.tabBarHeightPortrait
        }
    }
    
    /// 获取当前设备的tabBar安全高度（全面屏返回15，非全面屏返回0）
    func tabBarSafeHeight() -> CGFloat {
        return deviceType.isFullScreen ? 15 : 0
    }
    
    /// 获取当前设备的导航栏高度（考虑横竖屏和系统版本）
    func navBarHeight() -> CGFloat {
        let deviceType = self.deviceType
        let isLandscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
        
        if #available(iOS 26.0, *) {
            return isLandscape ? deviceType.navBarHeightLandscapeiOS26Later : deviceType.navBarHeightPortraitiOS26Later
        } else {
            return isLandscape ? deviceType.navBarHeightLandscape : deviceType.navBarHeightPortrait
        }
    }
    
    /// 获取当前设备的状态栏高度（考虑横竖屏和系统版本）
    func statusBarHeight() -> CGFloat {
        let deviceType = self.deviceType
        let isLandscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
        
        if #available(iOS 26.0, *) {
            return isLandscape ? deviceType.statusBarHeightLandscapeiOS26Later : deviceType.statusBarHeightPortraitiOS26Later
        } else {
            return isLandscape ? deviceType.statusBarHeightLandscape : deviceType.statusBarHeightPortrait
        }
    }
    
    /// 获取导航栏最大Y值（导航栏高度 + 状态栏高度）
    func navigationBarMaxY() -> CGFloat {
        return navBarHeight() + statusBarHeight()
    }
}


extension UIDevice {
    // 设备信息扩展
    var isJailbroken: Bool { JY_ProjectTool.isJailbroken() }
    var isSimulator: Bool { JY_ProjectTool.isSimulator() }
}

// MARK: - 设备参数模型（替代原元组，增加类型安全）
public struct JY_DeviceType: Equatable {
    /// 屏幕宽（竖屏，pt）
    public let width: CGFloat
    /// 屏幕高（竖屏，pt）
    public let height: CGFloat
    
    /// 竖屏状态栏高度（iOS 26前）
    public let statusBarHeightPortrait: CGFloat
    /// 竖屏导航栏高度（iOS 26前）
    public let navBarHeightPortrait: CGFloat
    /// 横屏状态栏高度（iOS 26前）
    public let statusBarHeightLandscape: CGFloat
    /// 横屏导航栏高度（iOS 26前）
    public let navBarHeightLandscape: CGFloat
    
    /// 竖屏状态栏高度（iOS 26及以后）
    public let statusBarHeightPortraitiOS26Later: CGFloat
    /// 竖屏导航栏高度（iOS 26及以后）
    public let navBarHeightPortraitiOS26Later: CGFloat
    /// 横屏状态栏高度（iOS 26及以后）
    public let statusBarHeightLandscapeiOS26Later: CGFloat
    /// 横屏导航栏高度（iOS 26及以后）
    public let navBarHeightLandscapeiOS26Later: CGFloat
    
    /// 竖屏标签栏高度（iOS 26前）
    public let tabBarHeightPortrait: CGFloat
    /// 横屏标签栏高度（iOS 26前）
    public let tabBarHeightLandscape: CGFloat
    
    /// 竖屏标签栏高度（iOS 26及以后）
    public let tabBarHeightPortraitiOS26Later: CGFloat
    /// 横屏标签栏高度（iOS 26及以后）
    public let tabBarHeightLandscapeiOS26Later: CGFloat
    
    /// 屏幕缩放比
    public let screenScale: CGFloat
    /// 是否全面屏
    public let isFullScreen: Bool
    /// 是否灵动岛设备
    public let isDynamicIsland: Bool
    /// 设备名称（如iPhone 11）
    public let deviceName: String
    /// 设备原始型号列表（如["iPhone12,1"]）
    public let modelIdentifiers: [String]
    /// 是否平板
    public let isPad: Bool
    
    // MARK: - 便捷获取当前系统版本对应的实际高度
    /// 当前系统竖屏状态栏高度
    var currentStatusBarHeightPortrait: CGFloat {
        if #available(iOS 26.0, *) {
            return statusBarHeightPortraitiOS26Later
        } else {
            return statusBarHeightPortrait
        }
    }
    
    /// 当前系统竖屏导航栏高度
    var currentNavBarHeightPortrait: CGFloat {
        if #available(iOS 26.0, *) {
            return navBarHeightPortraitiOS26Later
        } else {
            return navBarHeightPortrait
        }
    }
}

// MARK: - UIDevice扩展（设备型号/参数匹配）
public extension UIDevice {
    // MARK: - 缓存（避免重复计算）
    private static var cachedModelIdentifier: String?
    private static var cachedDeviceType: JY_DeviceType?
    
    // MARK: - 核心方法
    /// 获取设备原始型号标识符（如iPhone12,1）
    static func modelIdentifier() -> String {
        if let cached = cachedModelIdentifier {
            return cached
        }
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        // 缓存结果
        cachedModelIdentifier = identifier
        return identifier
    }
    
    /// 获取当前设备的参数模型（带缓存）
    static func currentDeviceType() -> JY_DeviceType {
        // 优先返回缓存
        if let cached = cachedDeviceType {
            return cached
        }
        
        let modelId = modelIdentifier()
        let supportedDevices = Self.supportedDevices()
        
        // 1. 先按设备型号精准匹配
        if let matchedDevice = supportedDevices.first(where: { $0.modelIdentifiers.contains(modelId) }) {
            cachedDeviceType = matchedDevice
            return matchedDevice
        }
        
        // 2. 型号匹配失败，按屏幕尺寸+缩放比匹配（允许±0.1精度误差）
        let screenSize = UIScreen.main.bounds
        let (screenWidth, screenHeight) = screenSize.width < screenSize.height ?
            (screenSize.width, screenSize.height) : (screenSize.height, screenSize.width)
        let screenScale = UIScreen.main.scale
        let nativeScale = UIScreen.main.nativeScale
        
        let sizeMatchedDevice = supportedDevices.first { device in
            let widthMatch = abs(device.width - screenWidth) < 0.1
            let heightMatch = abs(device.height - screenHeight) < 0.1
            let scaleMatch = abs(device.screenScale - screenScale) < 0.1 || abs(device.screenScale - nativeScale) < 0.1
            return widthMatch && heightMatch && scaleMatch
        }
        
        // 3. 尺寸匹配失败，返回iPhone 11默认参数
        let finalDevice = sizeMatchedDevice ?? defaultIPhone11DeviceType()
        cachedDeviceType = finalDevice
        return finalDevice
    }
    
    // MARK: - 私有辅助方法
    /// 默认iPhone 11设备参数
    private static func defaultIPhone11DeviceType() -> JY_DeviceType {
        JY_DeviceType(
            width: 414,
            height: 896,
            statusBarHeightPortrait: 48,
            navBarHeightPortrait: 44,
            statusBarHeightLandscape: 0,
            navBarHeightLandscape: 44,
            statusBarHeightPortraitiOS26Later: 48,
            navBarHeightPortraitiOS26Later: 54,
            statusBarHeightLandscapeiOS26Later: 24,
            navBarHeightLandscapeiOS26Later: 54,
            tabBarHeightPortrait: 83,
            tabBarHeightLandscape: 70,
            tabBarHeightPortraitiOS26Later: 83,
            tabBarHeightLandscapeiOS26Later: 64,
            screenScale: 2,
            isFullScreen: true,
            isDynamicIsland: false,
            deviceName: "iPhone 11",
            modelIdentifiers: ["iPhone12,1"],
            isPad: false
        )
    }
    
    /// 预设支持的设备列表（静态常量，仅初始化一次）
    private static func supportedDevices() -> [JY_DeviceType] {
        [
            // 非全面屏 - 4寸设备
            JY_DeviceType(
                width: 320,
                height: 568,
                statusBarHeightPortrait: 20,
                navBarHeightPortrait: 44,
                statusBarHeightLandscape: 0,
                navBarHeightLandscape: 32,
                statusBarHeightPortraitiOS26Later: 20,
                navBarHeightPortraitiOS26Later: 44,
                statusBarHeightLandscapeiOS26Later: 0,
                navBarHeightLandscapeiOS26Later: 32,
                tabBarHeightPortrait: 49,
                tabBarHeightLandscape: 32,
                tabBarHeightPortraitiOS26Later: 49,
                tabBarHeightLandscapeiOS26Later: 32,
                screenScale: 2,
                isFullScreen: false,
                isDynamicIsland: false,
                deviceName: "iPhone SE 1st",
                modelIdentifiers: ["iPhone8,4"],
                isPad: false
            ),
            // 非全面屏 - 4.7寸设备（iPhone 6s/7/8/SE2/SE3）
            JY_DeviceType(
                width: 375,
                height: 667,
                statusBarHeightPortrait: 20,
                navBarHeightPortrait: 44,
                statusBarHeightLandscape: 0,
                navBarHeightLandscape: 32,
                statusBarHeightPortraitiOS26Later: 20,
                navBarHeightPortraitiOS26Later: 44,
                statusBarHeightLandscapeiOS26Later: 0,
                navBarHeightLandscapeiOS26Later: 32,
                tabBarHeightPortrait: 49,
                tabBarHeightLandscape: 32,
                tabBarHeightPortraitiOS26Later: 49,
                tabBarHeightLandscapeiOS26Later: 32,
                screenScale: 2,
                isFullScreen: false,
                isDynamicIsland: false,
                deviceName: "iPhone 6s/7/8/SE2/SE3",
                modelIdentifiers: ["iPhone8,1", "iPhone9,1", "iPhone9,3", "iPhone10,1", "iPhone10,4", "iPhone12,8", "iPhone14,6"],
                isPad: false
            ),
            // 非全面屏 - 5.5寸设备
            JY_DeviceType(
                width: 414,
                height: 736,
                statusBarHeightPortrait: 20,
                navBarHeightPortrait: 44,
                statusBarHeightLandscape: 0,
                navBarHeightLandscape: 44,
                statusBarHeightPortraitiOS26Later: 20,
                navBarHeightPortraitiOS26Later: 44,
                statusBarHeightLandscapeiOS26Later: 0,
                navBarHeightLandscapeiOS26Later: 44,
                tabBarHeightPortrait: 49,
                tabBarHeightLandscape: 49,
                tabBarHeightPortraitiOS26Later: 49,
                tabBarHeightLandscapeiOS26Later: 49,
                screenScale: 3,
                isFullScreen: false,
                isDynamicIsland: false,
                deviceName: "iPhone 6s Plus/7 Plus/8 Plus",
                modelIdentifiers: ["iPhone8,2", "iPhone9,2", "iPhone9,4", "iPhone10,2", "iPhone10,5"],
                isPad: false
            ),
            // 全面屏 - 5.42寸（iPhone 12/13 mini）
            JY_DeviceType(
                width: 375,
                height: 812,
                statusBarHeightPortrait: 50,
                navBarHeightPortrait: 44,
                statusBarHeightLandscape: 0,
                navBarHeightLandscape: 32,
                statusBarHeightPortraitiOS26Later: 50,
                navBarHeightPortraitiOS26Later: 54,
                statusBarHeightLandscapeiOS26Later: 24,
                navBarHeightLandscapeiOS26Later: 54,
                tabBarHeightPortrait: 83,
                tabBarHeightLandscape: 53,
                tabBarHeightPortraitiOS26Later: 83,
                tabBarHeightLandscapeiOS26Later: 64,
                screenScale: 3,
                isFullScreen: true,
                isDynamicIsland: false,
                deviceName: "iPhone 12/13 mini",
                modelIdentifiers: ["iPhone13,1", "iPhone14,4"],
                isPad: false
            ),
            // 全面屏 - 5.85寸（iPhone X/XS/11 Pro）
            JY_DeviceType(
                width: 375,
                height: 812,
                statusBarHeightPortrait: 44,
                navBarHeightPortrait: 44,
                statusBarHeightLandscape: 0,
                navBarHeightLandscape: 44,
                statusBarHeightPortraitiOS26Later: 44,
                navBarHeightPortraitiOS26Later: 54,
                statusBarHeightLandscapeiOS26Later: 24,
                navBarHeightLandscapeiOS26Later: 54,
                tabBarHeightPortrait: 83,
                tabBarHeightLandscape: 53,
                tabBarHeightPortraitiOS26Later: 83,
                tabBarHeightLandscapeiOS26Later: 64,
                screenScale: 3,
                isFullScreen: true,
                isDynamicIsland: false,
                deviceName: "iPhone X/XS/11 Pro",
                modelIdentifiers: ["iPhone10,3", "iPhone10,6", "iPhone11,2", "iPhone12,3"],
                isPad: false
            ),
            // 全面屏 - 6.1寸 LCD（iPhone XR/11）
            JY_DeviceType(
                width: 414,
                height: 896,
                statusBarHeightPortrait: 48,
                navBarHeightPortrait: 44,
                statusBarHeightLandscape: 0,
                navBarHeightLandscape: 44,
                statusBarHeightPortraitiOS26Later: 48,
                navBarHeightPortraitiOS26Later: 54,
                statusBarHeightLandscapeiOS26Later: 24,
                navBarHeightLandscapeiOS26Later: 54,
                tabBarHeightPortrait: 83,
                tabBarHeightLandscape: 70,
                tabBarHeightPortraitiOS26Later: 83,
                tabBarHeightLandscapeiOS26Later: 64,
                screenScale: 2,
                isFullScreen: true,
                isDynamicIsland: false,
                deviceName: "iPhone XR/11",
                modelIdentifiers: ["iPhone11,8", "iPhone12,1"],
                isPad: false
            ),
            // 全面屏 - 6.1寸 OLED（iPhone 12/13/14）
            JY_DeviceType(
                width: 390,
                height: 844,
                statusBarHeightPortrait: 47,
                navBarHeightPortrait: 44,
                statusBarHeightLandscape: 0,
                navBarHeightLandscape: 44,
                statusBarHeightPortraitiOS26Later: 47,
                navBarHeightPortraitiOS26Later: 54,
                statusBarHeightLandscapeiOS26Later: 24,
                navBarHeightLandscapeiOS26Later: 54,
                tabBarHeightPortrait: 83,
                tabBarHeightLandscape: 53,
                tabBarHeightPortraitiOS26Later: 83,
                tabBarHeightLandscapeiOS26Later: 64,
                screenScale: 3,
                isFullScreen: true,
                isDynamicIsland: false,
                deviceName: "iPhone 12/13/14",
                modelIdentifiers: ["iPhone13,2", "iPhone13,3", "iPhone14,5", "iPhone14,2", "iPhone14,7", "iPhone17,5"],
                isPad: false
            ),
            // 全面屏 - 6.5寸（iPhone XS Max/11 Pro Max）
            JY_DeviceType(
                width: 414,
                height: 896,
                statusBarHeightPortrait: 44,
                navBarHeightPortrait: 44,
                statusBarHeightLandscape: 0,
                navBarHeightLandscape: 44,
                statusBarHeightPortraitiOS26Later: 44,
                navBarHeightPortraitiOS26Later: 54,
                statusBarHeightLandscapeiOS26Later: 24,
                navBarHeightLandscapeiOS26Later: 54,
                tabBarHeightPortrait: 83,
                tabBarHeightLandscape: 70,
                tabBarHeightPortraitiOS26Later: 83,
                tabBarHeightLandscapeiOS26Later: 64,
                screenScale: 3,
                isFullScreen: true,
                isDynamicIsland: false,
                deviceName: "iPhone XS Max/11 Pro Max",
                modelIdentifiers: ["iPhone11,6", "iPhone11,4", "iPhone12,5"],
                isPad: false
            ),
            // 全面屏 - 6.7寸（iPhone 12/13 Pro Max/14 Plus）
            JY_DeviceType(
                width: 428,
                height: 926,
                statusBarHeightPortrait: 47,
                navBarHeightPortrait: 44,
                statusBarHeightLandscape: 0,
                navBarHeightLandscape: 44,
                statusBarHeightPortraitiOS26Later: 47,
                navBarHeightPortraitiOS26Later: 54,
                statusBarHeightLandscapeiOS26Later: 24,
                navBarHeightLandscapeiOS26Later: 54,
                tabBarHeightPortrait: 83,
                tabBarHeightLandscape: 70,
                tabBarHeightPortraitiOS26Later: 83,
                tabBarHeightLandscapeiOS26Later: 64,
                screenScale: 3,
                isFullScreen: true,
                isDynamicIsland: false,
                deviceName: "iPhone 12/13 Pro Max/14 Plus",
                modelIdentifiers: ["iPhone13,4", "iPhone14,3", "iPhone14,8"],
                isPad: false
            ),
            // 灵动岛 - 6.1寸（iPhone 14/15/16 Pro）
            JY_DeviceType(
                width: 393,
                height: 852,
                statusBarHeightPortrait: 53.6666666,
                navBarHeightPortrait: 44,
                statusBarHeightLandscape: 0,
                navBarHeightLandscape: 44,
                statusBarHeightPortraitiOS26Later: 59,
                navBarHeightPortraitiOS26Later: 54,
                statusBarHeightLandscapeiOS26Later: 24,
                navBarHeightLandscapeiOS26Later: 54,
                tabBarHeightPortrait: 83,
                tabBarHeightLandscape: 53,
                tabBarHeightPortraitiOS26Later: 83,
                tabBarHeightLandscapeiOS26Later: 64,
                screenScale: 3,
                isFullScreen: true,
                isDynamicIsland: true,
                deviceName: "iPhone 14/15/16 Pro",
                modelIdentifiers: ["iPhone15,2", "iPhone16,1", "iPhone17,1"],
                isPad: false
            ),
            // 灵动岛 - 6.7寸（iPhone 14/15/16 Pro Max/Plus）
            JY_DeviceType(
                width: 430,
                height: 932,
                statusBarHeightPortrait: 53.6666666,
                navBarHeightPortrait: 44,
                statusBarHeightLandscape: 0,
                navBarHeightLandscape: 44,
                statusBarHeightPortraitiOS26Later: 59,
                navBarHeightPortraitiOS26Later: 54,
                statusBarHeightLandscapeiOS26Later: 24,
                navBarHeightLandscapeiOS26Later: 54,
                tabBarHeightPortrait: 83,
                tabBarHeightLandscape: 70,
                tabBarHeightPortraitiOS26Later: 83,
                tabBarHeightLandscapeiOS26Later: 64,
                screenScale: 3,
                isFullScreen: true,
                isDynamicIsland: true,
                deviceName: "iPhone 14/15/16 Pro Max/Plus",
                modelIdentifiers: ["iPhone15,3", "iPhone15,5", "iPhone16,2", "iPhone17,2"],
                isPad: false
            ),
            // 灵动岛 - iPhone 16 Pro系列
            JY_DeviceType(
                width: 402,
                height: 874,
                statusBarHeightPortrait: 56.3333333,
                navBarHeightPortrait: 44,
                statusBarHeightLandscape: 0,
                navBarHeightLandscape: 44,
                statusBarHeightPortraitiOS26Later: 62,
                navBarHeightPortraitiOS26Later: 54,
                statusBarHeightLandscapeiOS26Later: 24,
                navBarHeightLandscapeiOS26Later: 54,
                tabBarHeightPortrait: 83,
                tabBarHeightLandscape: 53,
                tabBarHeightPortraitiOS26Later: 83,
                tabBarHeightLandscapeiOS26Later: 64,
                screenScale: 3,
                isFullScreen: true,
                isDynamicIsland: true,
                deviceName: "iPhone 16 Pro / iPhone 17 / iPhone 17 Pro",
                modelIdentifiers: ["iPhone17,3"],
                isPad: false
            ),
            
            // 灵动岛 - iPhone 16 Pro Max系列
            JY_DeviceType(
                width: 440,
                height: 956,
                statusBarHeightPortrait: 56.3333333,
                navBarHeightPortrait: 44,
                statusBarHeightLandscape: 0,
                navBarHeightLandscape: 44,
                statusBarHeightPortraitiOS26Later: 62,
                navBarHeightPortraitiOS26Later: 54,
                statusBarHeightLandscapeiOS26Later: 24,
                navBarHeightLandscapeiOS26Later: 54,
                tabBarHeightPortrait: 83,
                tabBarHeightLandscape: 70,
                tabBarHeightPortraitiOS26Later: 83,
                tabBarHeightLandscapeiOS26Later: 64,
                screenScale: 3,
                isFullScreen: true,
                isDynamicIsland: true,
                deviceName: "iPhone 16 Pro Max / iPhone 17 Pro Max",
                modelIdentifiers: ["iPhone17,4"],
                isPad: false
            ),
            
            // 灵动岛 - iPhone 17 Air系列
            JY_DeviceType(
                width: 420,
                height: 912,
                statusBarHeightPortrait: 56.3333333,
                navBarHeightPortrait: 44,
                statusBarHeightLandscape: 0,
                navBarHeightLandscape: 44,
                statusBarHeightPortraitiOS26Later: 68,
                navBarHeightPortraitiOS26Later: 54,
                statusBarHeightLandscapeiOS26Later: 24,
                navBarHeightLandscapeiOS26Later: 54,
                tabBarHeightPortrait: 83,
                tabBarHeightLandscape: 70,
                tabBarHeightPortraitiOS26Later: 83,
                tabBarHeightLandscapeiOS26Later: 64,
                screenScale: 3,
                isFullScreen: true,
                isDynamicIsland: true,
                deviceName: "iPhone 17 Air",
                modelIdentifiers: ["iPhone17,4"],
                isPad: false
            ),
            
            // 平板 - 非全面屏（iPad 5-9代/Air2/Mini4-5/Pro 9.7/10.5/12.9 1-2代）
            JY_DeviceType(
                width: 768,
                height: 1024,
                statusBarHeightPortrait: 20,
                navBarHeightPortrait: 50,
                statusBarHeightLandscape: 20,
                navBarHeightLandscape: 50,
                statusBarHeightPortraitiOS26Later: 20,
                navBarHeightPortraitiOS26Later: 50,
                statusBarHeightLandscapeiOS26Later: 20,
                navBarHeightLandscapeiOS26Later: 50,
                tabBarHeightPortrait: 50,
                tabBarHeightLandscape: 50,
                tabBarHeightPortraitiOS26Later: 50,
                tabBarHeightLandscapeiOS26Later: 50,
                screenScale: 2,
                isFullScreen: false,
                isDynamicIsland: false,
                deviceName: "iPad 非全面屏系列",
                modelIdentifiers: ["iPad6,11", "iPad6,12", "iPad7,5", "iPad7,6", "iPad7,11", "iPad7,12", "iPad11,6", "iPad11,7", "iPad12,1", "iPad12,2", "iPad5,3", "iPad5,4", "iPad11,3", "iPad11,4", "iPad5,1", "iPad5,2", "iPad6,3", "iPad6,4", "iPad7,3", "iPad7,4", "iPad6,7", "iPad6,8", "iPad7,1", "iPad7,2"],
                isPad: true
            ),
            
            // 平板 - 全面屏（iPad Mini6/Air4-5/Pro 11/12.9 3-6代）
            JY_DeviceType(
                width: 834,
                height: 1194,
                statusBarHeightPortrait: 24,
                navBarHeightPortrait: 50,
                statusBarHeightLandscape: 24,
                navBarHeightLandscape: 50,
                statusBarHeightPortraitiOS26Later: 24,
                navBarHeightPortraitiOS26Later: 50,
                statusBarHeightLandscapeiOS26Later: 24,
                navBarHeightLandscapeiOS26Later: 50,
                tabBarHeightPortrait: 65,
                tabBarHeightLandscape: 65,
                tabBarHeightPortraitiOS26Later: 65,
                tabBarHeightLandscapeiOS26Later: 65,
                screenScale: 2,
                isFullScreen: true,
                isDynamicIsland: false,
                deviceName: "iPad 全面屏系列",
                modelIdentifiers: ["iPad14,1", "iPad14,2", "iPad13,18", "iPad13,19", "iPad13,1", "iPad13,2", "iPad13,16", "iPad13,17", "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4", "iPad8,9", "iPad8,10", "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7", "iPad14,3", "iPad14,4", "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8", "iPad8,11", "iPad8,12", "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11", "iPad14,5", "iPad14,6"],
                isPad: true
            ),
            
            // 模拟器适配
//            JY_DeviceType(
//                width: 390,
//                height: 844,
//                statusBarHeightPortrait: 47,
//                navBarHeightPortrait: 44,
//                statusBarHeightLandscape: 0,
//                navBarHeightLandscape: 44,
//                statusBarHeightPortraitiOS26Later: 47,
//                navBarHeightPortraitiOS26Later: 54,
//                statusBarHeightLandscapeiOS26Later: 24,
//                navBarHeightLandscapeiOS26Later: 54,
//                tabBarHeightPortrait: 83,
//                tabBarHeightLandscape: 53,
//                tabBarHeightPortraitiOS26Later: 83,
//                tabBarHeightLandscapeiOS26Later: 64,
//                screenScale: 3,
//                isFullScreen: true,
//                isDynamicIsland: false,
//                deviceName: "Simulator",
//                modelIdentifiers: ["i386", "x86_64", "arm64"],
//                isPad: false
//            )
            
            JY_DeviceType(
                width: 402,
                height: 874,
                statusBarHeightPortrait: 56.3333333,
                navBarHeightPortrait: 44,
                statusBarHeightLandscape: 0,
                navBarHeightLandscape: 44,
                statusBarHeightPortraitiOS26Later: 62,
                navBarHeightPortraitiOS26Later: 54,
                statusBarHeightLandscapeiOS26Later: 24,
                navBarHeightLandscapeiOS26Later: 54,
                tabBarHeightPortrait: 83,
                tabBarHeightLandscape: 53,
                tabBarHeightPortraitiOS26Later: 83,
                tabBarHeightLandscapeiOS26Later: 64,
                screenScale: 3,
                isFullScreen: true,
                isDynamicIsland: true,
                deviceName: "iPhone 16 Pro / iPhone 17 / iPhone 17 Pro",
                modelIdentifiers: ["模拟器"],
                isPad: false
            ),
        ]
    }
}

// MARK: - 便捷调用
public extension UIDevice {
    /// 当前设备参数（便捷属性）
    var deviceType: JY_DeviceType {
        return UIDevice.currentDeviceType()
    }
    
    /// 当前设备是否是平板
    var isPad: Bool {
        return deviceType.isPad
    }
    
    /// 当前设备是否是全面屏
    var isFullScreen: Bool {
        return deviceType.isFullScreen
    }
    
    /// 当前设备是否是灵动岛
    var isDynamicIsland: Bool {
        return deviceType.isDynamicIsland
    }
}



/**
 
 private static func supportedDevices() -> [JY_DeviceType] {
     [
         // MARK: - 非全面屏 iPhone（全拆分）
         // 4寸 - iPhone SE 1st（原本已独立）
         JY_DeviceType(
             width: 320,
             height: 568,
             statusBarHeightPortrait: 20,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 32,
             statusBarHeightPortraitiOS26Later: 20,
             navBarHeightPortraitiOS26Later: 44,
             statusBarHeightLandscapeiOS26Later: 0,
             navBarHeightLandscapeiOS26Later: 32,
             tabBarHeightPortrait: 49,
             tabBarHeightLandscape: 32,
             tabBarHeightPortraitiOS26Later: 49,
             tabBarHeightLandscapeiOS26Later: 32,
             screenScale: 2,
             isFullScreen: false,
             isDynamicIsland: false,
             deviceName: "iPhone SE 1st",
             modelIdentifiers: ["iPhone8,4"],
             isPad: false
         ),
         // 4.7寸 - iPhone 6s
         JY_DeviceType(
             width: 375,
             height: 667,
             statusBarHeightPortrait: 20,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 32,
             statusBarHeightPortraitiOS26Later: 20,
             navBarHeightPortraitiOS26Later: 44,
             statusBarHeightLandscapeiOS26Later: 0,
             navBarHeightLandscapeiOS26Later: 32,
             tabBarHeightPortrait: 49,
             tabBarHeightLandscape: 32,
             tabBarHeightPortraitiOS26Later: 49,
             tabBarHeightLandscapeiOS26Later: 32,
             screenScale: 2,
             isFullScreen: false,
             isDynamicIsland: false,
             deviceName: "iPhone 6s",
             modelIdentifiers: ["iPhone8,1"],
             isPad: false
         ),
         // 4.7寸 - iPhone 7
         JY_DeviceType(
             width: 375,
             height: 667,
             statusBarHeightPortrait: 20,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 32,
             statusBarHeightPortraitiOS26Later: 20,
             navBarHeightPortraitiOS26Later: 44,
             statusBarHeightLandscapeiOS26Later: 0,
             navBarHeightLandscapeiOS26Later: 32,
             tabBarHeightPortrait: 49,
             tabBarHeightLandscape: 32,
             tabBarHeightPortraitiOS26Later: 49,
             tabBarHeightLandscapeiOS26Later: 32,
             screenScale: 2,
             isFullScreen: false,
             isDynamicIsland: false,
             deviceName: "iPhone 7",
             modelIdentifiers: ["iPhone9,1", "iPhone9,3"],
             isPad: false
         ),
         // 4.7寸 - iPhone 8
         JY_DeviceType(
             width: 375,
             height: 667,
             statusBarHeightPortrait: 20,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 32,
             statusBarHeightPortraitiOS26Later: 20,
             navBarHeightPortraitiOS26Later: 44,
             statusBarHeightLandscapeiOS26Later: 0,
             navBarHeightLandscapeiOS26Later: 32,
             tabBarHeightPortrait: 49,
             tabBarHeightLandscape: 32,
             tabBarHeightPortraitiOS26Later: 49,
             tabBarHeightLandscapeiOS26Later: 32,
             screenScale: 2,
             isFullScreen: false,
             isDynamicIsland: false,
             deviceName: "iPhone 8",
             modelIdentifiers: ["iPhone10,1", "iPhone10,4"],
             isPad: false
         ),
         // 4.7寸 - iPhone SE2
         JY_DeviceType(
             width: 375,
             height: 667,
             statusBarHeightPortrait: 20,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 32,
             statusBarHeightPortraitiOS26Later: 20,
             navBarHeightPortraitiOS26Later: 44,
             statusBarHeightLandscapeiOS26Later: 0,
             navBarHeightLandscapeiOS26Later: 32,
             tabBarHeightPortrait: 49,
             tabBarHeightLandscape: 32,
             tabBarHeightPortraitiOS26Later: 49,
             tabBarHeightLandscapeiOS26Later: 32,
             screenScale: 2,
             isFullScreen: false,
             isDynamicIsland: false,
             deviceName: "iPhone SE2",
             modelIdentifiers: ["iPhone12,8"],
             isPad: false
         ),
         // 4.7寸 - iPhone SE3
         JY_DeviceType(
             width: 375,
             height: 667,
             statusBarHeightPortrait: 20,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 32,
             statusBarHeightPortraitiOS26Later: 20,
             navBarHeightPortraitiOS26Later: 44,
             statusBarHeightLandscapeiOS26Later: 0,
             navBarHeightLandscapeiOS26Later: 32,
             tabBarHeightPortrait: 49,
             tabBarHeightLandscape: 32,
             tabBarHeightPortraitiOS26Later: 49,
             tabBarHeightLandscapeiOS26Later: 32,
             screenScale: 2,
             isFullScreen: false,
             isDynamicIsland: false,
             deviceName: "iPhone SE3",
             modelIdentifiers: ["iPhone14,6"],
             isPad: false
         ),
         // 5.5寸 - iPhone 6s Plus
         JY_DeviceType(
             width: 414,
             height: 736,
             statusBarHeightPortrait: 20,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 20,
             navBarHeightPortraitiOS26Later: 44,
             statusBarHeightLandscapeiOS26Later: 0,
             navBarHeightLandscapeiOS26Later: 44,
             tabBarHeightPortrait: 49,
             tabBarHeightLandscape: 49,
             tabBarHeightPortraitiOS26Later: 49,
             tabBarHeightLandscapeiOS26Later: 49,
             screenScale: 3,
             isFullScreen: false,
             isDynamicIsland: false,
             deviceName: "iPhone 6s Plus",
             modelIdentifiers: ["iPhone8,2"],
             isPad: false
         ),
         // 5.5寸 - iPhone 7 Plus
         JY_DeviceType(
             width: 414,
             height: 736,
             statusBarHeightPortrait: 20,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 20,
             navBarHeightPortraitiOS26Later: 44,
             statusBarHeightLandscapeiOS26Later: 0,
             navBarHeightLandscapeiOS26Later: 44,
             tabBarHeightPortrait: 49,
             tabBarHeightLandscape: 49,
             tabBarHeightPortraitiOS26Later: 49,
             tabBarHeightLandscapeiOS26Later: 49,
             screenScale: 3,
             isFullScreen: false,
             isDynamicIsland: false,
             deviceName: "iPhone 7 Plus",
             modelIdentifiers: ["iPhone9,2", "iPhone9,4"],
             isPad: false
         ),
         // 5.5寸 - iPhone 8 Plus
         JY_DeviceType(
             width: 414,
             height: 736,
             statusBarHeightPortrait: 20,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 20,
             navBarHeightPortraitiOS26Later: 44,
             statusBarHeightLandscapeiOS26Later: 0,
             navBarHeightLandscapeiOS26Later: 44,
             tabBarHeightPortrait: 49,
             tabBarHeightLandscape: 49,
             tabBarHeightPortraitiOS26Later: 49,
             tabBarHeightLandscapeiOS26Later: 49,
             screenScale: 3,
             isFullScreen: false,
             isDynamicIsland: false,
             deviceName: "iPhone 8 Plus",
             modelIdentifiers: ["iPhone10,2", "iPhone10,5"],
             isPad: false
         ),

         // MARK: - 全面屏 iPhone（无灵动岛，全拆分）
         // 5.42寸 - iPhone 12 mini
         JY_DeviceType(
             width: 375,
             height: 812,
             statusBarHeightPortrait: 50,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 32,
             statusBarHeightPortraitiOS26Later: 50,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 53,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: false,
             deviceName: "iPhone 12 mini",
             modelIdentifiers: ["iPhone13,1"],
             isPad: false
         ),
         // 5.42寸 - iPhone 13 mini
         JY_DeviceType(
             width: 375,
             height: 812,
             statusBarHeightPortrait: 50,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 32,
             statusBarHeightPortraitiOS26Later: 50,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 53,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: false,
             deviceName: "iPhone 13 mini",
             modelIdentifiers: ["iPhone14,4"],
             isPad: false
         ),
         // 5.85寸 - iPhone X
         JY_DeviceType(
             width: 375,
             height: 812,
             statusBarHeightPortrait: 44,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 44,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 53,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: false,
             deviceName: "iPhone X",
             modelIdentifiers: ["iPhone10,3", "iPhone10,6"],
             isPad: false
         ),
         // 5.85寸 - iPhone XS
         JY_DeviceType(
             width: 375,
             height: 812,
             statusBarHeightPortrait: 44,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 44,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 53,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: false,
             deviceName: "iPhone XS",
             modelIdentifiers: ["iPhone11,2"],
             isPad: false
         ),
         // 5.85寸 - iPhone 11 Pro
         JY_DeviceType(
             width: 375,
             height: 812,
             statusBarHeightPortrait: 44,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 44,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 53,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: false,
             deviceName: "iPhone 11 Pro",
             modelIdentifiers: ["iPhone12,3"],
             isPad: false
         ),
         // 6.1寸 LCD - iPhone XR
         JY_DeviceType(
             width: 414,
             height: 896,
             statusBarHeightPortrait: 48,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 48,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 70,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 2,
             isFullScreen: true,
             isDynamicIsland: false,
             deviceName: "iPhone XR",
             modelIdentifiers: ["iPhone11,8"],
             isPad: false
         ),
         // 6.1寸 LCD - iPhone 11
         JY_DeviceType(
             width: 414,
             height: 896,
             statusBarHeightPortrait: 48,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 48,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 70,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 2,
             isFullScreen: true,
             isDynamicIsland: false,
             deviceName: "iPhone 11",
             modelIdentifiers: ["iPhone12,1"],
             isPad: false
         ),
         // 6.1寸 OLED - iPhone 12
         JY_DeviceType(
             width: 390,
             height: 844,
             statusBarHeightPortrait: 47,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 47,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 53,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: false,
             deviceName: "iPhone 12",
             modelIdentifiers: ["iPhone13,2", "iPhone13,3"],
             isPad: false
         ),
         // 6.1寸 OLED - iPhone 13
         JY_DeviceType(
             width: 390,
             height: 844,
             statusBarHeightPortrait: 47,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 47,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 53,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: false,
             deviceName: "iPhone 13",
             modelIdentifiers: ["iPhone14,5", "iPhone14,2"],
             isPad: false
         ),
         // 6.1寸 OLED - iPhone 14
         JY_DeviceType(
             width: 390,
             height: 844,
             statusBarHeightPortrait: 47,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 47,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 53,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: false,
             deviceName: "iPhone 14",
             modelIdentifiers: ["iPhone14,7", "iPhone17,5"],
             isPad: false
         ),
         // 6.5寸 - iPhone XS Max
         JY_DeviceType(
             width: 414,
             height: 896,
             statusBarHeightPortrait: 44,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 44,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 70,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: false,
             deviceName: "iPhone XS Max",
             modelIdentifiers: ["iPhone11,6"],
             isPad: false
         ),
         // 6.5寸 - iPhone 11 Pro Max
         JY_DeviceType(
             width: 414,
             height: 896,
             statusBarHeightPortrait: 44,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 44,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 70,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: false,
             deviceName: "iPhone 11 Pro Max",
             modelIdentifiers: ["iPhone11,4", "iPhone12,5"],
             isPad: false
         ),
         // 6.7寸 - iPhone 12 Pro Max
         JY_DeviceType(
             width: 428,
             height: 926,
             statusBarHeightPortrait: 47,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 47,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 70,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: false,
             deviceName: "iPhone 12 Pro Max",
             modelIdentifiers: ["iPhone13,4"],
             isPad: false
         ),
         // 6.7寸 - iPhone 13 Pro Max
         JY_DeviceType(
             width: 428,
             height: 926,
             statusBarHeightPortrait: 47,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 47,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 70,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: false,
             deviceName: "iPhone 13 Pro Max",
             modelIdentifiers: ["iPhone14,3"],
             isPad: false
         ),
         // 6.7寸 - iPhone 14 Plus
         JY_DeviceType(
             width: 428,
             height: 926,
             statusBarHeightPortrait: 47,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 47,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 70,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: false,
             deviceName: "iPhone 14 Plus",
             modelIdentifiers: ["iPhone14,8"],
             isPad: false
         ),

         // MARK: - 灵动岛 iPhone（全拆分）
         // 6.1寸 - iPhone 14 Pro
         JY_DeviceType(
             width: 393,
             height: 852,
             statusBarHeightPortrait: 53.6666666,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 59,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 53,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: true,
             deviceName: "iPhone 14 Pro",
             modelIdentifiers: ["iPhone15,2"],
             isPad: false
         ),
         // 6.1寸 - iPhone 15 Pro
         JY_DeviceType(
             width: 393,
             height: 852,
             statusBarHeightPortrait: 53.6666666,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 59,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 53,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: true,
             deviceName: "iPhone 15 Pro",
             modelIdentifiers: ["iPhone16,1"],
             isPad: false
         ),
         // 6.1寸 - iPhone 16 Pro
         JY_DeviceType(
             width: 393,
             height: 852,
             statusBarHeightPortrait: 53.6666666,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 59,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 53,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: true,
             deviceName: "iPhone 16 Pro",
             modelIdentifiers: ["iPhone17,1"],
             isPad: false
         ),
         // 6.7寸 - iPhone 14 Pro Max
         JY_DeviceType(
             width: 430,
             height: 932,
             statusBarHeightPortrait: 53.6666666,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 59,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 70,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: true,
             deviceName: "iPhone 14 Pro Max",
             modelIdentifiers: ["iPhone15,3"],
             isPad: false
         ),
         // 6.7寸 - iPhone 15 Pro Max
         JY_DeviceType(
             width: 430,
             height: 932,
             statusBarHeightPortrait: 53.6666666,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 59,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 70,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: true,
             deviceName: "iPhone 15 Pro Max",
             modelIdentifiers: ["iPhone15,5"],
             isPad: false
         ),
         // 6.7寸 - iPhone 16 Pro Max
         JY_DeviceType(
             width: 430,
             height: 932,
             statusBarHeightPortrait: 53.6666666,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 59,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 70,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: true,
             deviceName: "iPhone 16 Pro Max",
             modelIdentifiers: ["iPhone16,2"],
             isPad: false
         ),
         // 6.2寸 - iPhone 16 Pro（新尺寸）
         JY_DeviceType(
             width: 402,
             height: 874,
             statusBarHeightPortrait: 56.3333333,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 62,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 53,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: true,
             deviceName: "iPhone 16 Pro",
             modelIdentifiers: ["iPhone17,3"],
             isPad: false
         ),
         // 6.9寸 - iPhone 16 Pro Max（新尺寸）
         JY_DeviceType(
             width: 440,
             height: 956,
             statusBarHeightPortrait: 56.3333333,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 62,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 70,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: true,
             deviceName: "iPhone 16 Pro Max",
             modelIdentifiers: ["iPhone17,4"],
             isPad: false
         ),
         // 6.8寸 - iPhone 17
         JY_DeviceType(
             width: 402,
             height: 874,
             statusBarHeightPortrait: 56.3333333,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 62,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 53,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: true,
             deviceName: "iPhone 17",
             modelIdentifiers: ["iPhone18,1"],
             isPad: false
         ),
         // 6.8寸 - iPhone 17 Pro
         JY_DeviceType(
             width: 402,
             height: 874,
             statusBarHeightPortrait: 56.3333333,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 62,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 53,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: true,
             deviceName: "iPhone 17 Pro",
             modelIdentifiers: ["iPhone18,2"],
             isPad: false
         ),
         // 6.9寸 - iPhone 17 Pro Max
         JY_DeviceType(
             width: 440,
             height: 956,
             statusBarHeightPortrait: 56.3333333,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 62,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 70,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: true,
             deviceName: "iPhone 17 Pro Max",
             modelIdentifiers: ["iPhone18,3"],
             isPad: false
         ),
         // 6.7寸 - iPhone 17 Air
         JY_DeviceType(
             width: 420,
             height: 912,
             statusBarHeightPortrait: 56.3333333,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 68,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 70,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: true,
             deviceName: "iPhone 17 Air",
             modelIdentifiers: ["iPhone18,4"],
             isPad: false
         ),

         // MARK: - iPad 系列（暂保留合集，无细分需求）
         // 非全面屏 iPad
         JY_DeviceType(
             width: 768,
             height: 1024,
             statusBarHeightPortrait: 20,
             navBarHeightPortrait: 50,
             statusBarHeightLandscape: 20,
             navBarHeightLandscape: 50,
             statusBarHeightPortraitiOS26Later: 20,
             navBarHeightPortraitiOS26Later: 50,
             statusBarHeightLandscapeiOS26Later: 20,
             navBarHeightLandscapeiOS26Later: 50,
             tabBarHeightPortrait: 50,
             tabBarHeightLandscape: 50,
             tabBarHeightPortraitiOS26Later: 50,
             tabBarHeightLandscapeiOS26Later: 50,
             screenScale: 2,
             isFullScreen: false,
             isDynamicIsland: false,
             deviceName: "iPad 非全面屏系列",
             modelIdentifiers: ["iPad6,11", "iPad6,12", "iPad7,5", "iPad7,6", "iPad7,11", "iPad7,12", "iPad11,6", "iPad11,7", "iPad12,1", "iPad12,2", "iPad5,3", "iPad5,4", "iPad11,3", "iPad11,4", "iPad5,1", "iPad5,2", "iPad6,3", "iPad6,4", "iPad7,3", "iPad7,4", "iPad6,7", "iPad6,8", "iPad7,1", "iPad7,2"],
             isPad: true
         ),
         // 全面屏 iPad
         JY_DeviceType(
             width: 834,
             height: 1194,
             statusBarHeightPortrait: 24,
             navBarHeightPortrait: 50,
             statusBarHeightLandscape: 24,
             navBarHeightLandscape: 50,
             statusBarHeightPortraitiOS26Later: 24,
             navBarHeightPortraitiOS26Later: 50,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 50,
             tabBarHeightPortrait: 65,
             tabBarHeightLandscape: 65,
             tabBarHeightPortraitiOS26Later: 65,
             tabBarHeightLandscapeiOS26Later: 65,
             screenScale: 2,
             isFullScreen: true,
             isDynamicIsland: false,
             deviceName: "iPad 全面屏系列",
             modelIdentifiers: ["iPad14,1", "iPad14,2", "iPad13,18", "iPad13,19", "iPad13,1", "iPad13,2", "iPad13,16", "iPad13,17", "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4", "iPad8,9", "iPad8,10", "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7", "iPad14,3", "iPad14,4", "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8", "iPad8,11", "iPad8,12", "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11", "iPad14,5", "iPad14,6"],
             isPad: true
         ),
         // 模拟器
         JY_DeviceType(
             width: 390,
             height: 844,
             statusBarHeightPortrait: 47,
             navBarHeightPortrait: 44,
             statusBarHeightLandscape: 0,
             navBarHeightLandscape: 44,
             statusBarHeightPortraitiOS26Later: 47,
             navBarHeightPortraitiOS26Later: 54,
             statusBarHeightLandscapeiOS26Later: 24,
             navBarHeightLandscapeiOS26Later: 54,
             tabBarHeightPortrait: 83,
             tabBarHeightLandscape: 53,
             tabBarHeightPortraitiOS26Later: 83,
             tabBarHeightLandscapeiOS26Later: 64,
             screenScale: 3,
             isFullScreen: true,
             isDynamicIsland: false,
             deviceName: "Simulator",
             modelIdentifiers: ["i386", "x86_64", "arm64"],
             isPad: false
         )
     ]
 }
 */
