//
//  JY_Base_MineMessageCell.swift
//  ThePowerOfTheGreat
//
//  Created by ThePowerOfTheGreat on 2025/12/26.
//

import UIKit

open class JY_Base_MineMessageCell: JY_Base_MineCell {
    
    public private(set) lazy var yq_count: Int = 0
    
    public private(set) lazy var yq_message_count_label: JY_Label = JY_Label()
    public private(set) lazy var yq_message_count_bgImageView: JY_ImageView = JY_ImageView()
}

extension JY_Base_MineMessageCell {
    open override func yq_add_subviews() {
        super.yq_add_subviews()
        
        addSubview(yq_message_count_bgImageView)
        yq_message_count_bgImageView.addSubview(yq_message_count_label)
    }
}

extension JY_Base_MineMessageCell {
    public func set(count: Int) {
        yq_count = count
        yq_message_count_label.text = count > 99 ? "99+" : "\(count)"
        yq_message_count_bgImageView.isHidden = count <= 0
        layoutSubviews()
    }
}

extension JY_Base_MineMessageCell {
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        yq_message_count_label_frame()
        yq_message_count_bgImageView_frame()
    }
    
    private func yq_message_count_label_frame() {
        yq_message_count_label.font = UIFont.yq_pingfang_tc_bold(12 * yq_scale)
        yq_message_count_label.textColor = UIColor.yq_color(hexString: "0xFAFAFB")
        yq_message_count_label.sizeToFit()
    }
    
    private func yq_message_count_bgImageView_frame() {
        
        let width = yq_message_count_label.frame.width + 8 * yq_scale
        let height = yq_message_count_label.frame.height + 4 * yq_scale
        
        yq_message_count_bgImageView.frame.size = CGSize(width: width > height ? width : height, height: height)
        yq_message_count_bgImageView.layer.cornerRadius = yq_message_count_bgImageView.frame.height * 0.5
        yq_message_count_bgImageView.layer.masksToBounds = true
        yq_message_count_bgImageView.backgroundColor = UIColor.yq_color(hexString: "0x4CBAFF")
        
        yq_message_count_bgImageView.frame.origin = CGPoint(x: yq_arrow_imageView.frame.minX - yq_message_count_bgImageView.frame.width - 6 * yq_scale, y: yq_arrow_imageView.frame.midY - yq_message_count_bgImageView.frame.height * 0.5)
        
        yq_message_count_label.frame.origin = CGPoint(x: (yq_message_count_bgImageView.frame.width - yq_message_count_label.frame.width) * 0.5, y: (yq_message_count_bgImageView.frame.height - yq_message_count_label.frame.height) * 0.5)
    }
}
