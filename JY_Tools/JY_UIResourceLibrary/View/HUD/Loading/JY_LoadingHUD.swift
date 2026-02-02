//
//  JY_LoadingHUD.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/24.
//

import UIKit

/// 通用加载提示HUD（单例模式，线程安全）
final class JY_LoadingHUD: UIView {
    // MARK: - 单例
    static let shared = JY_LoadingHUD()
    
    // MARK: - 全屏遮罩View（避免和系统maskView冲突）
    private lazy var jy_maskView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - 可配置属性（支持全局自定义）
    /// 加载指示器颜色（默认白色）
    var indicatorColor: UIColor = .white {
        didSet {
            activityIndicator.color = indicatorColor
        }
    }
    
    /// 提示文字颜色（默认白色）
    var textColor: UIColor = .white {
        didSet {
            textLabel.textColor = textColor
        }
    }
    
    /// 遮罩View背景色（默认透明）
    var maskBackgroundColor: UIColor {
        get { jy_maskView.backgroundColor ?? .clear }
        set { jy_maskView.backgroundColor = newValue }
    }
    
    /// 遮罩View透明度（快捷修改，基于backgroundColor的alpha）
    var maskAlpha: CGFloat {
        get { jy_maskView.backgroundColor?.cgColor.alpha ?? 0.0 }
        set {
            let currentColor = jy_maskView.backgroundColor ?? .clear
            jy_maskView.backgroundColor = currentColor.withAlphaComponent(newValue)
        }
    }
    
    /// 容器背景色（默认黑色半透明）
    var containerColor: UIColor = UIColor.black.withAlphaComponent(0.7) {
        didSet {
            containerView.backgroundColor = containerColor
        }
    }
    
    /// 遮罩层是否可点击（兼容原有属性，实际由jy_maskView拦截）
    var maskIsUserInteractionEnabled: Bool = false {
        didSet {
            jy_maskView.isUserInteractionEnabled = !maskIsUserInteractionEnabled
        }
    }
    
    /// 容器圆角（默认10pt）
    var containerCornerRadius: CGFloat = 10 {
        didSet {
            containerView.layer.cornerRadius = containerCornerRadius
            containerView.clipsToBounds = true
        }
    }
    
