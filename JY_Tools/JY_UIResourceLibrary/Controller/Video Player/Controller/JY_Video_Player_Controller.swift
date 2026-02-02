//
//  JY_Video_Player_Controller.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/9/16.
//

import UIKit
import CoreMedia

class JY_Video_Player_Controller: JY_BaseController {

    /// 播放状态变化时的回调闭包（参数为当前最新状态）
    var yq_state_change_block: ((JY_Video_Player_State) -> Void)?
    /// 视频播放到结束时的回调闭包（用于处理播放结束后的自定义逻辑）
    var yq_play_to_end_time_block: (() -> Void)?
    /// 视频开始重播时的回调闭包（用于处理重播后的自定义逻辑）
    var yq_replay_block: (() -> Void)?
    
    var yq_paused_reason: JY_Video_Paused_Reason {
        get {
            return yq_detail_view.yq_paused_reason
        }
    }
    
    var yq_replay_count: Int {
        get {
            return yq_detail_view.yq_replay_count
        }
    }
    
    var yq_is_auto_replay: Bool {
        get {
            return yq_detail_view.yq_is_auto_replay
        }
    }
    
    var yq_speed_rate: Float {
        get {
            return yq_detail_view.yq_speed_rate
        }
    }
    
    /// 当前视频的播放进度（0-1范围）
    /// - 若已加载完成（isLoaded=true）：返回播放器的实时播放进度
    /// - 若未加载（isLoaded=false）：返回0
    var yq_play_progress: Double {
        get {
            return yq_detail_view.yq_play_progress >= 1 ? 1 : yq_detail_view.yq_play_progress
        }
    }
    
    /// 当前视频的已播放时长（单位：秒）
    /// - 若已加载：返回播放器当前播放位置对应的时长
    /// - 若未加载：返回0
    var yq_current_duration: Double {
        get {
            return yq_detail_view.yq_current_duration >= yq_detail_view.yq_total_duration ? yq_detail_view.yq_total_duration : yq_detail_view.yq_current_duration
        }
    }
    
    /// 当前视频的缓冲进度（0-1范围）
    /// - 若已加载：返回播放器的实时缓冲进度
    /// - 若未加载：返回0
    var yq_buffer_progress: Double {
        get {
            return yq_detail_view.yq_buffer_progress
        }
    }
    
    /// 当前视频的总时长（单位：秒）
    /// - 若已加载：返回视频资源的总时长
    /// - 若未加载：返回0
    var yq_total_duration: Double {
        get {
            return yq_detail_view.yq_total_duration
        }
    }
    
    /// 当前视频的总观看时长（单位：秒）
    /// - 若已加载：总观看时长 = 当前播放时长 + 重播次数 × 视频总时长
    /// - 若未加载：返回0
    var yq_watch_duration: Double {
        get {
            return yq_detail_view.yq_watch_duration
        }
    }
    
    var yq_video_url: String? {
        get {
            return yq_detail_view.yq_video_url
        }
    }
    
    private(set) lazy var yq_detail_view: JY_Video_Player_View = JY_Video_Player_View()
    
}

extension JY_Video_Player_Controller {
    override func yq_setInterface() {
        super.yq_setInterface()
        
        yq_contentView.addSubview(yq_detail_view)
        yq_detail_view.yq_state_change_block = { [weak self] state in
            self?.yq_state_change_block?(state)
        }
        
        yq_detail_view.yq_play_to_end_time_block = { [weak self] in
            self?.yq_play_to_end_time_block?()
        }
        
        yq_detail_view.yq_replay_block = { [weak self] in
            self?.yq_replay_block?()
        }
    }
    
    override func yq_layoutSubviews() {
        super.yq_layoutSubviews()
                
        yq_detail_view.frame.origin = {
            yq_detail_view.frame.size = yq_contentView.frame.size
            yq_detail_view.set(scale: yq_scale)
            return yq_contentView.bounds.origin
        }()
    }
}

extension JY_Video_Player_Controller {
    func set(videoUrl: String) {
        
        yq_detail_view.yq_play(playerUrlString: videoUrl)
    }
    
    func set(speedRate: Float) {
        yq_detail_view.yq_speed_rate = speedRate
    }
    
    func yq_pause() {
        yq_detail_view.yq_pause(reason: .userInteraction)
    }
    
    func yq_resume() {
        yq_detail_view.yq_resume()
    }
    
    func yq_replay() {
        yq_detail_view.yq_replay()
    }
    
    func set(progress: Float, completion: ((Bool) -> Void)? = nil) {
        
        let time = Double(progress) * yq_total_duration
        
        let targetTime = CMTime(value: CMTimeValue(time), timescale: 1)
        
        yq_detail_view.yq_seek(to: targetTime, completion: completion)
    }
    
    func set(isAutoReplay: Bool) {
        yq_detail_view.yq_is_auto_replay = isAutoReplay
    }
    
    func set(resetCount: Bool) {
        yq_detail_view.yq_replay(resetCount: resetCount)
    }
}
