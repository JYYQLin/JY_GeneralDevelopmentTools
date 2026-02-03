//
//  JY_TipHUD.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/24.
//

import UIKit

// MARK: - HUD 管理类（单例 + 线程安全 + 仅过滤连续重复）
final class JY_TipHUDManager {
    // 单例
    static let shared = JY_TipHUDManager()
    private init() {}
    
    // MARK: - 线程安全配置（核心：保证队列操作原子性）
    private let hudQueue = DispatchQueue(label: "com.jy.tip.hud.queue", attributes: .concurrent)
    
    /// 是否过滤重复提示（默认开启，符合你要求）
    var shouldFilterDuplicates: Bool = true
    
    // 线程安全的HUD队列
    private var _hudQueue: [JY_TipHUD] = []
    var hudQueueArray: [JY_TipHUD] {
        get { hudQueue.sync { _hudQueue } }
        set { hudQueue.async(flags: .barrier) { self._hudQueue = newValue } }
    }
    
    // 线程安全的显示状态
    private var _isShowing: Bool = false
    var isShowing: Bool {
        get { hudQueue.sync { _isShowing } }
        set { hudQueue.async(flags: .barrier) { self._isShowing = newValue } }
    }
    
    // MARK: - 核心方法
    /// 添加HUD到队列（核心优化：仅过滤连续的相同内容+类型）
    func addTipHUD(_ hud: JY_TipHUD) {
        // 原子性判断：仅队列最后一个是否是【相同内容+相同类型】（连续重复才过滤）
        let isContinuousDuplicate: Bool = hudQueue.sync(flags: .barrier, execute: {
            guard shouldFilterDuplicates, let lastHUD = _hudQueue.last else { return false }
            // 核心修改：仅判断最后一个元素（连续重复）
            return lastHUD.taskName == hud.taskName && lastHUD.tipType == hud.tipType
        })
        
        // 过滤重复：仅连续的相同内容+类型才返回
        guard !isContinuousDuplicate else {
            print("[JY_TipHUD] 过滤连续重复提示：\(hud.taskName)（类型：\(hud.tipType)）")
            return
        }
        
        // 非连续重复则添加到队列
        hudQueueArray.append(hud)
        // 尝试显示下一个
        showNextTip()
    }
    
    /// 显示队列中的下一个HUD（优化布局 + 容错）
    private func showNextTip() {
        // 容错：显示中/队列为空/无window，直接返回
        guard !isShowing,
              let window = UIWindow.yq_firstWindow(),
              let hud = hudQueueArray.first else {
            return
        }
        
        isShowing = true
        // 1. 计算HUD尺寸（适配缩放比）
//        let scale = window.bounds.width / 375.0
        let scale = 1.0
        let hudSize = hud.calculateSize(scale: scale)
        
        // 2. 添加到Window并设置初始位置（优化Frame设置，避免布局冲突）
        window.addSubview(hud)
        hud.frame = CGRect(
            x: (window.bounds.width - hudSize.width) / 2,
            y: UIDevice.current.statusBarHeight(), // 初始在状态栏高度
            width: hudSize.width,
            height: hudSize.height
        )
        hud.bringToFront() // 置顶显示
        
        // 3. 执行动画，完成后处理队列
        hud.performAnimation { [weak self] in
            guard let self = self else { return }
            // 清理当前HUD（移除视图+约束+动画）
            hud.removeFromSuperview()
            hud.layer.removeAllAnimations()
            NSLayoutConstraint.deactivate(hud.constraints)
            
            // 原子性更新队列和状态
            self.hudQueue.async(flags: .barrier) {
                self._hudQueue.removeFirst()
                self._isShowing = false
            }
            
            // 显示队列中的下一个
            self.showNextTip()
        }
    }
}

// MARK: - 核心HUD视图类（优化布局 + 适配 + 动画）
final class JY_TipHUD: JY_View {
    // MARK: - 配置属性（支持自定义）
    /// 提示类型（区分成功/失败）
    enum TipType {
        case success
        case danger
    }
    /// 当前提示类型
    var tipType: TipType = .success
    /// 提示文本
    var taskName: String = ""
    /// 创建时间戳
    var createTime: Int = 0
    /// 动画时长（默认2.25秒，支持自定义）
    var animationDuration: TimeInterval = 2.25
    /// 导航栏高度（默认44pt，支持自定义）
    var navigationBarHeight: CGFloat = 44
    
