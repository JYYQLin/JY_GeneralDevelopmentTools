//
//  JY_TimerManager.swift
//  JY_GeneralDevelopmentTools
//
//  Created by JYYQLin on 2025/12/24.
//

import Foundation

/// 全局定时器管理单例（秒级计时、运行时长统计、调试日志、通知回调）
public final class JY_TimerManager {
    // MARK: - 单例（Swift静态常量天然线程安全）
    public static let shared = JY_TimerManager()
    
    // MARK: - 私有属性（线程安全保护）
    /// 串行队列：保证属性读写、定时器操作线程安全（修正：移除.concurrent，改为纯串行）
    private let serialQueue = DispatchQueue(label: "JY_TimerManager_com.jy.timer.manager.queue")
    /// 核心定时器（Block版本避免target-action强引用）
    private var timer: Timer?
    /// 定时器锁：防止多线程同时操作timer（双重保障）
    private let timerLock = NSLock()
    
    // MARK: - 公开属性（只读，外部仅能通过方法修改）
    /// 本次运行时长（秒）：全局计时核心值，线程安全更新
    public private(set) var runTime: Int = 0
    /// 是否开启调试模式（开启后打印运行时长日志）
    public private(set) var isDebug: Bool = false
    /// 调试日志输出间隔（秒）：默认1秒，强制最小值1秒
    public private(set) var logInterval: Int = 1
    
    // MARK: - 初始化（私有，防止外部创建）
    private init() {}
    
    // MARK: - 析构函数（单例几乎不会调用，仅做兜底）
    deinit {
        stopTimer()
    }
}

extension Notification.Name {
    static let JY_TimerManagerFired = Notification.Name("Notification.Name + JY_TimerManager.TimerFired")
}

// MARK: - 配置方法（调试模式/日志间隔）
public extension JY_TimerManager {
    /// 设置调试模式
    /// - Parameter isDebug: 是否开启（开启后每秒/指定间隔打印运行时长）
    func setDebugMode(_ isDebug: Bool) {
        serialQueue.async { // 移除.barrier，串行队列异步写入即可保证安全
            self.isDebug = isDebug
        }
    }
    
    /// 设置调试日志输出间隔
    /// - Parameter interval: 间隔秒数（自动限制最小值为1，避免取模报错）
    func setLogInterval(_ interval: Int) {
        serialQueue.async { // 移除.barrier，串行队列异步写入即可保证安全
            self.logInterval = max(interval, 1)
        }
    }
}

// MARK: - 定时器核心操作（启动/停止/状态检查/恢复）
public extension JY_TimerManager {
    /// 启动定时器（重置运行时长为0，每秒触发一次）
    func startTimer() {
        // 先判断状态（非阻塞锁），避免重复创建
        guard !isTimerRunning() else { return }
        
        // 重置运行时长（异步，不阻塞）
        serialQueue.async {
            self.runTime = 0
        }
        
        // 加锁操作timer（仅在创建定时器时加锁，缩小锁范围）
        timerLock.lock()
        defer { timerLock.unlock() }
        createTimer()
    }
    
    /// 停止定时器
    func stopTimer() {
        timerLock.lock()
        defer { timerLock.unlock() }
        
        timer?.invalidate()
        timer = nil
    }
    
    /// 检查定时器是否正在运行
    /// - Returns: 运行状态（true=运行中，false=已停止）
    func isTimerRunning() -> Bool {
        // 改用 NSLock 的 try() 非阻塞加锁，避免永久等待
        guard timerLock.try() else {
            // 加锁失败（说明其他线程正在操作timer），暂时返回false（兜底逻辑）
            return false
        }
        defer { timerLock.unlock() }
        
        // 优化判断逻辑：先判timer是否存在，再判isValid（避免强制解包）
        guard let validTimer = timer else { return false }
        return validTimer.isValid
    }
    
    /// 恢复定时器（保留当前运行时长，不会重置）
    func resumeTimer() {
        guard !isTimerRunning() else { return }
        
        timerLock.lock()
        defer { timerLock.unlock() }
        createTimer()
    }
    
    /// 线程安全读取当前运行时长（新增：提供外部安全读取接口）
    func getCurrentRunTime() -> Int {
        serialQueue.sync {
            return self.runTime
        }
    }
}

// MARK: - 私有方法（定时器创建/回调）
private extension JY_TimerManager {
    /// 创建定时器（统一创建逻辑，绑定主线程RunLoop）
    func createTimer() {
        // Block版本Timer，避免target-action强引用
        let newTimer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.handleTimerFired()
        }
        
        // 绑定主线程RunLoop（全局定时器建议主线程，避免子线程RunLoop退出失效）
        RunLoop.main.add(newTimer, forMode: .common)
        newTimer.tolerance = 0.1 // 允许100ms误差，提升性能
        
        timer = newTimer
    }
    
    /// 定时器每秒触发的回调处理（核心修复：消除死锁）
    func handleTimerFired() {
        // 步骤1：异步更新运行时长（无阻塞）
        serialQueue.async {
            self.runTime += 1
            
            // 步骤2：在串行队列内完成日志判断（避免跨队列同步）
            guard self.isDebug else { return }
            
            let currentRunTime = self.runTime
            let interval = self.logInterval
            
            // 首次触发（1秒）或达到间隔时打印
            if currentRunTime == 1 || currentRunTime % interval == 0 {
                print("[JY_TimerManager] 已运行：\(currentRunTime) 秒（线程：\(Thread.current)）")
            }
        }
        
        // 步骤3：发送通知（使用安全读取的运行时长）
        let currentRunTime = getCurrentRunTime()
        NotificationCenter.default.post(
            name: .JY_TimerManagerFired,
            object: self,
            userInfo: ["runTime": currentRunTime]
        )
    }
}

// MARK: - 通知快捷操作（简化外部监听/移除）
public extension JY_TimerManager {
    /// 监听定时器触发通知
    /// - Parameters:
    ///   - observer: 监听者
    ///   - selector: 回调方法
    ///   - object: 过滤对象（默认nil）
    static func addTimerFiredObserver(_ observer: Any, selector: Selector, object: Any? = nil) {
        NotificationCenter.default.addObserver(
            observer,
            selector: selector,
            name: .JY_TimerManagerFired,
            object: object
        )
    }
    
    /// 移除定时器触发通知监听
    /// - Parameters:
    ///   - observer: 监听者
    ///   - object: 过滤对象（默认nil）
    static func removeTimerFiredObserver(_ observer: Any, object: Any? = nil) {
        NotificationCenter.default.removeObserver(
            observer,
            name: .JY_TimerManagerFired,
            object: object
        )
    }
}
