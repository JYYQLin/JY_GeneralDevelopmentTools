//
//  JY_AuthorizationManager.swift
//  JY_GeneralDevelopmentTools
//
//  Created by JYYQLin on 2025/12/24.
//

import Photos // 明确导入Photos框架，避免漏引

/// 权限管理工具类（单例）
public final class JY_AuthorizationManager {
    // 线程安全的单例（Swift 5.1+支持static let天然线程安全）
    public static let shared = JY_AuthorizationManager()
    
    // 私有初始化，防止外部实例化
    private init() {}
}

// MARK: - 相册权限相关
public extension JY_AuthorizationManager {
    /// 请求相册访问权限
    /// - Parameter completion: 权限请求完成回调（主线程执行）
    ///   - authorized: 是否拥有有效访问权限（authorized/limited为true，其余为false）
    ///   - status: 具体的权限状态
    func requestPhotoLibraryAuthorization(completion: @escaping (_ authorized: Bool, _ status: PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            // 统一判断是否为有效权限
            let isAuthorized = self?.isValidPhotoLibraryStatus(status) ?? false
            
            // 统一切换到主线程回调，避免重复代码
            DispatchQueue.main.async {
                // 打印日志，便于调试
                self?.logPhotoLibraryStatus(status, isAuthorized: isAuthorized)
                completion(isAuthorized, status)
            }
        }
    }
    
    // MARK: - 私有辅助方法
    /// 判断相册权限状态是否为“有效”（可正常访问）
    /// - Parameter status: 相册权限状态
    /// - Returns: 有效返回true，无效返回false
    private func isValidPhotoLibraryStatus(_ status: PHAuthorizationStatus) -> Bool {
        switch status {
        case .authorized:
            return true
        case .limited:
            // iOS 14+ 有限访问权限，视为有效
            return true
        case .notDetermined, .restricted, .denied:
            return false
        @unknown default:
            // 兼容未来新增的状态，默认视为无效
            return false
        }
    }
    
    /// 打印相册权限状态日志（调试用）
    /// - Parameters:
    ///   - status: 权限状态
    ///   - isAuthorized: 是否有效
    private func logPhotoLibraryStatus(_ status: PHAuthorizationStatus, isAuthorized: Bool) {
        let statusDesc: String
        switch status {
        case .notDetermined: statusDesc = "未作出权限选择"
        case .restricted: statusDesc = "权限受限制（如家长控制）"
        case .denied: statusDesc = "权限被拒绝"
        case .authorized: statusDesc = "完全授权"
        case .limited: statusDesc = "有限访问授权（iOS 14+）"
        @unknown default: statusDesc = "未知状态(\(status.rawValue))"
        }
        print("[JY_AuthorizationManager] 相册权限状态：\(statusDesc)，是否有效：\(isAuthorized)")
    }
}

// MARK: - 使用示例
/*
JY_AuthorizationManager.shared.requestPhotoLibraryAuthorization { authorized, status in
    if authorized {
        // 有权限，执行相册操作
        print("相册权限有效，可访问")
    } else {
        // 无权限，引导用户去设置开启
        print("相册权限无效，状态：\(status)")
    }
}
*/
