//
//  JY_Video_Player_View.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/9/16.
//

import UIKit
import AVFoundation

class JY_Video_Player_View: JY_View {
    
    var yq_video_url: String? {
        get {
            return yq_player_url?.absoluteString
        }
    }
    
    /// 播放状态变化时的回调闭包（参数为当前最新状态）
    var yq_state_change_block: ((JY_Video_Player_State) -> Void)?
    /// 视频播放到结束时的回调闭包（用于处理播放结束后的自定义逻辑）
    var yq_play_to_end_time_block: (() -> Void)?
    /// 视频开始重播时的回调闭包（用于处理重播后的自定义逻辑）
    var yq_replay_block: (() -> Void)?
    
    
    let yq_player_layer = AVPlayerLayer()
    
    
    /// 公开属性：播放器核心对象（提供播放/暂停/跳转等传输控制接口）
    /// - getter：获取当前playerLayer关联的AVPlayer实例
    /// - setter：为playerLayer设置新的AVPlayer实例
    public var yq_player: AVPlayer? {
        get { return yq_player_layer.player }
        set { yq_player_layer.player = newValue }
    }
    
    /// 当前播放器是否静音
    /// - getter：获取当前播放器的静音状态（默认false）
    /// - setter：设置当前播放器的静音状态
    open var yq_is_muted: Bool {
        get { return yq_player?.isMuted ?? false }
        set { yq_player?.isMuted = newValue }
    }
    
    /// 当前播放器的音量（仅对当前实例生效，范围0.0-1.0）
    /// - getter：获取音量（将AVPlayer的Float类型音量转为Double）
    /// - setter：设置音量（将Double类型音量转为Float，传给AVPlayer）
    var yq_volume: Double {
        get { return yq_player?.volume.double ?? 0 }
        set { yq_player?.volume = newValue.float }
    }
    
    //  当前正在播放的视频URL
    private(set) lazy var yq_player_url: URL? = nil
    
    /// 当前视频的播放状态（状态变化时会触发didSet中的回调）
    private(set) var yq_player_state: JY_Video_Player_State = .none {
        // 状态变化监听器：当state值改变时，调用stateDidChanged方法（传入当前状态和之前状态）
        didSet { stateDidChanged(state: yq_player_state, previous: oldValue) }
    }
    
    /// 视频暂停的具体原因（标记当前暂停是用户触发/缓冲触发/不可见触发）
    private(set) var yq_paused_reason: JY_Video_Paused_Reason = .waitingKeepUp
    
    /// 视频的重播次数（每次调用replay方法且不重置时，次数+1）
    private(set) var yq_replay_count: Int = 0
    
    /// 是否开启播放结束后自动重播（默认true）
    open lazy var yq_is_auto_replay: Bool = false
    
    /// 视频播放速率（默认1.0为正常速率，0.5为慢放，2.0为快放等）
    lazy var yq_speed_rate: Float = 1.0
    
    /// 当前视频的播放进度（0-1范围）
    /// - 若已加载完成（isLoaded=true）：返回播放器的实时播放进度
    /// - 若未加载（isLoaded=false）：返回0
    var yq_play_progress: Double {
        return yq_is_loaded ? yq_player?.playProgress ?? 0 : 0
    }
    
    /// 当前视频的已播放时长（单位：秒）
    /// - 若已加载：返回播放器当前播放位置对应的时长
    /// - 若未加载：返回0
    public var yq_current_duration: Double {
        return yq_is_loaded ? yq_player?.currentDuration ?? 0 : 0
    }
    
    /// 当前视频的缓冲进度（0-1范围）
    /// - 若已加载：返回播放器的实时缓冲进度
    /// - 若未加载：返回0
    public var yq_buffer_progress: Double {
        return yq_is_loaded ? yq_player?.bufferProgress ?? 0 : 0
    }
    
