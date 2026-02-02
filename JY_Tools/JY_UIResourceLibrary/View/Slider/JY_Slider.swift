//
//  JY_Slider.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2026/1/28.
//

import UIKit

class JY_Slider: JY_View {
    
    var progress: Float { get { return progressView.progress } }
    
    private lazy var sliderView: JY_View = JY_View()

    private lazy var progressView: UIProgressView = UIProgressView()
    
    private lazy var sliderColor: UIColor = UIColor.colorE85022
    private lazy var progressTintColor: UIColor = UIColor.colorE85022
    private lazy var progressTrackTintColor: UIColor = UIColor.colorFEFDFE.withAlphaComponent(0.75)
    
    var sliderChangeBlock: ((_ progress: Float) -> Void)?
    var sliderCancelBlock: (() -> Void)?
}

extension JY_Slider {
    
    func set(sliderColor: UIColor) {
        self.sliderColor = sliderColor
        sliderView.backgroundColor = sliderColor
    }
    
    func set(progressTintColor: UIColor) {
        self.progressTintColor = progressTintColor
        progressView.progressTintColor = progressTintColor
    }
    
    func set(progressTrackTintColor: UIColor) {
        self.progressTrackTintColor = progressTrackTintColor
        progressView.trackTintColor = progressTrackTintColor
    }
    
    func set(progress: Float) {
        progressView.progress = progress
        sliderView.center.x = progressView.frame.width * CGFloat(progress) + progressView.frame.minX
    }
}

extension JY_Slider {
    override func yq_add_subviews() {
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
    override func layoutSubviews() {
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
    @objc private func progressTapClick(tap: UITapGestureRecognizer) {
        let pointX = tap.location(in: self).x
        
        var progress = Float(pointX / frame.width)
        
        if progress <= 0 {
            progress = 0
        }
        
        if progress >= 1 {
            progress = 1
        }
        
        set(progress: progress)
        
        if sliderChangeBlock != nil {
            sliderChangeBlock!(progress)
        }
    }
    
    @objc private func progressPanClick(pan: UIPanGestureRecognizer) {
        let pointX = pan.location(in: self).x
        
        var progress = Float(pointX / frame.width)
        
        if progress <= 0 {
            progress = 0
        }
        
        if progress >= 1 {
            progress = 1
        }
        
        if pan.state == .changed {
            if sliderChangeBlock != nil {
                sliderChangeBlock!(progress)
            }
        }
        
        if pan.state == .ended {
            if sliderCancelBlock != nil {
                sliderCancelBlock!()
            }
        }
        
        set(progress: progress)
    }
}
