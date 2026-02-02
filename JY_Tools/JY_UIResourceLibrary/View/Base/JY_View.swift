//
//  JY_View.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/23.
//

import UIKit

open class JY_Label: UILabel {
    
    public private(set) lazy var yq_scale: CGFloat = 1
    open func set(scale: CGFloat) {
         if yq_scale != scale {
             yq_scale = scale
             layoutSubviews()
         }
     }
    
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        yq_add_subviews()
    }
    
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
    @objc dynamic open func yq_add_subviews() { }
}


open class JY_ImageView: UIImageView {
    
    public private(set) lazy var yq_scale: CGFloat = 1
    open func set(scale: CGFloat) {
         if yq_scale != scale {
             yq_scale = scale
             layoutSubviews()
         }
     }
    
    public lazy var yq_imageName: String = "" {
        didSet {
            if yq_imageName.count > 0 {
                image = UIImage(named: yq_imageName)
            }
        }
    }
    
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        yq_add_subviews()
    }
    
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
    @objc dynamic open func yq_add_subviews() { }
}

open class JY_Button: UIButton {
    
    public private(set) lazy var yq_scale: CGFloat = 1
    open func set(scale: CGFloat) {
         if yq_scale != scale {
             yq_scale = scale
             layoutSubviews()
         }
     }
    
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        yq_add_subviews()
    }
        
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc dynamic open func yq_add_subviews() { }
}

open class JY_View: UIView {
    
    public private(set) lazy var yq_scale: CGFloat = 1
    open func set(scale: CGFloat) {
         if yq_scale != scale {
             yq_scale = scale
             layoutSubviews()
         }
     }
    
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        yq_add_subviews()
    }
    
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc dynamic open func yq_add_subviews() { }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension UIView {
    func yq_safeAreaBottom() -> CGFloat {
        return safeAreaInsets.bottom <= 0 ? 15 : safeAreaInsets.bottom
    }
}

open class JY_ScrollView: UIScrollView {
    
    public private(set) lazy var yq_scale: CGFloat = 1
    open func set(scale: CGFloat) {
         if yq_scale != scale {
             yq_scale = scale
             layoutSubviews()
         }
     }
    
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        contentInsetAdjustmentBehavior = .never
        automaticallyAdjustsScrollIndicatorInsets = false
        
        yq_add_subviews()
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc dynamic open func yq_add_subviews() { }
}

open class JY_TableView: UITableView {
   
    public private(set) lazy var yq_scale: CGFloat = 1
    open func set(scale: CGFloat) {
         if yq_scale != scale {
             yq_scale = scale
             layoutSubviews()
         }
     }
    
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        backgroundColor = UIColor.clear
        contentInsetAdjustmentBehavior = .never
        automaticallyAdjustsScrollIndicatorInsets = false
        
        yq_add_subviews()
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc dynamic open func yq_add_subviews() { }
}

open class JY_CollectionView: UICollectionView {

    public private(set) lazy var yq_scale: CGFloat = 1
    open func set(scale: CGFloat) {
         if yq_scale != scale {
             yq_scale = scale
             layoutSubviews()
         }
     }
    
    public override init(frame: CGRect = .zero, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
 
        backgroundColor = UIColor.clear
        contentInsetAdjustmentBehavior = .never
        automaticallyAdjustsScrollIndicatorInsets = false
        
        yq_add_subviews()
    }
    
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc dynamic open func yq_add_subviews() { }
}
