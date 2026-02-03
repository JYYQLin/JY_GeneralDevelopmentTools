//
//  JY_Slider.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2026/1/28.
//

import UIKit

// 核心修改1：类添加@objc open，支持外部引用、继承、OC混编
@objc open class JY_Slider: JY_View {
    
    // 核心修改2：对外只读属性添加@objc open，支持外部访问进度值
    @objc open var progress: Float { get { return progressView.progress } }
    
    // 内部私有成员：保持private，无需修改
    private lazy var sliderView: JY_View = JY_View()
    private lazy var progressView: UIProgressView = UIProgressView()
    private lazy var sliderColor: UIColor = UIColor.yq_color(hexString: "0xE85022")
    private lazy var progressTintColor: UIColor = UIColor.yq_color(hexString: "0xE85022")
    private lazy var progressTrackTintColor: UIColor = UIColor.yq_color(hexString: "0xFEFDFE").withAlphaComponent(0.75)
    
    // 核心修改3：对外回调闭包添加@objc open，支持外部赋值监听事件
    @objc open var sliderChangeBlock: ((_ progress: Float) -> Void)?
    @objc open var sliderCancelBlock: (() -> Void)?
}

extension JY_Slider {
    // 核心修改4：所有对外设置方法添加@objc open，支持外部调用、OC混编
    @objc open func set(sliderColor: UIColor) {
        self.sliderColor = sliderColor
        sliderView.backgroundColor = sliderColor
    }
    
    @objc open func set(progressTintColor: UIColor) {
        self.progressTintColor = progressTintColor
        progressView.progressTintColor = progressTintColor
    }
    
    @objc open func set(progressTrackTintColor: UIColor) {
        self.progressTrackTintColor = progressTrackTintColor
        progressView.trackTintColor = progressTrackTintColor
    }
    
    @objc open func set(progress: Float) {
        progressView.progress = progress
        sliderView.center.x = progressView.frame.width * CGFloat(progress) + progressView.frame.minX
    }
}

extension JY_Slider {
    open override func yq_add_subviews() {
        super.yq_add_subviews()
        
        addSubview(progressView)
        addSubview(sliderView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(progressTapClick(tap:)))
        addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(progressPanClick(pan:)))
        addGestureRecognizer(pan)
    }
}

extension JY_Slider {
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        progressView.frame.origin = {
            progressView.frame.size = CGSize(width: frame.width, height: 3 * yq_scale)
            progressView.progressTintColor = progressTintColor
            progressView.trackTintColor = progressTrackTintColor
            
            progressView.layer.cornerRadius = progressView.frame.height * 0.5
            progressView.layer.masksToBounds = true
            
            return CGPoint(x: (frame.width - progressView.frame.width) * 0.5, y: (frame.height - progressView.frame.height) * 0.5)
        }()
        
        sliderView.frame.origin = {
            sliderView.frame.size = CGSize(width: 15 * yq_scale, height: 15 * yq_scale)
            sliderView.backgroundColor = sliderColor
            sliderView.layer.cornerRadius = sliderView.frame.height * 0.5
            sliderView.layer.masksToBounds = true
            return CGPoint(x: (progressView.frame.width) * CGFloat(progressView.progress) - sliderView.frame.width * 0.5, y: progressView.frame.midY - sliderView.frame.height * 0.5)
        }()
    }
}

extension JY_Slider {
    // 内部手势处理方法：保持@objc private，无需对外暴露
    @objc private func progressTapClick(tap: UITapGestureRecognizer) {
        let pointX = tap.location(in: self).x
        
        var progress = Float(pointX / frame.width)
        progress = max(0, min(1, progress)) // 简化边界判断，等价于原if逻辑
        
        set(progress: progress)
        sliderChangeBlock?(progress) // 简化可选闭包调用，等价于原if判断
    }
    
    @objc private func progressPanClick(pan: UIPanGestureRecognizer) {
        let pointX = pan.location(in: self).x
        
        var progress = Float(pointX / frame.width)
        progress = max(0, min(1, progress)) // 简化边界判断
        
        switch pan.state {
        case .changed:
            sliderChangeBlock?(progress)
        case .ended:
            sliderCancelBlock?()
        default:
            break
        }
        
        set(progress: progress)
    }
}
