//
//  JY_ScreenManager.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/23.
//

import UIKit

class JY_ScreenManager {
    
    // 静态常量作为单例的唯一访问点
    public static let shared = JY_ScreenManager()
    
    // 私有初始化方法，防止外部创建实例
    private init() { /**  print("Singleton 初始化") */ }
    
    
    //  MARK: 属性区
    let yq_designWidth: CGFloat = 375.0
    
}

extension JY_ScreenManager {
    
}







/**
 最大比例缩放
    手机系列最大宽度为
            16 pro max的 440
        最小宽度为
            375
 所以最大缩放比例就是 440 / 375 = 1.17333
 
 平板最小宽度为
    mini 6 的 744
 
 所以最小缩放比例就是 768 / 375 = 1.98
 
 最后取平均值 = 1.58
 
 */
let yq_max_phone_scale: CGFloat = (440 / 375.0)
let yq_max_scale: CGFloat = 1.58

extension UIScreen {
    //  屏幕宽度
    public static func yq_current_screen_width() -> CGFloat {
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        return window?.bounds.width ?? 0
    }
    
    //  屏幕高度
    public static func yq_current_screen_height() -> CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        return window?.bounds.height ?? 0
    }
    
    //  根据短边进行屏幕适配
    public static func yq_scale_to_short_side_screen() -> CGFloat {
        let width = yq_current_screen_width() <= yq_current_screen_height() ? yq_current_screen_width() : yq_current_screen_height()
        
        let scale = (width / JY_ScreenManager.shared.yq_designWidth)
        return scale > yq_max_scale ? yq_max_scale : scale
    }
}

extension UIView {
    /**
     根据控件宽度(短边)进行比例缩放,
        如果觉得预设的yq_max_scale不符合, 则可以通过自己传入maxScale计算
     */
    public func yq_scale_to_short_side_screen(originalWidth: CGFloat, maxScale: CGFloat? = nil) -> CGFloat {
        
        let width = self.frame.width <= self.frame.height ? self.frame.width : self.frame.height
        
        let scale = (width / originalWidth)
        
        if maxScale != nil {
            return scale > maxScale! ? maxScale! : scale
        }
        else {
            return scale > yq_max_scale ? yq_max_scale : scale
        }
    }
}

extension CGRect {
    /**
     根据控件宽度进行比例缩放,
        如果觉得预设的yq_max_scale不符合, 则可以通过自己传入maxScale计算
     */
    public func yq_scale_to_width(originalWidth: CGFloat, maxScale: CGFloat? = nil) -> CGFloat {
      
        let width = self.width <= self.height ? self.width : self.height
        
        let scale = (width / originalWidth)
        
        if maxScale != nil {
            return scale > maxScale! ? maxScale! : scale
        }
        else {
            return scale > yq_max_scale ? yq_max_scale : scale
        }
    }
}

extension CGFloat {
    /**
     根据控件宽度进行比例缩放,
        如果觉得预设的yq_max_scale不符合, 则可以通过自己传入maxScale计算
     */
    public func yq_scale_to(originalWidth: CGFloat, maxScale: CGFloat? = nil) -> CGFloat {
        let scale = (self / originalWidth)
        
        if maxScale != nil {
            return scale > maxScale! ? maxScale! : scale
        }
        else {
            return scale > yq_max_scale ? yq_max_scale : scale
        }
    }
}
