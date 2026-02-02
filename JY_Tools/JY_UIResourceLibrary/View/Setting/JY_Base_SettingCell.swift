//
//  JY_Base_SettingCell.swift
//  ThePowerOfTheGreat
//
//  Created by ThePowerOfTheGreat on 2025/12/29.
//

import UIKit

class JY_Base_SettingCell: JY_BaseTableViewCell {
    
    open override func setSelected(_ selected: Bool, animated: Bool) {}
    open override func setHighlighted(_ highlighted: Bool, animated: Bool) {}
    
    private(set) lazy var yq_title_label: JY_Label = JY_Label()
    private(set) lazy var yq_arrow_imageView: JY_ImageView = JY_ImageView()
}

extension JY_Base_SettingCell {
    open override func yq_add_subviews() {
        super.yq_add_subviews()
        
        contentView.addSubview(yq_title_label)
        contentView.addSubview(yq_arrow_imageView)
    }
}

extension JY_Base_SettingCell {
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        yq_title_label_frame()
        yq_arrow_imageView_frame()
    }
    
    public func yq_title_label_frame() {
        yq_title_label.frame.origin = {
            yq_title_label.font = UIFont.yq_pingfang_sc_medium(13 * yq_scale)
            yq_title_label.textColor = UIColor.color424242
            yq_title_label.sizeToFit()
            return CGPoint(x: 25 * yq_scale, y: (contentView.frame.height - yq_title_label.frame.height) * 0.5)
        }()
    }
    
    public func yq_arrow_imageView_frame() {
        yq_arrow_imageView.frame.origin = {
            yq_arrow_imageView.frame.size = CGSize(width: 18 * yq_scale, height: 18 * yq_scale)
            yq_arrow_imageView.yq_imageName = "fe7c9cd3cd0203d7485017d7fa496160"
            return CGPoint(x: contentView.frame.width - yq_arrow_imageView.frame.width - yq_title_label.frame.minX, y: (contentView.frame.height - yq_arrow_imageView.frame.height) * 0.5)
        }()
    }
}

extension JY_Base_SettingCell {
    
    func set(title: String) {
        if yq_title_label.text != title {
            yq_title_label.text = title
            yq_title_label_frame()
        }
    }
}
