//
//  JY_DeviceTool + UUID.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/25.
//

import UIKit

public extension JY_DeviceTool {
    /*
     无授权需求 → 用 IDFV（同一开发者 App 共享）
     
     1. 同一开发者的所有 App，在同一设备上的 IDFV 完全相同；
     2. 用户卸载该开发者的所有 App 后，重装会重置；
     3. 无需用户授权。
     */
    static func getIDFV() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}


import AdSupport
import AppTrackingTransparency

public extension JY_DeviceTool {
    /**
     需跨 App 标识（广告 / 归因）→ 用 IDFA（需用户授权）；
     
     申请授权（需在Info.plist添加NSUserTrackingUsageDescription）
     
     1. 同一设备上所有 App 的 IDFA 相同；
     2. 用户可在「设置 - 隐私 - 广告」中重置 / 关闭（开启 “限制广告跟踪” 后返回 0000-0000...）；
     3. iOS 14.5+ 需用户授权（ATT 弹窗）。
     */
    /**
     /// 请求IDFA授权（兼容iOS13.0+，带回调）
     /// - Parameter completion: 回调闭包（主线程执行）
     ///   - idfa: 广告标识符（全0代表未授权/受限）
     ///   - isAuthorized: 是否成功授权（true=授权成功且IDFA有效，false=未授权/受限/版本不支持授权）
     */
    /// 延迟请求IDFA（固定延迟，兼容iOS13+）
    /// - Parameters:
    ///   - delaySeconds: 延迟秒数（推荐3~5秒）
    ///   - completion: 回调闭包
    static func requestIDFAAuthorization(withDelay delaySeconds: TimeInterval = 3, completion: @escaping (_ idfa: String, _ isAuthorized: Bool) -> Void) {
        // 延迟执行授权逻辑
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
            innerRequestIDFA(completion: completion)
        }
    }

    /// 核心授权逻辑（抽离，供延迟/即时调用）
    private static func innerRequestIDFA(completion: @escaping (_ idfa: String, _ isAuthorized: Bool) -> Void) {
        
        func getIDFA() -> (idfa: String, isEnabled: Bool) {
            let adManager = ASIdentifierManager.shared()
            guard adManager.isAdvertisingTrackingEnabled else {
                return ("", false)
            }
            return (adManager.advertisingIdentifier.uuidString, true)
        }
        
        if #available(iOS 14.5, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    let (idfa, isEnabled) = getIDFA()
                    let isAuthorized = (status == .authorized) && isEnabled
                    completion(idfa, isAuthorized)
                }
            }
        } else if #available(iOS 13.0, *) {
            let (idfa, isEnabled) = getIDFA()
            completion(idfa, isEnabled)
        }
    }
}


import Security

public extension JY_DeviceTool {
    /**
     需 “应用 + 设备” 永久唯一 → 用 Keychain 存储自定义 UUID（最推荐）；
     
     1. 首次启动 App 时生成一个 UUID，存入 Keychain（而非 UserDefaults）；
     2. 卸载重装 App 后仍保留（Keychain 跨重装）；
     3. 仅关联 “设备 + 应用”，非硬件绑定。
     */
    static func saveCustomUUIDToKeychain() -> String {
        // 先查是否已有存储
        if let existingUUID = getCustomUUIDFromKeychain() {
            return existingUUID
        }
        // 无则生成新UUID并存储
        let newUUID = UUID().uuidString
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "AppCustomDeviceID",
            kSecValueData: newUUID.data(using: .utf8)!,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock // 跨重装保留
        ]
        SecItemAdd(query as CFDictionary, nil)
        return newUUID
    }
    
    // 从Keychain读取UUID
    static func getCustomUUIDFromKeychain() -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "AppCustomDeviceID",
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var data: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &data)
        if status == errSecSuccess, let data = data as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

//// 调用：首次启动生成，后续读取
//let deviceID = saveCustomUUIDToKeychain()
//print("自定义设备ID：\(deviceID)") // 卸载重装后仍不变
