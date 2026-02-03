//
//  JYClipImageController + Interaction.swift
//  JYClipImageController
//
//  Created by JYYQLin on 2025/12/8.
//

import UIKit

public extension JYClipImageController {
    
    @objc func yq_done_click() {
       let a = yq_detail_view.yq_clip_image()
        let image = a.clipImage
//        let rect = a.editRect
        
        yq_select_image_click_block?(image)
        yq_back_click()
    }
    
    @objc func yq_back_click() {
        if self.navigationController != nil && (navigationController?.viewControllers.count ?? 0) > 1 {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true)
        }
    }
}

extension JYClipImageController {
    @objc func yq_rotate_click() {
        yq_detail_view.yq_rotate_click()
    }
    
    @objc func yq_reduction_click() {
        yq_detail_view.yq_reduction_click()
    }
    
    func yq_ratio_click(radio: JYClipImageRatioModel) {
        yq_detail_view.set(ratio: radio)
    }
}

extension JYClipImageController {
    static func yq_show(_ fromController: UIViewController, image: UIImage, ratio: JYClipImageRatioModel? = nil, selectImageClickBlock: @escaping ((_ image: UIImage) -> Void)) {
        
        let controller = JYClipImageController(image: image, ratio: ratio)
        controller.yq_select_image_click_block = selectImageClickBlock
        
        if (fromController.navigationController != nil) {
            fromController.navigationController?.pushViewController(controller, animated: true)
        }
        else {
            let navigationController = UINavigationController(rootViewController: controller)
            fromController.present(navigationController, animated: true)
        }
    }
}
