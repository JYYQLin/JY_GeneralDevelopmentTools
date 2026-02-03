//
//  JYClipImageRatioCell.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/8.
//

import UIKit

class JYClipImageRatioCell: JY_BaseCollectionViewCell {
    
    private lazy var yq_is_selected: Bool = false
    
    private lazy var yq_ratio: JYClipImageRatioModel = .yq_custom()
    
    private lazy var yq_image: UIImage? = nil
    private lazy var yq_imageView: JY_ImageView = {
        let imageView = JY_ImageView()
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private lazy var yq_title_label: JY_Label = JY_Label()
    
}

extension JYClipImageRatioCell {
    override func yq_add_subviews() {
        super.yq_add_subviews()
        
        contentView.addSubview(yq_imageView)
        contentView.addSubview(yq_title_label)
    }
}

extension JYClipImageRatioCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        yq_title_label_frame()
        yq_imageView_frame()
    }
    
    func yq_imageView_frame() {
        
        if let image = yq_image {
            var w: CGFloat = 0, h: CGFloat = 0
            
            let imageMaxW = bounds.width - 10 * yq_scale
            if yq_ratio.yq_width_height_ratio == 0 {
                let maxSide = max(image.size.width, image.size.height)
                w = imageMaxW * image.size.width / maxSide
                h = imageMaxW * image.size.height / maxSide
            } else {
                if yq_ratio.yq_width_height_ratio >= 1 {
                    w = imageMaxW
                    h = w / yq_ratio.yq_width_height_ratio
                } else {
                    h = imageMaxW
                    w = h * yq_ratio.yq_width_height_ratio
                }
            }
            if yq_ratio.yq_is_circle {
                yq_imageView.layer.cornerRadius = w / 2
            } else {
                yq_imageView.layer.cornerRadius = 3 * yq_scale
            }
            yq_imageView.frame.size = CGSize(width: w, height: h)
            yq_imageView.frame.origin = CGPoint(x: (contentView.frame.width - w) * 0.5, y: (yq_title_label.frame.minY - h) * 0.5)
        }
    }
    
    func yq_title_label_frame() {
        yq_title_label.frame.origin = {
            yq_title_label.frame.size = CGSize(width: contentView.frame.width, height: 13 * yq_scale)
            yq_title_label.font = UIFont.yq_pingfang_sc(12 * yq_scale)
            yq_title_label.textAlignment = .center
            yq_title_label.layer.shadowColor = UIColor.yq_color(hexString: "0x010101").withAlphaComponent(0.3).cgColor
            yq_title_label.layer.shadowOffset = .zero
            yq_title_label.layer.shadowOpacity = 1
            yq_title_label.textColor = yq_is_selected == true ? UIColor.yq_color(hexString: "0xFAFAFB") : UIColor.yq_color(red: 160, green: 160, blue: 160)
            return CGPoint(x: 0, y: contentView.frame.height - yq_title_label.frame.height)
        }()
    }
}

extension JYClipImageRatioCell {
    func set(image: UIImage) {
        yq_image = image
        yq_imageView.image = image
        
        yq_imageView_frame()
    }
    
    func set(ratio: JYClipImageRatioModel, isSelected: Bool) {
        yq_ratio = ratio
        yq_title_label.text = ratio.yq_title
        yq_is_selected = isSelected
        layoutSubviews()
    }
}
