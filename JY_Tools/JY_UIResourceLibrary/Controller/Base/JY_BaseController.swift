//
//  JY_BaseController.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/22.
//

import UIKit

public enum JY_ControllerState: CustomStringConvertible {
    case yq_default
    /** 显示内容 */
    case showContent
    /** 显示请求 */
    case showLoading
    /** 显示状态 */
    case showStatus
    
    public var description: String {
        switch self {
        case .yq_default: "默认状态"
        case .showContent: "显示内容"
        case .showStatus: "显示状态"
        case .showLoading: "显示请求"
        }
    }
}

open class JY_BaseController: UIViewController {
    
    /** 状态栏颜色 */
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    //  MARK: 控制器 - 状态
    /** 控制器状态 */
    public private(set) var yq_status: JY_ControllerState = .yq_default
    open func set(status: JY_ControllerState) {
        if yq_status != status {
            yq_status = status
            yq_controllerStatusChange()
        }
    }
    
    private func yq_controllerStatusChange() {
        if yq_status == .showLoading {
            
            yq_show_loadingView()
        }else if yq_status == .showContent || yq_status == .yq_default {
            
            yq_show_contentView()
        }else if yq_status == .showStatus {
            
            yq_show_statusView()
        }
    }
    
    //  MARK: 控制器 - 缩放比例
    /** 控制器 - 缩放比例 */
    public private(set) var yq_scale: CGFloat = 1.0
    open func set(scale: CGFloat) {
        if yq_scale != scale {
            yq_scale = scale
            yq_layoutSubviews()
        }
    }
    
    //  MARK: 控制器 - 基础界面
    /** 内容容器 */
    public private(set) var yq_contentView: JY_View = JY_View()
    /** 背景容器 */
    public private(set) var yq_backgroundView: JY_View = JY_View()
    /** 状态容器 */
    public private(set) var yq_status_contentView: JY_View = JY_View()
    /** 请求容器 */
    public private(set) var yq_loading_contentView: JY_View = JY_View()
    //  用于解决,左滑返回于scrollView等控件左右滑动冲突,牺牲左侧宽度10的所有事件
    private(set) var yq_leftTapView: JY_View = JY_View()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//  MARK: 生命周期
public extension JY_BaseController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        yq_setInterface()
        yq_setNavigationBar()
    }
    
    //    override open func viewWillLayoutSubviews() {
    //        super.viewWillLayoutSubviews()
    //
    //        setSubviewsFrame()
    //    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        yq_layoutSubviews()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
}

public extension JY_BaseController {
    @objc dynamic open func yq_retry_request_click() {
        set(status: .showLoading)
    }
}

public extension JY_BaseController {
    public func yq_request_loading_addSubview(_ view: UIView) {
        for subView in yq_loading_contentView.subviews {
            subView.removeFromSuperview()
        }
        
        yq_loading_contentView.addSubview(view)
    }
    
    public func yq_status_addSubview(_ view: UIView) {
        for subView in yq_status_contentView.subviews {
            subView.removeFromSuperview()
        }
        
        yq_status_contentView.addSubview(view)
    }
}

public extension JY_BaseController {
    @objc dynamic open func yq_setInterface() {
        
        view.addSubview(yq_backgroundView)
        yq_backgroundView.isUserInteractionEnabled = false
        
        view.addSubview(yq_status_contentView)
        yq_status_contentView.isHidden = true
        
        view.addSubview(yq_loading_contentView)
        yq_loading_contentView.isUserInteractionEnabled = false
        yq_loading_contentView.isHidden = true
        
        view.addSubview(yq_contentView)
    }
    
    @objc dynamic open func yq_setNavigationBar() {
        
        view.addSubview(yq_leftTapView)
    }
    
    @objc dynamic open func yq_layoutSubviews() {
        
        yq_backgroundView.frame = view.bounds
        yq_contentView.frame = view.bounds
        
        yq_loading_contentView.frame = view.bounds
        yq_loading_contentView.set(scale: yq_scale)
        
        yq_status_contentView.frame = view.bounds
        yq_status_contentView.set(scale: yq_scale)
        
        yq_leftTapView.frame = CGRect(x: 0, y: UIDevice.current.navigationBarMaxY(), width: 15 * yq_scale, height: view.frame.height - UIDevice.current.navigationBarMaxY())
    }
}

extension JY_BaseController {
    @objc open func yq_show_loadingView() {
        yq_contentView.isHidden = true
        yq_status_contentView.isHidden = true
        yq_loading_contentView.isHidden = false
    }
    
    @objc open func yq_show_contentView() {
        yq_loading_contentView.isHidden = true
        yq_contentView.isHidden = false
        yq_status_contentView.isHidden = true
    }
    
    @objc open func yq_show_statusView() {
        yq_contentView.isHidden = true
        yq_status_contentView.isHidden = false
        yq_loading_contentView.isHidden = true
    }
}

public extension JY_BaseController {
    class func yq_ID() -> String {
        let name = ("\(self)" + "\(#function)")
        return name.yq_sha256()
    }
    
    var className: String {
        return String(describing: type(of: self))
    }
}
