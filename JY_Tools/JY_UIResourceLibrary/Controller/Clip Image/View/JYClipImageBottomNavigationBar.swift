//
//  JYClipImageBottomNavigationBar.swift
//  JYClipImageController
//
//  Created by JYYQLin on 2025/12/8.
//

import UIKit

class JYClipImageBottomNavigationBar: JY_View {
    
    private lazy var yq_cancel_button: JY_Button = JY_Button()
    private lazy var yq_done_button: JY_Button = JY_Button()
    
    private lazy var yq_underLine_view: JY_ImageView = JY_ImageView()

}

extension JYClipImageBottomNavigationBar {
    override func yq_add_subviews() {
        super.yq_add_subviews()
        
        addSubview(yq_cancel_button)
        addSubview(yq_done_button)
        
        addSubview(yq_underLine_view)
    }
}

extension JYClipImageBottomNavigationBar {
    func yq_cancel_button_add_target(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        yq_cancel_button.addTarget(target, action: action, for: controlEvents)
    }
    
    func yq_done_button_add_target(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        yq_done_button.addTarget(target, action: action, for: controlEvents)
    }
}

extension JYClipImageBottomNavigationBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        yq_underLine_view.frame.origin = {
            yq_underLine_view.frame.size = CGSize(width: frame.width, height: 1 / UIScreen.main.scale)
            yq_underLine_view.backgroundColor = UIColor.yq_color(red: 240, green: 240, blue: 240)
            return CGPoint(x: 0, y: 2 * yq_scale)
        }()
        
        yq_cancel_button.frame.origin = {
            yq_cancel_button.frame.size = CGSize(width: frame.height, height: frame.height)
            yq_cancel_button.setTitle("取消", for: .normal)
            yq_cancel_button.setTitleColor(UIColor.colorFAFAFB, for: .normal)
            yq_cancel_button.titleLabel?.font = UIFont.yq_pingfang_sc_medium(13 * yq_scale)
            
            return CGPoint(x: 5 * yq_scale, y: (frame.height - yq_cancel_button.frame.height) * 0.5)
        }()
        
        yq_done_button.frame.origin = {
            yq_done_button.frame.size = CGSize(width: frame.height, height: frame.height)
            yq_done_button.setTitle("确定", for: .normal)
            yq_done_button.setTitleColor(UIColor.colorFAFAFB, for: .normal)
            yq_done_button.titleLabel?.font = UIFont.yq_pingfang_sc_medium(13 * yq_scale)
            
            return CGPoint(x: frame.width - yq_done_button.frame.width - yq_cancel_button.frame.minX, y: yq_cancel_button.frame.midY - yq_done_button.frame.height * 0.5)
        }()
    }
}