    /// 当前视频的已缓冲时长（单位：秒）
    /// - 若已加载：返回播放器已缓冲内容的总时长
    /// - 若未加载：返回0
    public var yq_current_buffer_duration: Double {
        return yq_is_loaded ? yq_player?.currentBufferDuration ?? 0 : 0
    }
    
    /// 当前视频的总时长（单位：秒）
    /// - 若已加载：返回视频资源的总时长
    /// - 若未加载：返回0
    public var yq_total_duration: Double {
        return yq_is_loaded ? yq_player?.totalDuration ?? 0 : 0
    }
    
    /// 当前视频的总观看时长（单位：秒）
    /// - 若已加载：总观看时长 = 当前播放时长 + 重播次数 × 视频总时长
    /// - 若未加载：返回0
    public var yq_watch_duration: Double {
        return yq_is_loaded ? yq_current_duration + yq_total_duration * Double(yq_replay_count) : 0
    }
    
    // 私有属性：标记视频是否已加载完成（true表示资源就绪，可正常播放）
    private var yq_is_loaded = false
    // 私有属性：标记是否处于重播状态（避免重播时误触发暂停状态判断）
    private var yq_is_replay = false
    
    
    // 私有属性：播放器缓冲状态的KVO观察对象（用于监听AVPlayerItem的loadedTimeRanges变化）
    private var playerBufferingObservation: NSKeyValueObservation?
    // 私有属性：播放器项目"是否跟得上播放"的KVO观察对象（监听AVPlayerItem的isPlaybackLikelyToKeepUp）
    private var playerItemKeepUpObservation: NSKeyValueObservation?
    // 私有属性：播放器项目状态的KVO观察对象（监听AVPlayerItem的status变化，如就绪/失败）
    private var playerItemStatusObservation: NSKeyValueObservation?
    // 私有属性：playerLayer就绪状态的KVO观察对象（监听AVPlayerLayer的isReadyForDisplay，判断视频是否可显示）
    private var playerLayerReadyForDisplayObservation: NSKeyValueObservation?
    // 私有属性：播放器控制状态的KVO观察对象（监听AVPlayer的timeControlStatus，如播放/暂停/等待）
    private var playerTimeControlStatusObservation: NSKeyValueObservation?
    
    
    // MARK: - Lifecycle（生命周期相关方法）
    /// 重写UIView的内容模式（视频显示的缩放模式）
    /// - 当contentMode改变时，同步更新playerLayer的videoGravity（视频缩放规则）
    open override var contentMode: UIView.ContentMode {
        didSet {
            // 根据contentMode匹配对应的playerLayer视频缩放模式
            switch contentMode {
            case .scaleAspectFill:  // 填充模式：保持宽高比，填满视图（可能裁剪边缘）
                yq_player_layer.videoGravity = .resizeAspectFill
            case .scaleAspectFit:   // 适应模式：保持宽高比，完整显示（可能留黑边）
                yq_player_layer.videoGravity = .resizeAspect
            default:                // 其他模式：拉伸填充（不保持宽高比）
                yq_player_layer.videoGravity = .resize
            }
        }
    }
    
    deinit {
        yq_destroy()
        
        // 从通知中心移除当前实例的所有观察者（避免野指针导致崩溃）
        NotificationCenter.default.removeObserver(self)
    }
}

extension JY_Video_Player_View {
    override func yq_add_subviews() {
        super.yq_add_subviews()
        
        yq_configure_audios_session()
        yq_configure_init()
    }
    
