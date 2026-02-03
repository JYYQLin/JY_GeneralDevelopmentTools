//
//  JY_NetworkManager.swift
//  JY_GeneralDevelopmentTools
//
//  Created by JYYQLin on 2025/11/6.
//

import UIKit
import Combine
import Network

// MARK: - 网络类型枚举（无核心修改，仅注释优化）
public enum JYConnectionType: CustomStringConvertible {
    case unknown          // 未知
    case notConnected     // 无网络
    case wifi             // WiFi
    case cellular         // 蜂窝数据（4G/5G等）
    case wiredEthernet    // 有线网络（如iPad以太网适配器）
    
    public var description: String {
        switch self {
        case .unknown: return "未知网络"
        case .notConnected: return "无网络"
        case .wifi: return "WiFi"
        case .cellular: return "蜂窝数据"
        case .wiredEthernet: return "有线网络"
        }
    }
}

// MARK: - 网络状态模型（Equatable 保证精准对比）
public struct JYNetworkStatus: Equatable {
    let connectionType: JYConnectionType
    let isExpensive: Bool       // 是否是昂贵网络（蜂窝/热点等）
    let isConstrained: Bool     // 是否受低数据模式限制
    let isConnected: Bool       // 是否有网络连接
    
    // 日志友好的描述
    var logDescription: String {
        """
        [网络状态更新]
        - 连接状态：\(isConnected ? "已连接" : "未连接")
        - 网络类型：\(connectionType.description)
        - 昂贵网络：\(isExpensive ? "是" : "否")
        - 低数据模式：\(isConstrained ? "开启" : "关闭")
        """
    }
    
    // 简化默认值初始化
    static let defaultDisconnected = JYNetworkStatus(
        connectionType: .notConnected,
        isExpensive: false,
        isConstrained: false,
        isConnected: false
    )
}

// MARK: - 网络监听管理类（核心优化）
public final class JY_NetworkManager {
    // 线程安全单例
    public static let shared: JY_NetworkManager = {
        let instance = JY_NetworkManager()
        return instance
    }()
    
    // Combine发布者（仅状态真变化时更新）
    @Published public var networkStatus: JYNetworkStatus = .defaultDisconnected
    
    // 对外只读的Publisher（双重去重：模型对比 + 主线程）
    var networkStatusPublisher: AnyPublisher<JYNetworkStatus, Never> {
        $networkStatus
            .removeDuplicates() // 第一步：模型级去重（Equatable）
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // 私有属性
    private let lock = NSLock()
    private let monitorQueue = DispatchQueue(
        label: "com.jy.networkMonitor.queue",
        qos: .utility,
        attributes: .concurrent
    )
    private lazy var pathMonitor: NWPathMonitor = {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            self?.updateNetworkStatus(with: path)
        }
        return monitor
    }()
    private var isMonitoring = false
    private var cancellables = Set<AnyCancellable>()
    // 记录上一次的完整状态（用于精准对比）
    private var lastNetworkStatus: JYNetworkStatus = .defaultDisconnected
    // 记录上一次的连接状态（用于判断连接变动）
    private var lastConnectedState = false
    
    // 私有初始化
    private init() {
        setupStatusHandlers()
    }
    
