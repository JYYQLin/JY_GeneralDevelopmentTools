//
//  JY_NavigationController.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/24.
//

import UIKit

open class JY_NavigationController: UINavigationController {
    
    private lazy var yq_light_preferredStatusBarStyle: Bool = false
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return yq_light_preferredStatusBarStyle == true ? .lightContent : .darkContent
        }
    }
}

extension JY_NavigationController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        yq_remake_popGestureRecognizer()
    }
}

extension JY_NavigationController {
    /**
        修改状态栏模式
     isLight: true表示lightContent, false表示darkContent
     */
    @objc dynamic open func yq_light_preferredStatusBarStyle(_ isLight: Bool) {
        yq_light_preferredStatusBarStyle = isLight
        setNeedsStatusBarAppearanceUpdate()
    }
}



// MARK: - 交互事件
extension JY_NavigationController {
    @objc fileprivate func yq_back_click() {
        view.endEditing(true)
        _ = popViewController(animated: true)
    }
}

// MARK: - 恢复边缘滑动返回手势
extension JY_NavigationController : UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return children.count != 1
    }
    
    /// 设置滑动手势
    fileprivate func yq_remake_popGestureRecognizer() {
        interactivePopGestureRecognizer?.delegate = self as UIGestureRecognizerDelegate
    }
}


// MARK: 导航条样式相关
extension JY_NavigationController {
    
//    /// 重写pushViewController
//    /*
//     统一设置返回按钮图片
//     统一设置push后隐藏TabBar
//     */
//    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
//        if children.isEmpty == false {
//            NotificationCenter.default.post(name: NSNotification.Name(JY_NotificationName_TabBar_Hidden), object: nil)
//            viewController.hidesBottomBarWhenPushed = true
//
//            let backButton = UIButton(type: .custom)
//            backButton.setImage(UIImage(named: JY_NavigationController.yq_normal_back_imageName()), for: .normal)
//            backButton.setImage(UIImage(named: JY_NavigationController.yq_normal_back_imageName()), for: .highlighted)
//            backButton.sizeToFit()
//            backButton.addTarget(self, action: #selector(yq_back_click), for: .touchUpInside)
//
//            let view = UIView(frame:backButton.frame)
//            view.addSubview(backButton)
//
//            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
//        }
//        super.pushViewController(viewController, animated: animated)
//    }
}
