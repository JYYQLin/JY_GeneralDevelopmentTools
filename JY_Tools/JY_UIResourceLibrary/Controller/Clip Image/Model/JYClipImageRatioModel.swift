//
//  JYClipImageRatioModel.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/8.
//

import UIKit

class JYClipImageRatioModel: Equatable {
   private(set) lazy var yq_title: String = ""
    
    private(set) lazy var yq_width_height_ratio: CGFloat = 0
    
    private(set) lazy var yq_is_circle: Bool = false
    
    func set(title: String, ratio: CGFloat, isCircle: Bool) {
        
        if yq_title != title {
            yq_title = title
        }
        
        if yq_width_height_ratio != ratio {
            yq_width_height_ratio = ratio
        }
        
        if yq_is_circle != isCircle {
            yq_is_circle = isCircle
        }
    }
}

extension JYClipImageRatioModel {
    static func == (lhs: JYClipImageRatioModel, rhs: JYClipImageRatioModel) -> Bool {
        return lhs.yq_width_height_ratio == rhs.yq_width_height_ratio && lhs.yq_title == rhs.yq_title && lhs.yq_is_circle == rhs.yq_is_circle
    }
}

extension JYClipImageRatioModel {
    
    static func yq_custom() -> JYClipImageRatioModel {
        let model = JYClipImageRatioModel()
        model.set(title: "custom", ratio: 0, isCircle: false)
        return model
    }
    
    static func yq_circle() -> JYClipImageRatioModel {
        let model = JYClipImageRatioModel()
        model.set(title: "circle", ratio: 1, isCircle: true)
        return model
    }
    
    static func yq_ratio_1_1() -> JYClipImageRatioModel {
        let model = JYClipImageRatioModel()
        model.set(title: "1 : 1", ratio: 1, isCircle: false)
        return model
    }
    
    static func yq_ratio_3_4() -> JYClipImageRatioModel {
        let model = JYClipImageRatioModel()
        model.set(title: "3 : 4", ratio: 3.0 / 4, isCircle: false)
        return model
    }
    
    static func yq_ratio_4_3() -> JYClipImageRatioModel {
        let model = JYClipImageRatioModel()
        model.set(title: "4 : 3", ratio: 4.0 / 3, isCircle: false)
        return model
    }
    
    static func yq_ratio_2_3() -> JYClipImageRatioModel {
        let model = JYClipImageRatioModel()
        model.set(title: "2 : 3", ratio: 2.0 / 3, isCircle: false)
        return model
    }
    
    static func yq_ratio_3_2() -> JYClipImageRatioModel {
        let model = JYClipImageRatioModel()
        model.set(title: "3 : 2", ratio: 3.0 / 2, isCircle: false)
        return model
    }
    
    static func yq_ratio_9_16() -> JYClipImageRatioModel {
        let model = JYClipImageRatioModel()
        model.set(title: "9 : 16", ratio: 9.0 / 16.0, isCircle: false)
        return model
    }
    
    static func yq_ratio_16_9() -> JYClipImageRatioModel {
        let model = JYClipImageRatioModel()
        model.set(title: "16 : 9", ratio: 16.0 / 9.0, isCircle: false)
        return model
    }
    
    static func yq_all() -> [JYClipImageRatioModel] {
        return [yq_custom(), yq_circle(), yq_ratio_1_1(), yq_ratio_3_4(), yq_ratio_4_3(), yq_ratio_2_3(), yq_ratio_3_2(), yq_ratio_9_16(), yq_ratio_16_9()]
    }
}
