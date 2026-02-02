//
//  JYClipOverlayView.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/8.
//

import UIKit

// MARK: 裁剪网格视图
class JYClipOverlayView: JY_View {
    
    static let yq_corner_line_width: CGFloat = 3.0
    
    var cropRect: CGRect = .zero
    
    private lazy var yq_is_circle = false
    
    //  背景
    private lazy var yq_shadow_view: JY_View = {
        let view = JY_View()
        view.backgroundColor = UIColor.color010101.withAlphaComponent(0.65)
        view.layer.mask = yq_shadow_mask_layer
        return view
    }()
    
    private lazy var yq_shadow_mask_layer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillRule = .evenOdd
        return layer
    }()
    
    //  中心区域
    private lazy var yq_frame_border_view: UIView = {
        let view = UIView()
        view.layer.addSublayer(yq_frame_border_layer)
        return view
    }()
    
    private lazy var yq_frame_border_layer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 1.2
        layer.contentsScale = UIScreen.main.scale
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 1
        layer.shadowRadius = 2
        layer.shadowColor = UIColor.black.withAlphaComponent(0.7).cgColor
        return layer
    }()
    
    //  边角
    private lazy var yq_corner_lines_view: UIView = {
        let view = UIView()
        view.layer.addSublayer(yq_corner_lines_layer)
        return view
    }()
    
    private lazy var yq_corner_lines_layer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = JYClipOverlayView.yq_corner_line_width
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()
    
    //  网格辅助线
    private lazy var yq_grid_lines_view: UIView = {
        let view = UIView()
        view.layer.addSublayer(yq_grid_lines_layer)
        view.alpha = 0
        return view
    }()
    
    private lazy var yq_grid_lines_layer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 0.5
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()
}

extension JYClipOverlayView {
    override func yq_add_subviews() {
        super.yq_add_subviews()
        
        addSubview(yq_shadow_view)
        addSubview(yq_frame_border_view)
        addSubview(yq_corner_lines_view)
        addSubview(yq_grid_lines_view)
        
        layoutSubviews()
    }
}

extension JYClipOverlayView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        yq_shadow_view.frame.origin = {
            yq_shadow_view.frame.size = bounds.size
            yq_shadow_mask_layer.frame = yq_shadow_view.bounds
            return bounds.origin
        }()
        
        yq_frame_border_view.frame.origin = {
            yq_frame_border_view.frame.size = bounds.size
            yq_frame_border_layer.frame = yq_frame_border_view.bounds
            return bounds.origin
        }()
        
        yq_corner_lines_view.frame.origin = {
            yq_corner_lines_view.frame.size = bounds.size
            yq_corner_lines_layer.frame = yq_corner_lines_view.bounds
            return bounds.origin
        }()
        
        yq_grid_lines_view.frame.origin = {
            yq_grid_lines_view.frame.size = bounds.size
            yq_grid_lines_layer.frame = yq_grid_lines_view.bounds
            return bounds.origin
        }()
    }
    
}

extension JYClipOverlayView {
    func set(isCircle: Bool) {
        yq_is_circle = isCircle
        yq_shadow_mask_layer.path = yq_get_shadow_mask_layer_path().cgPath
    }
}