    // MARK: - UI组件（优化适配 + 懒加载）
    private lazy var bgView: JY_ImageView = {
        let iv = JY_ImageView()
        iv.layer.cornerRadius = 12 * yq_scale // 适配缩放比
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var titleLabel: JY_Label = {
        let label = JY_Label()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.yq_color(hexString: "0xFAFAFB")
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        yq_add_subviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI布局（优化适配 + 统一缩放比）
    override func yq_add_subviews() {
        super.yq_add_subviews()
        addSubview(bgView)
        bgView.addSubview(titleLabel)
        
        // AutoLayout约束（全适配缩放比，解决不同屏幕显示不一致）
        NSLayoutConstraint.activate([
            // 背景图全屏覆盖HUD
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bgView.topAnchor.constraint(equalTo: topAnchor),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // 文字标签居中，内边距适配缩放比
            titleLabel.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: bgView.leadingAnchor, constant: 12 * yq_scale),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: bgView.trailingAnchor, constant: -12 * yq_scale),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: bgView.topAnchor, constant: 4 * yq_scale),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bgView.bottomAnchor, constant: -4 * yq_scale)
        ])
    }
    
    /// 计算HUD尺寸（优化文字尺寸计算 + 适配缩放比）
    func calculateSize(scale: CGFloat) -> CGSize {
        titleLabel.text = taskName
        titleLabel.font = UIFont.systemFont(ofSize: 13 * scale)
        
        // 计算文字尺寸（最大宽度325pt适配，乘缩放比）
        let maxWidth = 325 * scale
        let textSize = titleLabel.sizeThatFits(CGSize(
            width: maxWidth,
            height: CGFloat.greatestFiniteMagnitude
        ))
        
        // HUD尺寸 = 文字尺寸 + 内边距（乘缩放比，保证适配）
        return CGSize(
            width: textSize.width + 24 * scale,  // 12*2
            height: textSize.height + 8 * scale  // 4*2
        )
    }
    
    // MARK: - 样式配置（简化 + 可扩展）
    /// 成功背景色
    class func successBgColor() -> UIColor {
        return UIColor.yq_color(hexString: "0x4DC56C")
    }
    
    /// 失败/危险背景色
    class func dangerBgColor() -> UIColor {
        return UIColor.yq_color(hexString: "0xFF4B3B")  
    }
    
    // MARK: - 动画逻辑（优化内存 + 适配自定义导航栏高度）
    func performAnimation(completion: (() -> Void)? = nil) {
        weak let weakSelf = self
        
        // 初始状态：透明 + 状态栏位置
        alpha = 0.25
        
        // 第一步：显示动画（上移到导航栏下方 + 淡入）
        UIView.animate(withDuration: 0.25, animations: {
            weakSelf?.alpha = 1.0
            // 适配自定义导航栏高度
            weakSelf?.frame.origin.y = UIDevice.current.statusBarHeight() + self.navigationBarHeight
        }) { _ in
            // 保持状态后执行隐藏动画
            DispatchQueue.main.asyncAfter(deadline: .now() + (weakSelf?.animationDuration ?? 2.25)) { [weak self] in
                guard let self = self else {
                    completion?()
                    return
                }
                // 第二步：隐藏动画（下移回状态栏位置 + 淡出）
                UIView.animate(withDuration: 0.25, animations: {
                    self.alpha = 0.25
                    self.frame.origin.y = UIDevice.current.statusBarHeight()
                }) { _ in
                    // 彻底清理动画和约束
                    self.layer.removeAllAnimations()
                    NSLayoutConstraint.deactivate(self.constraints)
                    completion?()
                }
            }
        }
    }
}

// MARK: - 快速调用扩展（优化容错 + 简化调用）
extension JY_TipHUD {
    /// 显示成功提示（仅连续的相同内容+类型才过滤）
    class func showSuccess(tip text: String) {
        // 容错：空文本/无window直接返回
        guard !text.isEmpty, UIWindow.yq_firstWindow() != nil else { return }
        
        DispatchQueue.main.async {
            let hud = JY_TipHUD()
            hud.taskName = text
            hud.tipType = .success // 绑定成功类型
            hud.createTime = JY_TimeTool.currentTimestamp()
            hud.bgView.backgroundColor = JY_TipHUD.successBgColor()
            JY_TipHUDManager.shared.addTipHUD(hud)
        }
    }
    
    /// 显示失败/危险提示（仅连续的相同内容+类型才过滤）
    class func showDanger(tip text: String) {
        guard !text.isEmpty, UIWindow.yq_firstWindow() != nil else { return }
        
        DispatchQueue.main.async {
            let hud = JY_TipHUD()
            hud.taskName = text
            hud.tipType = .danger // 绑定失败类型
            hud.createTime = JY_TimeTool.currentTimestamp()
            hud.bgView.backgroundColor = JY_TipHUD.dangerBgColor()
            JY_TipHUDManager.shared.addTipHUD(hud)
        }
    }
    
    /// 自定义配置（如动画时长、导航栏高度）
    class func config(animationDuration: TimeInterval? = nil, navigationBarHeight: CGFloat? = nil) {
        let hud = JY_TipHUD()
        if let duration = animationDuration {
            hud.animationDuration = duration
        }
        if let navHeight = navigationBarHeight {
            hud.navigationBarHeight = navHeight
        }
    }
}

// MARK: - UIView 扩展（快速置顶 + 约束清理）
extension UIView {
    func bringToFront() {
        superview?.bringSubviewToFront(self)
    }
    
    /// 清理所有约束（避免残留）
    func clearAllConstraints() {
        NSLayoutConstraint.deactivate(constraints)
        removeConstraints(constraints)
        superview?.removeConstraints(superview?.constraints.filter {
            $0.firstItem as? UIView == self || $0.secondItem as? UIView == self
        } ?? [])
    }
}