    private func yq_configure_init() {
        // 初始时隐藏视图：避免未加载完成时显示空白/异常画面（加载完成后会自动显示）
        isHidden = true
        
        // 为当前实例添加通知观察者：监听视频播放结束通知
        NotificationCenter.default.addObserver(
            self,                                  // 观察者：当前视图实例
            selector: #selector(yq_player_item_did_reach_end(notification:)),  // 通知触发时调用的方法
            name: .AVPlayerItemDidPlayToEndTime,   // 监听的通知名称：AVPlayerItem播放到结束时间
            object: nil                             // 观察对象：nil表示观察所有对象的该通知（可指定具体playerItem）
        )
        
        // 将playerLayer添加到当前视图的层中：作为子层，用于显示视频画面
        layer.addSublayer(yq_player_layer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard yq_player_layer.superlayer == layer else { return }
        
        // 开始CALayer事务（用于批量修改layer属性，避免多次触发渲染）
        CATransaction.begin()
        // 禁用事务的默认动画：让playerLayer的frame变化立即生效，无过渡动画
        CATransaction.setDisableActions(true)
        // 设置playerLayer的frame为当前视图的边界（让视频层填满整个播放器视图）
        yq_player_layer.frame = bounds
        // 提交CALayer事务，应用所有layer修改
        CATransaction.commit()
    }
}

extension JY_Video_Player_View {
    // 配置音频会话的方法
    private func yq_configure_audios_session() {
        do {
            // 设置音频会话类别为.playback，这会忽略静音开关
            // 同时设置选项为.mixWithOthers允许与其他音频混合
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            // 激活音频会话
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("配置音频会话失败: \(error.localizedDescription)")
        }
    }
}

extension JY_Video_Player_View {
    
    func yq_play(playerUrlString: String) {
        if let videoUrl = URL(string: playerUrlString) {
            yq_play(for: videoUrl)
        }
    }
    
    func yq_play(for url: URL) {
        //  如果当前播放的URL与传入URL相同，直接恢复播放（避免重复加载同一资源）
        guard yq_player_url != url else {
            // 设置暂停原因为"等待缓冲"（标记为非用户暂停）
            yq_paused_reason = .waitingKeepUp
            // 立即以当前播放速率恢复播放（跳过缓冲等待，适合已加载的资源）
            yq_player?.playImmediately(atRate: yq_speed_rate)
            return
        }
        
        // 1. 配置音频会话（确保播放时有声音，且符合场景策略）
        yq_configure_audios_session()
        
        // 2. 移除之前的KVO观察（避免对旧播放器/旧资源的无效观察，防止内存泄漏）
        observe(player: nil)
        observe(playerItem: nil)
        
        // 3. 清理旧播放器的残留操作（避免旧资源占用，释放内存）
        yq_player?.currentItem?.cancelPendingSeeks()  // 取消旧项目中未完成的进度跳转请求
        yq_player?.currentItem?.asset.cancelLoading()  // 取消旧项目资源的加载操作
        
        // 4. 创建新的播放器实例（用于播放新视频资源）
        let player = AVPlayer()
        // 禁用"自动等待缓冲以减少卡顿"：适合对实时性要求高的场景（如直播），可能增加卡顿风险
        player.automaticallyWaitsToMinimizeStalling = false
        
        // 5. 创建新的播放器项目（AVPlayerItem：管理视频资源的播放元数据和状态）
        let playerItem = AVPlayerItem(loader: url)
        // 允许直播流在暂停时仍使用网络资源：直播场景优化，暂停时继续缓冲，恢复时更快
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        
        // 6. 初始化当前播放器视图的状态（重置为新视频的初始状态）
        yq_player = player                  // 关联新创建的播放器
        yq_player_url = url                  // 更新当前播放URL
        yq_paused_reason = .waitingKeepUp    // 初始暂停原因为"等待缓冲"
        yq_replay_count = 0                  // 重置重播次数为0
        yq_is_replay = false                 // 标记为非重播状态
        yq_is_loaded = false                 // 标记为未加载完成
        
        // 7. 判断资源是否可立即播放（本地文件或缓冲足够）
        if playerItem.isEnoughToPlay || url.isFileURL {
            // 本地文件/缓冲足够：设置状态为"无状态"（准备播放）
            yq_player_state = .none
            // 标记是否加载完成：根据playerItem的状态是否为"就绪"（readyToPlay）
            yq_is_loaded = playerItem.status == .readyToPlay
            // 立即以当前速率播放（无需等待缓冲）
            player.playImmediately(atRate: yq_speed_rate)
        } else {
            // 远程资源且缓冲不足：设置状态为"加载中"（提示用户等待）
            yq_player_state = .loading
        }
        
        // 8. 将新创建的playerItem设置为播放器的当前项目（开始加载资源）
        player.replaceCurrentItem(with: playerItem)
        
        // 9. 为新播放器和新项目添加KVO观察（监听后续状态变化）
        observe(player: player)
        observe(playerItem: playerItem)
    }
}

extension JY_Video_Player_View {
    /// 重播当前视频
    /// - 参数resetCount：是否重置重播次数（默认false，即重播次数+1；true则重置为0）
    func yq_replay(resetCount: Bool = false) {
        // 更新重播次数：根据resetCount决定是重置为0还是加1
        yq_replay_count = resetCount ? 0 : yq_replay_count + 1
        // 将播放进度跳转到视频开头（CMTime.zero表示0时刻，即视频起始位置）
        yq_player?.seek(to: .zero)
        // 调用resume方法恢复播放（开始重播）
        yq_resume()
    }
    
