//
//  JY_TipHUD.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/24.
//

import UIKit

// MARK: - HUD 管理类（单例 + 线程安全 + 仅过滤连续重复）
// 修改1：加public，暴露类给外部
public final class JY_TipHUDManager {
    // 修改2：加public，暴露单例（外部核心访问入口）
    public static let shared = JY_TipHUDManager()
    // 单例私有化初始化，保持不变
    private init() {}
    
    // MARK: - 线程安全配置（核心：保证队列操作原子性）
    private let hudQueue = DispatchQueue(label: "com.jy.tip.hud.queue", attributes: .concurrent)
    
    // 修改3：加public，暴露可配置开关（外部可控制是否过滤重复）
    public var shouldFilterDuplicates: Bool = true
    
    // 内部私有队列，保持不变（外部无需访问）
    private var _hudQueue: [JY_TipHUD] = []
    var hudQueueArray: [JY_TipHUD] {
        get { hudQueue.sync { _hudQueue } }
        set { hudQueue.async(flags: .barrier) { self._hudQueue = newValue } }
    }
    
    // 内部私有显示状态，保持不变
    private var _isShowing: Bool = false
    var isShowing: Bool {
        get { hudQueue.sync { _isShowing } }
        set { hudQueue.async(flags: .barrier) { self._isShowing = newValue } }
    }
    
    // MARK: - 核心方法
    // 修改4：加public，暴露添加HUD方法（外部自定义HUD时需调用）
    public func addTipHUD(_ hud: JY_TipHUD) {
        let isContinuousDuplicate: Bool = hudQueue.sync(flags: .barrier, execute: {
            guard shouldFilterDuplicates, let lastHUD = _hudQueue.last else { return false }
            return lastHUD.taskName == hud.taskName && lastHUD.tipType == hud.tipType
        })
        
        guard !isContinuousDuplicate else {
            print("[JY_TipHUD] 过滤连续重复提示：\(hud.taskName)（类型：\(hud.tipType)）")
            return
        }
        
        hudQueueArray.append(hud)
        showNextTip()
    }
    
    /// 内部私有方法，保持不变（外部无需访问）
    private func showNextTip() {
        guard !isShowing,
              let window = UIWindow.yq_firstWindow(),
              let hud = hudQueueArray.first else {
            return
        }
        
        isShowing = true
        let scale = 1.0
        let hudSize = hud.calculateSize(scale: scale)
        
        window.addSubview(hud)
        hud.frame = CGRect(
            x: (window.bounds.width - hudSize.width) / 2,
            y: UIDevice.current.statusBarHeight(),
            width: hudSize.width,
            height: hudSize.height
        )
        hud.bringToFront()
        
        hud.performAnimation { [weak self] in
            guard let self = self else { return }
            hud.removeFromSuperview()
            hud.layer.removeAllAnimations()
            NSLayoutConstraint.deactivate(hud.constraints)
            
            self.hudQueue.async(flags: .barrier) {
                self._hudQueue.removeFirst()
                self._isShowing = false
            }
            
            self.showNextTip()
        }
    }
}

// MARK: - 核心HUD视图类（优化布局 + 适配 + 动画）
// 修改5：加public，暴露核心视图类
public final class JY_TipHUD: JY_View {
    // MARK: - 配置属性（支持自定义）
    // 修改6：加public，暴露枚举（与public属性tipType匹配访问级别）
    public enum TipType {
        case success
        case danger
    }
    // 修改7：加public，暴露可配置属性（外部自定义HUD时需设置）
    public var tipType: TipType = .success
    var taskName: String = "" // 内部使用，保持internal
    var createTime: Int = 0  // 内部使用，保持internal
    // 修改7：加public，外部可自定义动画时长
    public var animationDuration: TimeInterval = 2.25
    // 修改7：加public，外部可自定义导航栏高度（适配不同导航栏）
    public var navigationBarHeight: CGFloat = 44
    
