//
//  JY_UIWindow.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/24.
//

import UIKit

// MARK: - UIWindow 扩展（获取当前主窗口，优化容错）
extension UIWindow {
    public static func yq_firstWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?
                .windows
                .first { $0.isKeyWindow && !$0.isHidden } // 过滤隐藏的window
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
