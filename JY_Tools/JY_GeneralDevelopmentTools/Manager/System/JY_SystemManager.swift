//
//  JY_SystemManager.swift
//  JY_GeneralDevelopmentTools
//
//  Created by JYYQLin on 2025/12/22.
//

import Foundation

public final class JY_SystemManager {
    
    // 静态常量作为单例的唯一访问点
    public static let shared = JY_SystemManager()
    
    // 私有初始化方法，防止外部创建实例
    private init() { // 初始化代码
        //        print("Singleton 初始化")
    }
}