    // MARK: - 私有UI组件
    /// 加载指示器
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            indicator = UIActivityIndicatorView(style: .large)
        } else {
            indicator = UIActivityIndicatorView(style: .whiteLarge)
        }
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    /// 提示文字标签
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 容器视图（包裹指示器+文字）
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - 关键约束（动态切换）
    /// 指示器顶部约束（有文字时激活）
    private var indicatorTopConstraint: NSLayoutConstraint!
    /// 指示器居中约束（无文字时激活）
    private var indicatorCenterYConstraint: NSLayoutConstraint!
    /// 文字标签高度约束（无文字时设为0）
    private var textLabelHeightConstraint: NSLayoutConstraint!
    /// 文字标签顶部约束（有文字时激活）
    private var textLabelTopConstraint: NSLayoutConstraint!
    
    // MARK: - 初始化
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupDynamicConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI布局
    private func setupUI() {
        // HUD自身透明，不拦截交互
        backgroundColor = .clear
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        
        // 添加子视图
        addSubview(containerView)
        containerView.addSubview(activityIndicator)
        containerView.addSubview(textLabel)
        
        // 容器视图基础约束（居中，最小宽高）
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
        
        // 指示器基础约束（居中X）
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 40),
            activityIndicator.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // 文字标签基础约束（左右间距）
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - 动态约束配置（核心：根据文字切换布局）
    private func setupDynamicConstraints() {
        // 1. 指示器顶部约束（有文字时激活）
        indicatorTopConstraint = activityIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20)
        indicatorTopConstraint.priority = .defaultHigh
        
        // 2. 指示器居中Y约束（无文字时激活）
        indicatorCenterYConstraint = activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        indicatorCenterYConstraint.priority = .required
        indicatorCenterYConstraint.isActive = false // 默认禁用
        
        // 3. 文字标签顶部约束（有文字时激活）
        textLabelTopConstraint = textLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10)
        textLabelTopConstraint.isActive = false // 默认禁用
        
        // 4. 文字标签高度约束（无文字时设为0）
        textLabelHeightConstraint = textLabel.heightAnchor.constraint(equalToConstant: 0)
        textLabelHeightConstraint.priority = .required
        textLabelHeightConstraint.isActive = true // 默认激活（无文字时高度0）
    }
    
    // MARK: - 布局切换方法（根据文字是否为空）
    private func updateLayout(withText text: String?) {
        let hasText = text != nil && !text!.isEmpty
        
        // 1. 切换文字标签状态
        textLabel.isHidden = !hasText
        textLabelHeightConstraint.isActive = !hasText // 无文字时高度0，有文字时取消高度限制
        textLabelTopConstraint.isActive = hasText     // 有文字时激活顶部约束
        
        // 2. 切换指示器约束
        indicatorTopConstraint.isActive = hasText       // 有文字时：指示器靠上
        indicatorCenterYConstraint.isActive = !hasText  // 无文字时：指示器居中
        
        // 3. 刷新布局
        containerView.layoutIfNeeded()
    }
    
    // MARK: - 公开方法
    /// 显示纯加载动画的HUD（无文字）
    func show() {
        show(withText: nil)
    }
    
    /// 显示带文字的HUD
    /// - Parameter text: 提示文字（nil则隐藏文字标签）
    func show(withText text: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 修复核心：重新启动指示器动画
            self.activityIndicator.startAnimating()
            
            // 避免重复显示
            guard self.jy_maskView.superview == nil else {
                // 更新文字和布局
                if let text = text {
                    self.textLabel.text = text
                }
                self.updateLayout(withText: text)
                return
            }
            
            // 配置文字
            self.textLabel.text = text
            // 切换布局（核心）
            self.updateLayout(withText: text)
            
            guard let keyWindow = UIWindow.yq_firstWindow() else {
                return
            }
            
            // 添加遮罩View并设置约束
            keyWindow.addSubview(self.jy_maskView)
            keyWindow.bringSubviewToFront(self.jy_maskView)
            NSLayoutConstraint.activate([
                self.jy_maskView.leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor),
                self.jy_maskView.trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor),
                self.jy_maskView.topAnchor.constraint(equalTo: keyWindow.topAnchor),
                self.jy_maskView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor)
            ])
            
            // 添加HUD到遮罩View并设置约束
            self.jy_maskView.addSubview(self)
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: self.jy_maskView.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: self.jy_maskView.trailingAnchor),
                self.topAnchor.constraint(equalTo: self.jy_maskView.topAnchor),
                self.bottomAnchor.constraint(equalTo: self.jy_maskView.bottomAnchor)
            ])
            
            // 显示动画
            self.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: 0.25) {
                self.alpha = 1
                self.containerView.transform = .identity
            }
        }
    }
    
    /// 隐藏HUD
    /// - Parameter animated: 是否开启动画（默认true）
    func hide(animated: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.jy_maskView.superview != nil else { return }
            
            if animated {
                UIView.animate(withDuration: 0.25, animations: {
                    self.alpha = 0
                    self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }) { _ in
                    self.activityIndicator.stopAnimating()
                    self.removeFromSuperview()
                    self.jy_maskView.removeFromSuperview()
                    self.containerView.transform = .identity
                }
            } else {
                self.activityIndicator.stopAnimating()
                self.removeFromSuperview()
                self.jy_maskView.removeFromSuperview()
            }
        }
    }
    
    /// 延迟隐藏HUD
    /// - Parameters:
    ///   - delay: 延迟时间（秒）
    ///   - animated: 是否开启动画（默认true）
    func hide(afterDelay delay: TimeInterval, animated: Bool = true) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.hide(animated: animated)
        }
    }
}

// MARK: - 便捷调用扩展（简化使用）
extension JY_LoadingHUD {
    static func show() {
        shared.show()
    }
    
    static func show(withText text: String) {
        shared.show(withText: text)
    }
    
    static func hide(animated: Bool = true) {
        shared.hide(animated: animated)
    }
    
    static func hide(afterDelay delay: TimeInterval, animated: Bool = true) {
        shared.hide(afterDelay: delay, animated: animated)
    }
    
    static func setMaskBackgroundColor(_ color: UIColor) {
        shared.maskBackgroundColor = color
    }
    
    static func setMaskAlpha(_ alpha: CGFloat) {
        shared.maskAlpha = alpha
    }
    
    static func configMaskView(color: UIColor, alpha: CGFloat) {
        shared.maskBackgroundColor = color.withAlphaComponent(alpha)
    }
}

//  MARK: 使用示例
/**
 // 1. 基础使用（默认透明遮罩，拦截交互）
 JY_LoadingHUD.show(withText: "加载中...")

 // 2. 动态修改遮罩背景色（半透明黑色）
 JY_LoadingHUD.setMaskBackgroundColor(UIColor.black.withAlphaComponent(0.3))

 // 3. 动态修改遮罩透明度（0.5）
 JY_LoadingHUD.setMaskAlpha(0.5)

 // 4. 一键配置遮罩样式（白色背景+0.2透明度）
 JY_LoadingHUD.configMaskView(color: .white, alpha: 0.2)

 // 5. 加载完成后隐藏
 DispatchQueue.global().async {
     Thread.sleep(forTimeInterval: 3)
     DispatchQueue.main.async {
         JY_LoadingHUD.hide() // 修复笔误：AHA_LoadingHUD → JY_LoadingHUD
     }
 }

 // 6. 显示后再修改遮罩样式（后期动态调整）
 JY_LoadingHUD.show(withText: "动态修改样式")
 DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
     // 1秒后改为红色半透明遮罩
     JY_LoadingHUD.setMaskBackgroundColor(UIColor.red.withAlphaComponent(0.1))
 }
 */
