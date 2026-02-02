//
//  JYAnimationUtils.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/8.
//

import UIKit

class JYAnimationUtils: NSObject {
    enum AnimationType: String {
        case fade = "opacity"
        case scale = "transform.scale"
        case rotate = "transform.rotation"
        case path
    }
    
    class func animation(
        type: JYAnimationUtils.AnimationType,
        fromValue: Any?,
        toValue: Any?,
        duration: TimeInterval,
        fillMode: CAMediaTimingFillMode = .forwards,
        isRemovedOnCompletion: Bool = false,
        timingFunction: CAMediaTimingFunction? = nil
    ) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: type.rawValue)
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = duration
        animation.fillMode = fillMode
        animation.isRemovedOnCompletion = isRemovedOnCompletion
        animation.timingFunction = timingFunction
        return animation
    }
    
    class func springAnimation() -> CAKeyframeAnimation {
        let animate = CAKeyframeAnimation(keyPath: "transform")
        animate.duration = 0.5
        animate.isRemovedOnCompletion = true
        animate.fillMode = .forwards
        
        animate.values = [
            CATransform3DMakeScale(0.7, 0.7, 1),
            CATransform3DMakeScale(1.15, 1.15, 1),
            CATransform3DMakeScale(0.9, 0.9, 1),
            CATransform3DMakeScale(1, 1, 1)
        ]
        return animate
    }
}
