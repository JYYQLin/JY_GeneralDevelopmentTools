//
//  JY_SemicircleView.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/24.
//

import UIKit
/// 半圆弧形空心视图（带左右端点圆形）
class JY_SemicircleView: JY_View {
    // MARK: - 可配置属性（增强复用性）
    /// 圆弧线宽（默认20，支持外部设置）
    var lineWidth: CGFloat = 20.0 {
        didSet {
            guard lineWidth != oldValue else { return }
            updateLayerStyles()
            setNeedsLayout()
        }
    }
    
    /// 圆弧显示百分比（0-100，超出自动修正）
    var progress: CGFloat = 100.0 {
        didSet {
            // 边界值修正，避免角度异常
            let clampedProgress = max(0, min(100, progress))
            guard clampedProgress != oldValue else { return }
            progress = clampedProgress
            setNeedsLayout()
        }
    }
    
    /// 圆弧/端点颜色（默认透明）
    var strokeColor: UIColor = .clear {
        didSet {
            guard strokeColor != oldValue else { return }
            updateLayerStyles()
        }
    }
    
    // MARK: - 私有图层属性
    private let arcLayer = CAShapeLayer()
    private let leftDotLayer = CAShapeLayer()
    private let rightDotLayer = CAShapeLayer()
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    // MARK: - 布局刷新
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayerPaths()
    }
}

// MARK: - 图层配置&更新
private extension JY_SemicircleView {
    /// 初始化图层（仅执行一次，避免重复添加）
    func setupLayers() {
        // 基础配置：填充透明、添加图层到主图层
        [arcLayer, leftDotLayer, rightDotLayer].forEach { layer in
            layer.fillColor = strokeColor.cgColor
            layer.masksToBounds = true
            self.layer.addSublayer(layer)
        }
        
        // 圆弧图层专属配置
        arcLayer.strokeColor = strokeColor.cgColor
        arcLayer.lineWidth = lineWidth
        arcLayer.fillColor = UIColor.clear.cgColor // 圆弧填充透明
    }
    
    /// 更新图层样式（颜色、线宽，避免重复初始化）
    func updateLayerStyles() {
        arcLayer.strokeColor = strokeColor.cgColor
        arcLayer.lineWidth = lineWidth
        leftDotLayer.fillColor = strokeColor.cgColor
        rightDotLayer.fillColor = strokeColor.cgColor
    }
    
    /// 更新图层路径（仅布局变化/进度变化时执行）
    func updateLayerPaths() {
        // 1. 计算圆弧核心参数
        let arcCenter = CGPoint(x: bounds.midX, y: bounds.maxY - lineWidth * 0.5)
        let arcRadius = min(bounds.width, bounds.height) - lineWidth
        let startAngle = -CGFloat.pi // 半圆起始角度（左侧水平）
        let endAngle = startAngle + CGFloat.pi * (progress / 100) // 按进度计算结束角度
        
        // 2. 更新圆弧路径
        let arcPath = UIBezierPath(
            arcCenter: arcCenter,
            radius: arcRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        arcLayer.path = arcPath.cgPath
        
        // 3. 计算端点位置&更新圆形路径
        let dotRadius = lineWidth / 2 // 端点圆形半径=线宽的一半
        // 左端点（固定在圆弧起始位置）
        let leftDotCenter = CGPoint(x: arcCenter.x - arcRadius, y: arcCenter.y)
        leftDotLayer.path = UIBezierPath(
            arcCenter: leftDotCenter,
            radius: dotRadius,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true
        ).cgPath
        
        // 右端点（随进度变化）
        let rightDotCenter = CGPoint(
            x: arcCenter.x + arcRadius * cos(endAngle),
            y: arcCenter.y + arcRadius * sin(endAngle)
        )
        rightDotLayer.path = UIBezierPath(
            arcCenter: rightDotCenter,
            radius: dotRadius,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true
        ).cgPath
    }
}

// MARK: - 外部便捷方法（兼容原有调用习惯）
extension JY_SemicircleView {
    func set(strokeColor: UIColor) {
        self.strokeColor = strokeColor
        setupLayers()
    }
}