extension JYClipOverlayView {
    /// 生成阴影遮罩层的路径（核心：创建「外围填充、中间透明」的镂空路径）
    /// 原理：主路径是yq_shadow_view的矩形区域，追加反转后的透明区域路径，结合evenOdd填充规则时，中间区域会镂空透明
    /// - Returns: 组合后的UIBezierPath（用于CAShapeLayer的path属性，实现阴影遮罩）
    private func yq_get_shadow_mask_layer_path() -> UIBezierPath {
        // 1. 创建基础路径：大小为阴影容器视图（yq_shadow_view）的完整矩形路径
        // 这个路径是阴影需要显示的「外围区域」
        let path = UIBezierPath(rect: yq_shadow_view.frame)
        
        // 2. 定义需要透明镂空的区域路径（根据是否为圆形，创建对应形状）
        let transparentPath: UIBezierPath
        if yq_is_circle == true {
            // 若是圆形：创建裁剪区域（cropRect）大小的圆形路径（圆角为宽度的一半）
            transparentPath = UIBezierPath(roundedRect: cropRect, cornerRadius: cropRect.width / 2)
        } else {
            // 若不是圆形：创建裁剪区域（cropRect）大小的矩形路径
            transparentPath = UIBezierPath(rect: cropRect)
        }
        
        // 3. 反转透明区域的路径方向 + 追加到主路径
        // reversing()：反转路径的绘制方向（影响evenOdd/nonZero填充规则的判断）
        // append：将反转后的透明路径合并到主路径中，形成「外围矩形 + 反向的中间区域」的复合路径
        path.append(transparentPath.reversing())
        
        // 最终返回的路径：结合evenOdd填充规则时，外围yq_shadow_view区域填充（显示阴影），中间cropRect区域透明（镂空）
        return path
    }
    
    
    /// 生成裁剪框四角的角线路径（用于绘制裁剪区域的边角指示线，呈现L型短线条效果）
    /// 核心逻辑：基于裁剪区域(cropRect)向外扩展线条宽度的一半，在四个角落分别绘制L型短线条，形成裁剪框的边角标记
    /// - Returns: 包含四个角落L型线条的UIBezierPath（用于CAShapeLayer绘制角线）
    private func yq_get_corner_lines_layer_path() -> UIBezierPath {
        // 1. 调整裁剪区域的矩形范围：向外扩展角线宽度的一半
        // 原因：角线绘制时以矩形边缘为中心，扩展后能保证线条完整显示，不会被裁剪
        // insetBy(dx/dy为负数) = 矩形向外扩展，正数 = 向内收缩
        let rect = cropRect.insetBy(dx: -(JYClipOverlayView.yq_corner_line_width / 2), dy: -(JYClipOverlayView.yq_corner_line_width / 2))
        
        // 2. 初始化空的贝塞尔路径，用于拼接四个角落的线条
        let path = UIBezierPath()
        
        // 3. 定义角线的长度（每个L型短线的单边长度，固定20pt）
        let length: CGFloat = 20
        
        // --------------------- 绘制左上角的L型角线 ---------------------
        // 移动画笔到左上角横向线条的终点（避免与其他线条连笔）
        path.move(to: CGPoint(x: rect.minX + length, y: rect.minY))
        // 画横线：从(左+length, 上) → (左, 上)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        // 画竖线：从(左, 上) → (左, 上+length)，形成左上L型
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + length))

        // --------------------- 绘制右上角的L型角线 ---------------------
        // 移动画笔到右上角横向线条的起点（重置路径起点，避免和左上线条连接）
        path.move(to: CGPoint(x: rect.maxX - length, y: rect.minY))
        // 画横线：从(右-length, 上) → (右, 上)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        // 画竖线：从(右, 上) → (右, 上+length)，形成右上L型
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + length))

        // --------------------- 绘制左下角的L型角线 ---------------------
        // 移动画笔到左下角竖线的起点
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY - length))
        // 画竖线：从(左, 下-length) → (左, 下)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        // 画横线：从(左, 下) → (左+length, 下)，形成左下L型
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.maxY))
        
        // --------------------- 绘制右下角的L型角线 ---------------------
        // 移动画笔到右下角横向线条的起点
        path.move(to: CGPoint(x: rect.maxX - length, y: rect.maxY))
        // 画横线：从(右-length, 下) → (右, 下)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        // 画竖线：从(右, 下) → (右, 下-length)，形成右下L型
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - length))
        
        // 返回包含四个角落L型线条的完整路径
        return path
    }
    
    /// 生成裁剪区域的九宫格网格线路径（适配圆形/矩形裁剪场景）
    /// 核心逻辑：默认绘制覆盖裁剪区域的九宫格线条；若为圆形裁剪且开启「裁剪区变暗」，则调整网格线垂直偏移，避免线条超出圆形边界
    /// - Returns: 九宫格网格线的UIBezierPath（用于CAShapeLayer绘制裁剪辅助网格）
    private func yq_get_grid_lines_layerPath() -> UIBezierPath {
        // 1. 初始化空的贝塞尔路径，用于拼接九宫格的横竖线条
        let path = UIBezierPath()
        
        // 2. 计算裁剪矩形宽度的一半（圆形裁剪时为圆的半径）
        let r = cropRect.width / 2
        // 3. 网格线垂直方向的偏移量（仅圆形裁剪且开启特定配置时生效，默认0）
        var diff: CGFloat = 0
        
        // 4. 条件判断：仅当「圆形裁剪」且「裁剪调整时被裁剪区域变暗」时，计算偏移量diff
//        if yq_is_circle && ZLPhotoConfiguration.default().editImageConfiguration.dimClippedAreaDuringAdjustments {
            if yq_is_circle == true {
                // 几何计算：避免网格线超出圆形边界的垂直偏移量
                // 原理（勾股定理）：
                // 圆半径r，网格线水平位置在r/3处，计算该位置的垂直边界到圆心的距离，再用r减去该距离得到diff
                // 目的：让网格线的上下端点落在圆形边缘内，而非裁剪矩形的边缘（避免圆形裁剪时网格线超出圆）
                diff = r - sqrt(pow(r, 2) - pow(r / 3, 2))
            }
//        }
        
        // --------------------- 绘制九宫格竖线（共2条，将裁剪区宽度三等分） ---------------------
        // 计算每一份的宽度（裁剪区宽度/3）
        let dw = cropRect.width / 3
        // 循环1-2次，绘制第1、2条竖线（三等分的两个分割线）
        for i in 1...2 {
            // 计算当前竖线的x坐标（裁剪区左边界 + 第i份的宽度）
            let x = CGFloat(i) * dw + cropRect.minX
            // 移动画笔到竖线起点（y轴偏移diff，避免圆形时超出边界）
            path.move(to: CGPoint(x: x, y: cropRect.minY + diff))
            // 绘制竖线到终点（y轴向下偏移diff，贴合圆形边界）
            path.addLine(to: CGPoint(x: x, y: cropRect.maxY - diff))
        }
        
        // --------------------- 绘制九宫格横线（共2条，将裁剪区高度三等分） ---------------------
        // 计算每一份的高度（裁剪区高度/3）
        let dh = cropRect.height / 3
        // 循环1-2次，绘制第1、2条横线（三等分的两个分割线）
        for i in 1...2 {
            // 计算当前横线的y坐标（裁剪区上边界 + 第i份的高度）
            let y = CGFloat(i) * dh + cropRect.minY
            // 移动画笔到横线起点（x轴偏移diff，避免圆形时超出边界）
            path.move(to: CGPoint(x: cropRect.minX + diff, y: y))
            // 绘制横线到终点（x轴向右偏移diff，贴合圆形边界）
            path.addLine(to: CGPoint(x: cropRect.maxX - diff, y: y))
        }
        
        // 返回包含九宫格横竖线条的完整路径
        return path
    }
}

