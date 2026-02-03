//
//  JY_Base_MineCell.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/23.
//

import UIKit

open class JY_Base_MineCell: JY_BaseTableViewCell {
    
    open override func setSelected(_ selected: Bool, animated: Bool) {}
    open override func setHighlighted(_ highlighted: Bool, animated: Bool) {}
    
    public lazy var yq_icon_imageView: JY_ImageView = JY_ImageView()
    public lazy var yq_title_label: JY_Label = JY_Label()
    public lazy var yq_arrow_imageView: JY_ImageView = JY_ImageView()
}

extension JY_Base_MineCell {
    open override func yq_add_subviews() {
        super.yq_add_subviews()
        
        contentView.addSubview(yq_icon_imageView)
        contentView.addSubview(yq_title_label)
        contentView.addSubview(yq_arrow_imageView)
    }
}

extension JY_Base_MineCell {
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        yq_icon_imageView_frame()
        yq_title_label_frame()
        yq_arrow_imageView_frame()
    }
    
    public func yq_icon_imageView_frame() {
        yq_icon_imageView.frame.origin = {
            yq_icon_imageView.frame.size = CGSize(width: 20 * yq_scale, height: 20 * yq_scale)
            return CGPoint(x: 30 * yq_scale, y: (contentView.frame.height - yq_icon_imageView.frame.height) * 0.5)
        }()
    }
    
    public func yq_title_label_frame() {
        yq_title_label.frame.origin = {
            yq_title_label.font = UIFont.yq_pingfang_sc(13 * yq_scale)
            yq_title_label.textColor = UIColor.yq_color(hexString: "0x424242")
            yq_title_label.sizeToFit()
            return CGPoint(x: yq_icon_imageView.frame.maxX + 15 * yq_scale, y: (contentView.frame.height - yq_title_label.frame.height) * 0.5)
        }()
    }
    
    public func yq_arrow_imageView_frame() {
        yq_arrow_imageView.frame.origin = {
            yq_arrow_imageView.frame.size = CGSize(width: 18 * yq_scale, height: 18 * yq_scale)
            yq_arrow_imageView.yq_imageName = "fe7c9cd3cd0203d7485017d7fa496160"
            return CGPoint(x: contentView.frame.width - yq_arrow_imageView.frame.width - yq_icon_imageView.frame.minX, y: (contentView.frame.height - yq_arrow_imageView.frame.height) * 0.5)
        }()
    }
}

extension JY_Base_MineCell {
    func set(iconName: String) {
        if yq_icon_imageView.yq_imageName != iconName {
            yq_icon_imageView.yq_imageName = iconName
            yq_icon_imageView_frame()
        }
    }
    
    func set(title: String) {
        if yq_title_label.text != title {
            yq_title_label.text = title
            yq_title_label_frame()
        }
    }
}
