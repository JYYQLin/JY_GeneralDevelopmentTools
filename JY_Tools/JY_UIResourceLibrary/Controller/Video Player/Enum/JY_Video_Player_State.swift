//
//  JY_Video_Player_State.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/9/16.
//

import UIKit

public enum JY_Video_Player_State: Equatable {
    
    /// 无状态（初始默认状态，未开始加载或播放）
    case none
    
    /// 加载中（从首次发起加载请求，到成功获取视频首帧的阶段）
    case loading
    
    /// 正在播放（视频正常播放中的状态）
    case playing
    
    /// 暂停状态（缓冲进度变化时会重复触发该状态），关联两个参数：
    /// - playProgress：当前播放进度（0-1范围，0为开头，1为结尾）
    /// - bufferProgress：当前缓冲进度（0-1范围）
    case paused(playProgress: Double, bufferProgress: Double)
    
    /// 播放完成状态
    case playEndTime
    
    /// 错误状态（播放过程中发生错误，无法继续播放），关联错误对象NSError
    case error(NSError)
}

// 播放状态枚举
extension JY_Video_Player_State {
    
    /// 实现Equatable协议的==方法：判断两个JY_Player_State实例是否相等
    /// - 参数lhs：左侧状态实例（left-hand side）
    /// - 参数rhs：右侧状态实例（right-hand side）
    /// - 返回值：Bool，true表示相等，false表示不相等
    public static func == (lhs: JY_Video_Player_State, rhs: JY_Video_Player_State) -> Bool {
        // 根据状态类型进行模式匹配，判断是否相等
        switch (lhs, rhs) {
        case (.none, .none):
            // 两边都是"无状态"，相等
            return true
        case (.loading, .loading):
            // 两边都是"加载中"，相等
            return true
        case (.playing, .playing):
            // 两边都是"正在播放"，相等
            return true
        case let (.paused(p1, b1), .paused(p2, b2)):
            // 两边都是"暂停状态"：需要播放进度和缓冲进度都相等才视为相等
            return (p1 == p2) && (b1 == b2)
        case let (.error(e1), .error(e2)):
            // 两边都是"错误状态"：需要错误对象相等（NSError遵循Equatable）才视为相等
            return e1 == e2
        default:
            // 其他情况（状态类型不同，如一边是playing一边是paused），不相等
            return false
        }
    }
}

public enum JY_Video_Paused_Reason: Int {
    
    /// 因播放器视图不可见而暂停（缓冲进度变化时不会触发stateDidChanged回调）
    case hidden
    
    /// 用户交互触发的暂停（如点击暂停按钮，默认暂停行为）
    case userInteraction
    
    /// 等待资源缓冲完成（缓冲不足时自动暂停，缓冲足够后会自动恢复）
    case waitingKeepUp
}


enum JY_Action_Type {
    /** 本地 */
    case local
    /** 远程 */
    case remote
}

enum JY_Video_Speed: Float {
    case slow_7_5 = 0.75
    case normal = 1.0
    case fast_1_25 = 1.25
    case fast_1_5 = 1.5
    case fast_2_0 = 2
}