    /// 恢复播放（从暂停状态继续播放）
    func yq_resume() {
        // 设置暂停原因为"等待缓冲"（标记为非用户暂停，缓冲足够时自动恢复）
        yq_paused_reason = .waitingKeepUp
        // 立即以当前播放速率恢复播放
        yq_player?.playImmediately(atRate: yq_speed_rate)
    }
    
    /// 暂停当前播放
    func yq_pause() {
        // 调用AVPlayer的pause方法，暂停视频播放
        yq_player?.pause()
    }
    
    /// 带原因的暂停（明确标记暂停触发的原因）
    /// - 参数reason：暂停的原因（PausedReason枚举值）
    func yq_pause(reason: JY_Video_Paused_Reason) {
        // 设置当前暂停原因
        yq_paused_reason = reason
        // 调用基础pause方法，执行暂停操作
        yq_pause()
    }
}

extension JY_Video_Player_View {
    /// 跳转播放进度到指定时间
    /// - 参数time：目标跳转时间（CMTime类型，Core Media框架的时间格式）
    /// - 参数completion：跳转完成后的回调闭包（参数为Bool，true表示跳转成功，false表示失败）
    func yq_seek(to time: CMTime, completion: ((Bool) -> Void)? = nil) {
        // 调用AVPlayer的seek方法，跳转后将结果传入回调闭包
        yq_player?.seek(to: time) { completion?($0) }
    }
    
    /// 带时间容忍范围的进度跳转（更灵活的跳转控制）
    /// - 参数time：目标跳转时间
    /// - 参数toleranceBefore：跳转允许的向前误差范围（如允许比目标时间早多少）
    /// - 参数toleranceAfter：跳转允许的向后误差范围（如允许比目标时间晚多少）
    /// - 参数completion：跳转完成后的回调闭包（必传，参数为跳转是否成功）
    func yq_seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completion: @escaping (Bool) -> Void) {
        // 调用AVPlayer的带容忍范围的seek方法，满足精准或模糊跳转需求
        yq_player?.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completion)
    }
}

extension JY_Video_Player_View {
    /// 公开方法：添加边界时间观察者（播放到指定时间点时触发回调）
    /// - 参数times：需要监听的时间点数组（CMTime类型）
    /// - 参数queue：回调闭包执行的队列（默认nil，即主线程）
    /// - 参数using：时间点触发时的回调闭包
    /// - 返回值：观察者对象（需保存，后续用于移除观察者）
    @discardableResult  // 允许忽略返回值（无需移除观察者时可省略）
    @nonobjc public func yq_add_boundary_time_observer(forTimes times: [CMTime], queue: DispatchQueue? = nil, using: @escaping () -> Void) -> Any? {
        // 将CMTime数组转为NSValue数组（AVPlayer要求的参数格式），添加观察者并返回
        return yq_player?.addBoundaryTimeObserver(forTimes: times.map { NSValue(time: $0) }, queue: queue, using: using)
    }
    