    // MARK: - UI组件（内部私有，保持不变）
    private lazy var bgView: JY_ImageView = {
        let iv = JY_ImageView()
        iv.layer.cornerRadius = 12 * yq_scale
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
    
    // MARK: - 初始化（保持不变）
    override init(frame: CGRect) {
        super.init(frame: frame)
        yq_add_subviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI布局（内部私有，保持不变）
    override func yq_add_subviews() {
        super.yq_add_subviews()
        addSubview(bgView)
        bgView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bgView.topAnchor.constraint(equalTo: topAnchor),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: bgView.leadingAnchor, constant: 12 * yq_scale),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: bgView.trailingAnchor, constant: -12 * yq_scale),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: bgView.topAnchor, constant: 4 * yq_scale),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bgView.bottomAnchor, constant: -4 * yq_scale)
        ])
    }
    
    // MARK: - 公共方法（外部调用）
    // 修改8：加public，暴露尺寸计算方法（自定义HUD时需调用）
    public func calculateSize(scale: CGFloat) -> CGSize {
        titleLabel.text = taskName
        titleLabel.font = UIFont.systemFont(ofSize: 13 * scale)
        
        let maxWidth = 325 * scale
        let textSize = titleLabel.sizeThatFits(CGSize(
            width: maxWidth,
            height: CGFloat.greatestFiniteMagnitude
        ))
        
        return CGSize(
            width: textSize.width + 24 * scale,
            height: textSize.height + 8 * scale
        )
    }
    
    // 修改9：加public，暴露背景色类方法（外部自定义HUD时需调用）
    public class func successBgColor() -> UIColor {
        return UIColor.yq_color(hexString: "0x4DC56C")
    }
    
    public class func dangerBgColor() -> UIColor {
        return UIColor.yq_color(hexString: "0xFF4B3B")
    }
    
    // 修改10：加public，暴露动画方法（自定义HUD时需调用）
    public func performAnimation(completion: (() -> Void)? = nil) {
        weak let weakSelf = self
        
        alpha = 0.25
        
        UIView.animate(withDuration: 0.25, animations: {
            weakSelf?.alpha = 1.0
            weakSelf?.frame.origin.y = UIDevice.current.statusBarHeight() + self.navigationBarHeight
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + (weakSelf?.animationDuration ?? 2.25)) { [weak self] in
                guard let self = self else {
                    completion?()
                    return
                }
                UIView.animate(withDuration: 0.25, animations: {
                    self.alpha = 0.25
                    self.frame.origin.y = UIDevice.current.statusBarHeight()
                }) { _ in
                    self.layer.removeAllAnimations()
                    NSLayoutConstraint.deactivate(self.constraints)
                    completion?()
                }
            }
        }
    }
}

// MARK: - 快速调用扩展（核心外部调用入口）
extension JY_TipHUD {
    // 修改11：加public，暴露快速显示成功提示方法（外部最常用）
    public class func showSuccess(tip text: String) {
        guard !text.isEmpty, UIWindow.yq_firstWindow() != nil else { return }
        
        DispatchQueue.main.async {
            let hud = JY_TipHUD()
            hud.taskName = text
            hud.tipType = .success
            hud.createTime = JY_TimeTool.currentTimestamp()
            hud.bgView.backgroundColor = JY_TipHUD.successBgColor()
            JY_TipHUDManager.shared.addTipHUD(hud)
        }
    }
    
    // 修改11：加public，暴露快速显示失败提示方法
    public class func showDanger(tip text: String) {
        guard !text.isEmpty, UIWindow.yq_firstWindow() != nil else { return }
        
        DispatchQueue.main.async {
            let hud = JY_TipHUD()
            hud.taskName = text
            hud.tipType = .danger
            hud.createTime = JY_TimeTool.currentTimestamp()
            hud.bgView.backgroundColor = JY_TipHUD.dangerBgColor()
            JY_TipHUDManager.shared.addTipHUD(hud)
        }
    }
    
    // 修改11：加public，暴露全局配置方法（外部自定义动画/导航栏高度）
    public class func config(animationDuration: TimeInterval? = nil, navigationBarHeight: CGFloat? = nil) {
        let hud = JY_TipHUD()
        if let duration = animationDuration {
            hud.animationDuration = duration
        }
        if let navHeight = navigationBarHeight {
            hud.navigationBarHeight = navHeight
        }
    }
}

// MARK: - UIView 扩展（通用工具方法）
extension UIView {
    // 修改12：加public，暴露快速置顶方法（外部可复用）
    public func bringToFront() {
        superview?.bringSubviewToFront(self)
    }
    
    // 修改12：加public，暴露清理约束方法（外部可复用）
    public func clearAllConstraints() {
        NSLayoutConstraint.deactivate(constraints)
        removeConstraints(constraints)
        superview?.removeConstraints(superview?.constraints.filter {
            $0.firstItem as? UIView == self || $0.secondItem as? UIView == self
        } ?? [])
    }
}
