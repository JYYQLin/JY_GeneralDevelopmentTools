//
//  JY_ContentTextView_TextCount.swift
//  ThePowerOfTheGreat
//
//  Created by ThePowerOfTheGreat on 2025/12/29.
//

import UIKit

open class JY_ContentTextView_TextCount: JY_View {
    
    public var yq_textView_did_change_block: (() -> Void)?
    
    public lazy var yq_placeholder: String = "请填写您的反馈意见或问题，每一条我们都会认真查看（\(yq_max_text_count)字以内）"
    public lazy var yq_max_text_count: Int = 500
    public lazy var yq_bg_color: UIColor = UIColor.yq_color(hexString: "0xFEFDFE")
    public lazy var yq_tip_text_color: UIColor = UIColor.yq_color(hexString: "0x9E9E9E")
    
    public var text: String {
        get {
            return yq_textView.text
        }
    }
    
    public lazy var yq_bg_imageView: JY_ImageView = JY_ImageView()
    public lazy var yq_textView: UITextView = UITextView()
    public lazy var yq_tip_label: JY_Label = JY_Label()
}


public extension JY_ContentTextView_TextCount {
    func set(maxTextCount: Int) {
        yq_max_text_count = maxTextCount
        layoutSubviews()
    }
    
    func set(bgColor: UIColor) {
        yq_bg_color = bgColor
        layoutSubviews()
    }
    
    func set(tipTextColor: UIColor) {
        yq_tip_text_color = tipTextColor
        layoutSubviews()
    }
    
    func set(placeholder: String) {
        yq_placeholder = placeholder
        layoutSubviews()
    }
    
    func set(text: String) {
        yq_textView.text = text
        yq_tip_label_frame()
        yq_textView_did_change_block?()
    }
    
    func yq_add(text: String) {
        yq_textView.text = yq_textView.text + text
        yq_tip_label_frame()
        yq_textView_did_change_block?()
    }
    
    func yq_becomeFirstResponder() {
        yq_textView.becomeFirstResponder()
    }
    
    func yq_clear() {
        yq_textView.text = ""
        yq_tip_label_frame()
        yq_textView_did_change_block?()
    }
    
    func set(keyboardType: UIKeyboardType) {
        yq_textView.keyboardType = keyboardType
    }
}

extension JY_ContentTextView_TextCount {
   open override func yq_add_subviews() {
        super.yq_add_subviews()
        
        addSubview(yq_bg_imageView)
        addSubview(yq_textView)
        addSubview(yq_tip_label)
        
        yq_textView.delegate = self
    }
}

extension JY_ContentTextView_TextCount {
   open override func layoutSubviews() {
        super.yq_add_subviews()
        
        yq_bg_imageView_frame()
        yq_tip_label_frame()
        yq_textView_frame()
    }
    
    private func yq_bg_imageView_frame() {
        yq_bg_imageView.frame.size = bounds.size
        yq_bg_imageView.backgroundColor = yq_bg_color
        yq_bg_imageView.layer.cornerRadius = 24 * yq_scale
        yq_bg_imageView.layer.masksToBounds = true
        yq_bg_imageView.frame.origin = bounds.origin
    }
    
    private func yq_tip_label_frame() {
        yq_tip_label.font = UIFont.yq_din_alternate(13 * yq_scale)
        yq_tip_label.textColor = text.count > yq_max_text_count ? UIColor.yq_color(hexString: "0xFF2442") :  yq_tip_text_color
        yq_tip_label.text = "\(text.count)/\(yq_max_text_count)"
        yq_tip_label.sizeToFit()
        yq_tip_label.isHidden = yq_max_text_count <= 0
        yq_tip_label.frame.origin = CGPoint(x: frame.width - yq_tip_label.frame.width - 20 * yq_scale, y: frame.height - yq_tip_label.frame.height - 10 * yq_scale)
    }
    
    private func yq_textView_frame() {
        yq_textView.frame.size = CGSize(width: frame.width - 16 * yq_scale * 2, height: yq_tip_label.frame.minY - 12 * yq_scale * 2)
        
        yq_textView.font = UIFont.yq_pingfang_sc(14 * yq_scale)
        yq_textView.textColor = UIColor.yq_color(hexString: "0x212121")
        yq_textView.placeholderColor = UIColor.yq_color(hexString: "0x9E9E9E")
        
        yq_textView.placeholder = yq_placeholder
        
        yq_textView.backgroundColor = UIColor.clear
        
        yq_textView.frame.origin = CGPoint(x: (frame.width - yq_textView.frame.width) * 0.5, y: 11 * yq_scale)
    }
}

extension JY_ContentTextView_TextCount: UITextViewDelegate {
   public func textViewDidChange(_ textView: UITextView) {
        yq_tip_label_frame()
        yq_textView_did_change_block?()
    }
}