    /// 添加周期性时间观察者（播放过程中定期触发回调，如更新进度条）
    /// - 参数interval：回调触发的时间间隔（如CMTimeMake(value: 1, timescale: 1)表示每秒触发一次）
    /// - 参数queue：回调闭包执行的队列（默认nil，即主线程）
    /// - 参数using：定期触发的回调闭包（参数为当前播放时间CMTime）
    /// - 返回值：观察者对象（需保存，后续用于移除观察者）
    @discardableResult
    func yq_add_periodic_time_observer(forInterval interval: CMTime, queue: DispatchQueue? = nil, using: @escaping (CMTime) -> Void) -> Any? {
        // 调用AVPlayer的周期性观察者方法，返回观察者对象
        return yq_player?.addPeriodicTimeObserver(forInterval: interval, queue: queue, using: using)
    }
    
    /// 移除时间观察者（避免内存泄漏，不再需要时必须调用）
    /// - 参数observer：之前通过addBoundaryTimeObserver或addPeriodicTimeObserver获取的观察者对象
    func yq_remove_time_observer(_ observer: Any) {
        // 调用AVPlayer的移除观察者方法，停止监听时间变化
        yq_player?.removeTimeObserver(observer)
    }
    
    /// 销毁播放器视图（释放所有资源，从父视图移除）
    func yq_destroy() {
        // 置空播放器（释放AVPlayer及关联资源）
        yq_player = nil
        // 移除通知观察者（双重保险，避免析构前未释放的情况）
        NotificationCenter.default.removeObserver(self)
        // 将当前播放器视图从父视图中移除（销毁视图层级）
        removeFromSuperview()
    }
}

extension JY_Video_Player_View {
    /// 开放方法：切换播放指定索引的音轨（如多语言音轨切换）
    /// - 参数index：目标音轨的索引（从0开始）
    func yq_play_audio_track(index: Int) {
        // 守卫条件：确保获取到当前播放器项目的资源、可听媒体组，且索引不越界
        guard
            let asset = yq_player?.currentItem?.asset,  // 获取当前视频资源（AVAsset）
            let group = asset.mediaSelectionGroup(
                forMediaCharacteristic: AVMediaCharacteristic.audible  // 获取"可听"类型的媒体组（即音轨组）
            ),
            group.options.count > index  // 确保目标索引小于音轨数量（避免越界）
        else {
            // 上述条件不满足（如无音轨组、索引越界），直接返回
            return
        }
        
        // 在全局并发队列（用户发起优先级）异步执行：避免阻塞主线程（音轨切换可能耗时）
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // 弱引用self：避免循环引用（闭包持有self，self持有player，防止内存泄漏）
            // 选择媒体组中指定索引的音轨选项（切换到目标音轨）
            self?.yq_player?.currentItem?.select(group.options[index], in: group)
        }
    }
}

extension JY_Video_Player_View {
    func observe(player: AVPlayer?) {
        
        guard let player = player else {
            playerLayerReadyForDisplayObservation = nil
            playerTimeControlStatusObservation = nil
            return
        }
        
        playerLayerReadyForDisplayObservation = yq_player_layer.observe(\.isReadyForDisplay) { [unowned self, unowned player] playerLayer, _ in
            if playerLayer.isReadyForDisplay, player.rate > 0 {
                yq_is_loaded = true
                yq_player_state = .playing
            }
        }
        
        playerTimeControlStatusObservation = player.observe(\.timeControlStatus) { [unowned self] player, _ in
            switch player.timeControlStatus {
            case .paused:
                guard !self.yq_is_replay else { break }
                self.yq_player_state = .paused(playProgress: self.yq_play_progress, bufferProgress: self.yq_buffer_progress)
                if self.yq_paused_reason == .waitingKeepUp { player.playImmediately(atRate: yq_speed_rate) }
            case .waitingToPlayAtSpecifiedRate:
                break
            case .playing:
                if self.yq_player_layer.isReadyForDisplay, player.rate > 0 {
                    self.yq_is_loaded = true
                    if self.yq_play_progress == 0, self.yq_is_replay { self.yq_is_replay = false; break }
                    self.yq_player_state = .playing
                }
            @unknown default:
                break
            }
        }
    }
    
