//
//  JY_VerifyTextField.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/24.
//

import UIKit

open class JY_VerifyTextField: JY_View {
    
    var text: String {
        get {
            return yq_textField.text ?? ""
        }
    }
    
//    weak open var delegate: (any UITextFieldDelegate)? {
//        didSet {
//            yq_textField.delegate = delegate
//        }
//    }
    
    private lazy var yq_placeholder: String = "请输入验证码"
    private lazy var yq_font: UIFont = UIFont.yq_pingfang_sc(15 * yq_scale)
    
    private(set) lazy var yq_bgImageView: JY_ImageView = JY_ImageView()
    private(set) lazy var yq_textField: JY_TextField = JY_TextField()
}

public extension JY_VerifyTextField {
    override func yq_add_subviews() {
        super.yq_add_subviews()
        
        addSubview(yq_bgImageView)
        addSubview(yq_textField)
    }
}

public extension JY_VerifyTextField {
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        yq_textField.addTarget(target, action: action, for: controlEvents)
    }
}

public extension JY_VerifyTextField {
    func set(placeholder: String) {
        
        if yq_placeholder != placeholder {
            yq_placeholder = placeholder
            layoutIfNeeded()
        }
    }
    
    func set(font: UIFont) {
        if yq_font != font {
            yq_font = font
            layoutIfNeeded()
        }
    }
}

extension JY_VerifyTextField {
     override open func layoutSubviews() {
        super.layoutSubviews()
        
        yq_bgImageView.frame.origin = {
            yq_bgImageView.frame.size = bounds.size
            yq_bgImageView.layer.cornerRadius = yq_bgImageView.frame.height * 0.5
            yq_bgImageView.layer.masksToBounds = true
            yq_bgImageView.backgroundColor = UIColor.yq_color(hexString: "0xFEFDFE")
            return bounds.origin
        }()
        
        yq_textField.frame.origin = {
            yq_textField.keyboardType = .numberPad
            yq_textField.placeholder = yq_placeholder
            
            yq_textField.font = yq_font
            yq_textField.placeholderFont = yq_font
            
            yq_textField.textColor = UIColor.yq_color(hexString: "0x424242")
            yq_textField.placeholderColor = UIColor.yq_color(hexString: "0xBDBDBD")
            
            yq_textField.clearButtonMode = .whileEditing
            
            yq_textField.frame.size = CGSize(width: bounds.width - 20 * yq_scale * 2, height: bounds.height - 5 * yq_scale)
            yq_textField.set(scale: yq_scale)
            return CGPoint(x: (frame.width - yq_textField.frame.width) * 0.5, y: (frame.height - yq_textField.frame.height) * 0.5)
        }()
    }
}
