//
//  JYClipImageController.swift
//  JYClipImageController
//
//  Created by JYYQLin on 2025/12/8.
//

import UIKit

class JYClipImageController: JY_BaseController {
    
    var yq_select_image_click_block: ((_ image: UIImage) -> Void)?
    
//    // 隐藏状态栏
//     override var prefersStatusBarHidden: Bool { true }
//     // 自动隐藏HomeIndicator（底部横条）
//     override var prefersHomeIndicatorAutoHidden: Bool { true }
//     // 延缓系统边缘手势（避免与裁剪手势冲突）
//     override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { [.top, .bottom] }
     // 支持的屏幕方向（iPhone仅竖屏，iPad支持全方向）
     override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
         JY_DeviceTool.isIPhone() ? .portrait : .all
     }
    
    private(set) lazy var yq_bottom_navigationBar: JYClipImageBottomNavigationBar = {
        let view = JYClipImageBottomNavigationBar()
        
        view.yq_done_button_add_target(self, action: #selector(yq_done_click), for: .touchUpInside)
        view.yq_cancel_button_add_target(self, action: #selector(yq_back_click), for: .touchUpInside)
        
        return view
    }()
    
    private(set) lazy var yq_clip_tool_view: JYClipImageToolView = {
        let view = JYClipImageToolView()
        
        view.yq_rotate_button_add_target(self, action: #selector(yq_rotate_click), for: .touchUpInside)
        view.yq_reduction_button_add_target(self, action: #selector(yq_reduction_click), for: .touchUpInside)
        
        view.yq_ratio_click_block = { [weak self] radio in
            self?.yq_ratio_click(radio: radio)
        }
        
        return view
    }()
    
    private(set) lazy var yq_detail_view: JYClipImageView = {
        let view = JYClipImageView()
        
        return view
    }()
    
    init(image: UIImage, ratio: JYClipImageRatioModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        yq_clip_tool_view.set(image: image)
        if ratio == nil {
            yq_clip_tool_view.set(ratioArray: JYClipImageRatioModel.yq_all())
        }
        else {
            yq_clip_tool_view.set(ratioArray: [ratio!])
        }
        
        yq_detail_view.set(image: image)
    }
    
    @MainActor required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension JYClipImageController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        yq_detail_view.set(ratio: yq_clip_tool_view.yq_current_radio)
    }
}

extension JYClipImageController {
    override func yq_setInterface() {
        super.yq_setInterface()
        
        yq_contentView.addSubview(yq_detail_view)
    }
    
    override func yq_setNavigationBar() {
        super.yq_setNavigationBar()
        
        view.addSubview(yq_bottom_navigationBar)
        view.addSubview(yq_clip_tool_view)
    }
    
    override func yq_layoutSubviews() {
        super.yq_layoutSubviews()
                
        view.backgroundColor = UIColor.color010101
        
        yq_bottom_navigationBar.frame.origin = {
            
            let bottom = view.safeAreaInsets.bottom <= 0 ? 10 * yq_scale : view.safeAreaInsets.bottom
            
            if yq_bottom_navigationBar.isHidden == true {
                yq_bottom_navigationBar.frame.size = CGSize(width: view.frame.width, height: 0)
            }
            else {
                yq_bottom_navigationBar.frame.size = CGSize(width: view.frame.width, height: 45)
            }
            
            yq_bottom_navigationBar.set(scale: 1.0)
            
            return CGPoint(x: (view.frame.width - yq_bottom_navigationBar.frame.width) * 0.5, y: view.frame.height - yq_bottom_navigationBar.frame.height - bottom)
            
            
        }()
        
        yq_clip_tool_view.frame.origin = {
            yq_clip_tool_view.frame.size = CGSize(width: view.frame.width, height: 78)
            yq_clip_tool_view.set(scale: 1.0)
            return CGPoint(x: (view.frame.width - yq_clip_tool_view.frame.width) * 0.5, y: yq_bottom_navigationBar.frame.minY - yq_clip_tool_view.frame.height)
        }()
        
        yq_detail_view.frame.origin = {
            yq_detail_view.frame.size = CGSize(width: yq_contentView.frame.width, height: yq_contentView.frame.height)
            yq_detail_view.set(scale: yq_scale)
            return .zero
        }()
    }
}

extension JYClipImageController {
    func yq_hidden_bottom_navigationBar() {
        yq_bottom_navigationBar.isHidden = true        
        yq_layoutSubviews()
    }
}