    func observe(playerItem: AVPlayerItem?) {
        
        guard let playerItem = playerItem else {
            playerBufferingObservation = nil
            playerItemStatusObservation = nil
            playerItemKeepUpObservation = nil
            return
        }
        
        playerBufferingObservation = playerItem.observe(\.loadedTimeRanges) { [unowned self] item, _ in
            if case .paused = self.yq_player_state, self.yq_paused_reason != .hidden {
                self.yq_player_state = .paused(playProgress: self.yq_play_progress, bufferProgress: self.yq_buffer_progress)
            }
            
            if self.yq_buffer_progress >= 0.99 || (self.yq_current_buffer_duration - self.yq_current_duration) > 3 {
                JY_Video_Preload_Manager.shared.start()
            } else {
                JY_Video_Preload_Manager.shared.pause()
            }
        }
        
        playerItemStatusObservation = playerItem.observe(\.status) { [unowned self] item, _ in
            if item.status == .failed, let error = item.error as NSError? {
                self.yq_player_state = .error(error)
            }
        }
        
        playerItemKeepUpObservation = playerItem.observe(\.isPlaybackLikelyToKeepUp) { [unowned self] item, _ in
            if item.isPlaybackLikelyToKeepUp {
                if self.yq_player?.rate == 0, self.yq_paused_reason == .waitingKeepUp {
                    self.yq_player?.playImmediately(atRate: yq_speed_rate)
                }
            }
        }
    }
}

extension JY_Video_Player_View {
    //  视频播放结束的通知回调
    @objc func yq_player_item_did_reach_end(notification: Notification) {
        guard (notification.object as? AVPlayerItem) == yq_player?.currentItem else {
            return
        }
        
        //  触发播放结束回调：外部可通过该回调处理结束逻辑（如显示"播放完成"提示）
        yq_play_to_end_time_block?()
        
        //  如果开启自动重播，且暂停原因是"等待缓冲"（不是用户手动暂停）
        guard yq_is_auto_replay, yq_paused_reason == .waitingKeepUp else {
            return
        }
        
        // 执行自动重播逻辑
        yq_player_state = .playEndTime
        yq_is_replay = true     // 标记为重播状态（避免暂停状态误判）
        yq_replay_block?()               // 触发重播回调（外部可处理重播相关逻辑）
        yq_replay_count += 1    // 重播次数加1（用于计算总观看时长）
        
        //  跳转到视频开头并开始重播
        yq_player?.seek(to: CMTime.zero)
        yq_player?.playImmediately(atRate: yq_speed_rate)
    }
}

extension JY_Video_Player_View {
    /// 私有方法：处理播放状态变化（状态改变时的核心逻辑）
    /// - 参数state：当前最新的播放状态
    /// - 参数previous：之前的播放状态（用于对比，避免重复处理）
    func stateDidChanged(state: JY_Video_Player_State, previous: JY_Video_Player_State) {
        guard state != previous else {
            return
        }
        
        // 根据当前状态设置视图可见性：仅播放/暂停状态显示视图，其他状态隐藏
        switch state {
        case .playing, .paused:  // 正在播放或暂停状态：显示视图
            isHidden = false
        default:                // 无状态/加载中/错误状态：隐藏视图
            isHidden = true
        }
        
        // 触发外部设置的状态变化回调：将最新状态传给外部（如UI更新、业务逻辑处理）
        yq_state_change_block?(state)
    }
}



