//
//  JY_SystemManager + Func.swift
//  JY_GeneralDevelopmentTools
//
//  Created by JYYQLin on 2025/12/22.
//

import UIKit

public extension JY_SystemManager {
    /** 跳转应用设置 */
    static func yq_push_application_setting(completionHandler: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) == true {
                UIApplication.shared.open(url, options: [:], completionHandler: completionHandler)
            }
        }
    }
}