    // MARK: - 状态监听初始化（拆分逻辑，职责单一）
    private func setupStatusHandlers() {
        // 1. 全量状态变化：仅模型真变化时，发送JY_NetworkStatusChanged通知
        networkStatusPublisher
            .sink { [weak self] newStatus in
                guard let self = self else { return }
                self.handleFullStatusChange(newStatus: newStatus)
            }
            .store(in: &cancellables)
        
        // 2. 连接状态变化：拆分“无→有”和“有→无”，发送专属通知
        networkStatusPublisher
            .map { $0.isConnected } // 仅关注连接状态
            .removeDuplicates() // 过滤重复的连接状态
            .sink { [weak self] currentConnected in
                guard let self = self else { return }
                self.handleConnectionStateChange(currentConnected: currentConnected)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 全量状态变化处理（仅真变化时发送JY_NetworkStatusChanged）
    private func handleFullStatusChange(newStatus: JYNetworkStatus) {
        lock.lock()
        defer { lock.unlock() }
        
        // 核心：仅当新状态 ≠ 上一次状态时，才发送全量通知
        guard newStatus != lastNetworkStatus else {
            return // 状态无变化，不发送通知
        }
        
        // 打印日志 + 发送全量状态通知
        print(newStatus.logDescription)
        NotificationCenter.default.post(
            name: .JY_NetworkStatusChanged,
            object: self,
            userInfo: ["networkStatus": newStatus]
        )
        
        // 更新上一次的完整状态
        lastNetworkStatus = newStatus
    }
    
    // MARK: - 连接状态变化处理（拆分“无→有”和“有→无”）
    private func handleConnectionStateChange(currentConnected: Bool) {
        lock.lock()
        defer { lock.unlock() }
        
        let lastConnected = lastConnectedState
        
        // 1. 无网 → 有网：发送重连通知
        if !lastConnected && currentConnected {
            print("[JY_NetworkManager] 检测到网络重连（无网→有网）")
            NotificationCenter.default.post(
                name: .JY_NetworkConnectedChanged,
                object: self,
                userInfo: ["isConnected": true, "networkStatus": networkStatus]
            )
        }
        // 2. 有网 → 无网：发送断连通知
        else if lastConnected && !currentConnected {
            print("[JY_NetworkManager] 检测到网络断开（有网→无网）")
            NotificationCenter.default.post(
                name: .JY_NetworkDisconnectedChanged,
                object: self,
                userInfo: ["isConnected": false, "networkStatus": networkStatus]
            )
        }
        
        // 更新上一次的连接状态
        lastConnectedState = currentConnected
    }
    
    // MARK: - 网络状态更新（线程安全 + 精准对比）
    private func updateNetworkStatus(with path: NWPath) {
        lock.lock()
        defer { lock.unlock() }
        
        let isConnected = path.status == .satisfied
        let newStatus = JYNetworkStatus(
            connectionType: getConnectionType(from: path, isConnected: isConnected),
            isExpensive: path.isExpensive,
            isConstrained: path.isConstrained,
            isConnected: isConnected
        )
        
        // 仅当新状态 ≠ 当前状态时，才更新（避免无效的@Published触发）
        if newStatus != networkStatus {
            networkStatus = newStatus
        }
    }
    
    // MARK: - 辅助方法：解析网络类型
    private func getConnectionType(from path: NWPath, isConnected: Bool) -> JYConnectionType {
        guard isConnected else { return .notConnected }
        
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .wiredEthernet
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else {
            return .unknown
        }
    }
    
    // MARK: - 公开方法：启动/停止监听
    public func startNetworkMonitoring() {
        lock.lock()
        defer { lock.unlock() }
        
        guard !isMonitoring else {
            print("[JY_NetworkManager] 网络监听已启动，无需重复操作")
            return
        }
        pathMonitor.start(queue: monitorQueue)
        isMonitoring = true
        // 初始化状态记录
        lastConnectedState = networkStatus.isConnected
        lastNetworkStatus = networkStatus
        print("[JY_NetworkManager] 网络监听已启动")
    }
    
    public func stopNetworkMonitoring() {
        lock.lock()
        defer { lock.unlock() }
        
        guard isMonitoring else {
            print("[JY_NetworkManager] 网络监听未启动，无需停止")
            return
        }
        pathMonitor.cancel()
        isMonitoring = false
        print("[JY_NetworkManager] 网络监听已停止")
    }
    
    // MARK: - 订阅方法（优化语义）
    func subscribeNetworkStatus(
        owner: AnyObject,
        cancellables: inout Set<AnyCancellable>,
        handler: @escaping (JYNetworkStatus) -> Void
    ) {
        networkStatusPublisher
            .sink(receiveValue: handler)
            .store(in: &cancellables)
    }
    
    // 析构函数（安全清理）
    deinit {
        stopNetworkMonitoring()
        cancellables.removeAll()
    }
}

// MARK: - 通知名扩展（新增断连通知 + 语义化）
public extension Notification.Name {
    /// 网络全量状态变化通知（仅当状态真变化时触发：类型/连接/昂贵/低数据模式）
    static let JY_NetworkStatusChanged = Notification.Name("JY_NetworkManager_StatusChanged")
    
    /// 网络重连通知（仅“无网→有网”时触发）
    static let JY_NetworkConnectedChanged = Notification.Name("JY_NetworkManager_ConnectedChanged")
    
    /// 网络断连通知（仅“有网→无网”时触发）
    static let JY_NetworkDisconnectedChanged = Notification.Name("JY_NetworkManager_DisconnectedChanged")
}
