//
//  JY_ProjectManager.swift
//  JY_GeneralDevelopmentTools
//
//  Created by JYYQLin on 2025/12/22.
//

import Foundation

class JY_ProjectManager {
    
    // 静态常量作为单例的唯一访问点
    public static let shared = JY_ProjectManager()
    
    /** 是否是测试环境 */
    private(set) lazy var is_test_environment: Bool = false
    
    // 私有初始化方法，防止外部创建实例
    private init() { /**  print("Singleton 初始化") */ }
}

//  MARK: 设置测试环境
extension JY_ProjectManager {
    func set(isTestEnvironment: Bool) {
        is_test_environment = isTestEnvironment
    }
}