extension JYClipOverlayView {
    func yq_begin_update() {
//        let config = ZLPhotoConfiguration.default().editImageConfiguration
//        yq_shadow_view.alpha = config.dimClippedAreaDuringAdjustments ? 1 : 0
        
        yq_shadow_view.alpha = 1
        yq_grid_lines_view.alpha = 1
    }
    
    func yq_end_update(delay: TimeInterval = 0) {
        UIView.animate(withDuration: 0.15, delay: delay) {
//            if !ZLPhotoConfiguration.default().editImageConfiguration.dimClippedAreaDuringAdjustments {
                self.yq_shadow_view.alpha = 1
//            }
            self.yq_grid_lines_view.alpha = 0
        }
    }
    
    func yq_update_layers(_ rect: CGRect, animate: Bool, endEditing: Bool) {
        cropRect = rect
        
        let shadowMaskPath = yq_get_shadow_mask_layer_path()
        let frameBorderPath = UIBezierPath(rect: rect)
        let cornerLinesPath = yq_get_corner_lines_layer_path()
        let gridLinesPath = yq_get_grid_lines_layerPath()
        
        let duration: TimeInterval = 0.25
        func animateShadowMaskLayer() {
            yq_shadow_mask_layer.removeAnimation(forKey: "shadowMaskAnimation")
            let animation = JYAnimationUtils.animation(
                type: .path,
                fromValue: yq_shadow_mask_layer.path,
                toValue: shadowMaskPath.cgPath,
                duration: duration,
                isRemovedOnCompletion: true,
                timingFunction: CAMediaTimingFunction(name: .easeInEaseOut)
            )
            yq_shadow_mask_layer.add(animation, forKey: "shadowMaskAnimation")
        }
        
        func animateFrameBorderLayer() {
            yq_frame_border_layer.removeAnimation(forKey: "frameBorderAnimation")
            let animation = JYAnimationUtils.animation(
                type: .path,
                fromValue: yq_frame_border_layer.path,
                toValue: frameBorderPath.cgPath,
                duration: duration,
                isRemovedOnCompletion: true,
                timingFunction: CAMediaTimingFunction(name: .easeInEaseOut)
            )
            yq_frame_border_layer.add(animation, forKey: "frameBorderAnimation")
        }
        
        func animateCornerLinesLayer() {
            yq_corner_lines_layer.removeAnimation(forKey: "cornerLinesAnimation")
            let animation = JYAnimationUtils.animation(
                type: .path,
                fromValue: yq_corner_lines_layer.path,
                toValue: cornerLinesPath.cgPath,
                duration: duration,
                isRemovedOnCompletion: true,
                timingFunction: CAMediaTimingFunction(name: .easeInEaseOut)
            )
            yq_corner_lines_layer.add(animation, forKey: "cornerLinesAnimation")
        }
        
        func animateGridLinesLayer() {
            yq_grid_lines_layer.removeAnimation(forKey: "gridLinesAnimation")
            let animation = JYAnimationUtils.animation(
                type: .path,
                fromValue: yq_grid_lines_layer.path,
                toValue: gridLinesPath.cgPath,
                duration: duration,
                isRemovedOnCompletion: true,
                timingFunction: CAMediaTimingFunction(name: .easeInEaseOut)
            )
            yq_grid_lines_layer.add(animation, forKey: "gridLinesAnimation")
        }
        
        if animate {
            animateShadowMaskLayer()
            animateFrameBorderLayer()
            animateCornerLinesLayer()
            animateGridLinesLayer()
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        yq_shadow_mask_layer.path = shadowMaskPath.cgPath
        yq_frame_border_layer.path = frameBorderPath.cgPath
        yq_corner_lines_layer.path = cornerLinesPath.cgPath
        yq_grid_lines_layer.path = gridLinesPath.cgPath
        
        CATransaction.commit()
        
        if animate, endEditing {
            yq_end_update(delay: duration)
        }
    }
}
