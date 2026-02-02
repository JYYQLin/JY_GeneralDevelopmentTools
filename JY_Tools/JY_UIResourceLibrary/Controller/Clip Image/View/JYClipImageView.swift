//
//  JYClipImageView.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/8.
//

import UIKit

extension JYClipImageView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == yq_grid_pan else {
            return true
        }
        
        let point = gestureRecognizer.location(in: self)
        let innerFrame = yq_clip_box_frame.insetBy(dx: 22, dy: 22)
        let outerFrame = yq_clip_box_frame.insetBy(dx: -22, dy: -22)
        
        if innerFrame.contains(point) || !outerFrame.contains(point) {
            return false
        }
        return true
    }
}

class JYClipImageView: JY_View {
    
    enum ClipPanEdge {
        case none
        case top
        case bottom
        case left
        case right
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    /// 裁剪比例选择项的尺寸
    private static let yq_clip_ratio_item_size = CGSize(width: 60, height: 70)
    
    /// 裁剪框拖拽手势
    private lazy var yq_grid_pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(yq_grid_pan_click(_:)))
        pan.delegate = self
        return pan
    }()
    
    // MARK: - 动画相关属性
    /// 取消裁剪时动画的目标frame
    private var yq_cancel_clip_animate_frame: CGRect = .zero
    /// viewDidAppear调用次数（用于控制首次进入的动画逻辑）
    private var viewDidAppearCount = 0
    /// 是否正在执行动画（防止重复操作）
    private var yq_is_being_animate = false
    /// 是否启用转场动画
    var yq_is_animate = true
    /// 退出裁剪时的动画起始frame
    var yq_dismiss_animate_from_rect: CGRect = .zero
    /// 退出裁剪时的动画图片
    var yq_dismiss_animate_image: UIImage?
    
    private lazy var yq_is_first_load: Bool = true
    
    // MARK: - 图片相关属性
    /// 原始图片（未经过任何编辑的图片）
    private var yq_original_image: UIImage = UIImage()
    /// 当前编辑中的图片（可能经过旋转）
    private var yq_edit_image: UIImage = UIImage()
    /// 旋转角度（单位：度，顺时针为负，如-90表示顺时针旋转90度）
    private var yq_angle: CGFloat = 0
    
    
    // MARK: - 裁剪区域相关属性
    private(set) lazy var yq_current_radio: JYClipImageRatioModel = JYClipImageRatioModel()
    /// 初次进入界面时的裁剪范围（相对编辑图片的坐标）
    private var yq_edit_rect: CGRect = .zero
    /// 裁剪框的原始frame（拖拽开始时的frame）
    private var yq_clip_origin_frame: CGRect = .zero
    /// 裁剪框当前frame（屏幕坐标）
    private var yq_clip_box_frame: CGRect = .zero
    /// 最大裁剪区域frame（屏幕坐标，限制裁剪框的最大范围）
    private lazy var yq_max_clip_frame = yq_calculate_max_clip_frame()
    /// 最小裁剪尺寸（防止裁剪框过小）
    private var yq_min_clip_size = CGSize(width: 45, height: 45)
    /// 拖拽的边缘/角落标识
    private var yq_pan_edge: JYClipImageView.ClipPanEdge = .none
    /// 拖拽开始的点（屏幕坐标）
    private var yq_begin_pan_point: CGPoint = .zero
    
    // MARK: - UI相关属性
    /// 主滚动视图（用于图片的缩放和拖拽）
    private lazy var yq_scrollView: JY_ScrollView = {
        let view = JY_ScrollView()
        view.alwaysBounceVertical = true
        view.alwaysBounceHorizontal = true
        
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        
        view.delegate = self
        
        return view
    }()
    
    /// 图片容器视图（用于缩放的载体）
    private lazy var yq_container_view: JY_View = JY_View()
    
    //  MARK: 编辑框
    /// 裁剪遮罩层（显示裁剪框和半透明遮罩）
    private lazy var yq_overlay_view: JYClipOverlayView = {
        let view = JYClipOverlayView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    
    //  MARK: ImageView区
    /// 显示编辑图片的imageView
    private lazy var yq_imageView: JY_ImageView = {
        let view = JY_ImageView()
        
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        
        return view
    }()
    
    /// 图片旋转/还原/切换比例时的动画占位View
    private lazy var yq_fake_animate_imageView: JY_ImageView = {
        let animateImageView = JY_ImageView()
        animateImageView.contentMode = .scaleAspectFit
        animateImageView.clipsToBounds = true
        return animateImageView
    }()
}

extension JYClipImageView {
    override func yq_add_subviews() {
        super.yq_add_subviews()
        
        addSubview(yq_scrollView)
        yq_scrollView.addSubview(yq_container_view)
        yq_container_view.addSubview(yq_imageView)
        addSubview(yq_overlay_view)
        
        addGestureRecognizer(yq_grid_pan)
        yq_scrollView.panGestureRecognizer.require(toFail: yq_grid_pan)
    }
}

extension JYClipImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.width > 0, bounds.height > 0, (yq_scrollView.frame.width == bounds.width && yq_scrollView.frame.height == bounds.height) {
            return
        }
        
        let maxClipFrame = yq_calculate_max_clip_frame()
        if maxClipFrame != yq_max_clip_frame {
            yq_max_clip_frame = maxClipFrame
        }
        
        yq_scrollView.frame = bounds
        yq_overlay_view.frame = bounds
        
        yq_layout_initial_image(animate: true)
    }
}

extension JYClipImageView {
    // MARK: - 图片布局
    /// 初始化图片布局（首次加载/旋转/切换比例后调用）
    /// - Parameter animate: 是否开启动画
    private func yq_layout_initial_image(animate: Bool) {
        
        if yq_edit_image.size.width <= 0 || yq_edit_image.size.height <= 0 {
            return
        }
        
        // 重置缩放比例
        yq_scrollView.minimumZoomScale = 1
        yq_scrollView.maximumZoomScale = 1
        yq_scrollView.zoomScale = 1
        
        let editSize = yq_edit_rect.size
        yq_scrollView.contentSize = editSize
        let maxClipRect = yq_max_clip_frame
        
        // 容器View和图片View布局
        yq_container_view.frame = CGRect(origin: .zero, size: yq_edit_image.size)
        yq_imageView.frame = yq_container_view.bounds
        yq_imageView.image = yq_edit_image
        
        // 计算裁剪范围适配最大可视区域的缩放比例
        let editScale = min(maxClipRect.width / editSize.width, maxClipRect.height / editSize.height)
        let scaledSize = CGSize(width: floor(editSize.width * editScale), height: floor(editSize.height * editScale))
        
        // 计算裁剪框初始Frame（居中）
        var frame = CGRect.zero
        frame.size = scaledSize
        frame.origin.x = maxClipRect.minX + floor((maxClipRect.width - frame.width) / 2)
        frame.origin.y = maxClipRect.minY + floor((maxClipRect.height - frame.height) / 2)
        
        // 计算图片基础缩放比例
        let originalScale = max(frame.width / yq_edit_image.size.width, frame.height / yq_edit_image.size.height)
        
        // 裁剪范围缩放后适配最大可视区域的比例
        let scaleEditSize = CGSize(width: yq_edit_rect.width * originalScale, height: yq_edit_rect.height * originalScale)
        let clipRectZoomScale = min(maxClipRect.width / scaleEditSize.width, maxClipRect.height / scaleEditSize.height)
        
        // 设置滚动视图缩放范围
        yq_scrollView.minimumZoomScale = originalScale
        yq_scrollView.maximumZoomScale = 10 // 最大缩放10倍
        let zoomScale = clipRectZoomScale * originalScale
        yq_scrollView.zoomScale = zoomScale
        yq_scrollView.contentSize = CGSize(width: yq_edit_image.size.width * zoomScale, height: yq_edit_image.size.height * zoomScale)
        
        // 更新裁剪框Frame
        yq_change_clip_box_frame(newFrame: frame, animate: animate, updateInset: animate)
        
        // 调整滚动视图偏移（适配裁剪框位置）
        if (frame.size.width < scaledSize.width - CGFloat.ulpOfOne) || (frame.size.height < scaledSize.height - CGFloat.ulpOfOne) {
            var offset = CGPoint.zero
            offset.x = -floor((yq_scrollView.frame.width - scaledSize.width) / 2)
            offset.y = -floor((yq_scrollView.frame.height - scaledSize.height) / 2)
            yq_scrollView.contentOffset = offset
        }
        
        // 调整滚动偏移至裁剪框初始位置
        let diffX = yq_edit_rect.origin.x / yq_edit_image.size.width * yq_scrollView.contentSize.width
        let diffY = yq_edit_rect.origin.y / yq_edit_image.size.height * yq_scrollView.contentSize.height
        yq_scrollView.contentOffset = CGPoint(x: -yq_scrollView.contentInset.left + diffX, y: -yq_scrollView.contentInset.top + diffY)
    }
}

extension JYClipImageView {
    func set(image: UIImage) {
        yq_original_image = image
        yq_edit_image = yq_original_image
        yq_edit_rect = CGRect(origin: .zero, size: image.size)
//        reloadImage()
    }
    
    func set(ratio: JYClipImageRatioModel) {
        
        if ratio == yq_current_radio {
            return
        }
        
        yq_current_radio = ratio
        yq_overlay_view.set(isCircle: ratio.yq_is_circle)
        reloadImage()
    }
    
    private func reloadImage() {
        yq_calculate_clip_rect()
        yq_config_fake_animate_imageView()
        yq_layout_initial_image(animate: true)
        yq_is_first_load = false
        
        let toFrame = convert(yq_container_view.frame, from: yq_scrollView)
        yq_animate_fake_imageView {
            self.yq_fake_animate_imageView.frame = toFrame
        }
    }
}

extension JYClipImageView {
    func yq_rotate_click() {
        if yq_is_being_animate == true {
            return
        }
        
        var angle = yq_angle
        // 更新旋转角度
        angle -= 90
        if angle == -360 { angle = 0 }
        
        // 配置动画View
        yq_config_fake_animate_imageView()
        
        if yq_current_radio.yq_width_height_ratio == 0 || yq_current_radio.yq_width_height_ratio == 1 {
            // 自由比例/1:1：转换裁剪范围（适配旋转后的图片）
            let rect = yq_convert_clip_rect_to_edit_image_rect()
            yq_edit_image = yq_edit_image.rotate(orientation: .left)
            // 旋转后裁剪范围转换（逆时针旋转90度）
            yq_edit_rect = CGRect(x: rect.minY, y: yq_edit_image.size.height - rect.minX - rect.width, width: rect.height, height: rect.width)
        } else {
            // 固定比例：直接旋转图片并重新计算裁剪范围
            yq_edit_image = yq_edit_image.rotate(orientation: .left)
            yq_calculate_clip_rect()
        }
        
        // 更新图片和布局
        yq_imageView.image = yq_edit_image
        yq_layout_initial_image(animate: true)
        
        // 执行旋转动画
        let toFrame = convert(yq_container_view.frame, from: yq_scrollView)
        let transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        yq_animate_fake_imageView {
            self.yq_fake_animate_imageView.transform = transform
            self.yq_fake_animate_imageView.frame = toFrame
        }
        
    }
    
    func yq_reduction_click() {
        guard !yq_is_being_animate else { return }
        
        // 配置动画View
        yq_config_fake_animate_imageView()
        
        // 计算还原旋转角度
        let revertAngle: CGFloat = (Int(yq_angle) + 360) % 360 == 90 ? CGFloat(-90).toPi : -yq_angle.toPi
        let transform = CGAffineTransform(rotationAngle: revertAngle)
        
        // 重置状态
        yq_angle = 0
        yq_edit_image = yq_original_image
        yq_calculate_clip_rect()
        yq_imageView.image = yq_edit_image
        yq_layout_initial_image(animate: true)
        
        // 执行还原动画
        let toFrame = convert(yq_container_view.frame, from: yq_scrollView)
        yq_animate_fake_imageView {
            self.yq_fake_animate_imageView.transform = transform
            self.yq_fake_animate_imageView.frame = toFrame
        }
    }
}

extension CGFloat {
    var toPi: CGFloat {
        return self / 180 * .pi
    }
}

extension JYClipImageView {
    /// 计算初始裁剪范围（根据选中比例）
    func yq_calculate_clip_rect() {
        if yq_current_radio.yq_width_height_ratio == 0 {
            // 自由比例：裁剪范围为整张图片
            yq_edit_rect = CGRect(origin: .zero, size: yq_edit_image.size)
        } else {
            // 固定比例：计算适配图片的最大裁剪范围
            let imageSize = yq_edit_image.size
            let imageWHRatio = imageSize.width / imageSize.height
            let targetRatio = yq_current_radio.yq_width_height_ratio
            
            var w: CGFloat = 0, h: CGFloat = 0
            if targetRatio >= imageWHRatio {
                // 目标比例更宽 → 宽度适配图片，高度按比例计算
                w = imageSize.width
                h = w / targetRatio
            } else {
                // 目标比例更高 → 高度适配图片，宽度按比例计算
                h = imageSize.height
                w = h * targetRatio
            }
            
            // 居中显示裁剪范围
            yq_edit_rect = CGRect(
                x: (imageSize.width - w) / 2,
                y: (imageSize.height - h) / 2,
                width: w,
                height: h
            )
        }
    }
}

extension JYClipImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return yq_container_view
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        startEditing()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        guard scrollView == yq_scrollView else {
            return
        }
        if !scrollView.isDragging {
            //                    startTimer()
            endEditing()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView == yq_scrollView else {
            return
        }
        startEditing()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == yq_scrollView else {
            return
        }
        //                startTimer()
        endEditing()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == yq_scrollView else {
            return
        }
        if !decelerate {
            //                startTimer()
            endEditing()
        }
    }
}

extension JYClipImageView {
    @objc private func yq_grid_pan_click(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: self)
        if pan.state == .began {
            startEditing()
            yq_begin_pan_point = point
            yq_clip_origin_frame = yq_clip_box_frame
            yq_pan_edge = yq_calculate_pan_edge(at: point)
        } else if pan.state == .changed {
            guard yq_pan_edge != .none else {
                return
            }
            
            updateClipBoxFrame(point: point)
        } else if pan.state == .cancelled || pan.state == .ended {
            yq_pan_edge = .none
            //            startTimer()
            endEditing()
        }
    }
}

extension JYClipImageView {
    private func startEditing() {
        yq_overlay_view.yq_begin_update()
    }
    
    private func endEditing() {
        yq_move_clip_content_to_center()
    }
}

extension JYClipImageView {
    /// 将裁剪内容归位到可视区域中心
    private func yq_move_clip_content_to_center() {
        let maxClipRect = yq_max_clip_frame
        var clipRect = yq_clip_box_frame
        
        // 过滤无效尺寸
        if clipRect.width < CGFloat.ulpOfOne || clipRect.height < CGFloat.ulpOfOne {
            return
        }
        
        // 计算归位缩放比例
        let scale = min(maxClipRect.width / clipRect.width, maxClipRect.height / clipRect.height)
        
        // 裁剪框中心点 → 可视区域中心点
        let focusPoint = CGPoint(x: clipRect.midX, y: clipRect.midY)
        let midPoint = CGPoint(x: maxClipRect.midX, y: maxClipRect.midY)
        
        // 计算归位后的裁剪框Frame
        clipRect.size.width = ceil(clipRect.width * scale)
        clipRect.size.height = ceil(clipRect.height * scale)
        clipRect.origin.x = maxClipRect.minX + ceil((maxClipRect.width - clipRect.width) / 2)
        clipRect.origin.y = maxClipRect.minY + ceil((maxClipRect.height - clipRect.height) / 2)
        
        // 计算滚动视图目标偏移
        var contentTargetPoint = CGPoint.zero
        contentTargetPoint.x = (focusPoint.x + yq_scrollView.contentOffset.x) * scale
        contentTargetPoint.y = (focusPoint.y + yq_scrollView.contentOffset.y) * scale
        
        var offset = CGPoint(x: contentTargetPoint.x - midPoint.x, y: contentTargetPoint.y - midPoint.y)
        offset.x = max(-clipRect.minX, offset.x)
        offset.y = max(-clipRect.minY, offset.y)
        
        // 更新裁剪框并执行归位动画
        yq_change_clip_box_frame(newFrame: clipRect, animate: true, updateInset: false, endEditing: true)
        UIView.animate(withDuration: 0.25) {
            // 调整缩放比例
            if scale < 1 - CGFloat.ulpOfOne || scale > 1 + CGFloat.ulpOfOne {
                self.yq_scrollView.zoomScale *= scale
                self.yq_scrollView.zoomScale = min(self.yq_scrollView.maximumZoomScale, self.yq_scrollView.zoomScale)
            }
            
            // 调整滚动偏移
            if self.yq_scrollView.zoomScale < self.yq_scrollView.maximumZoomScale - CGFloat.ulpOfOne {
                offset.x = min(self.yq_scrollView.contentSize.width - clipRect.maxX, offset.x)
                offset.y = min(self.yq_scrollView.contentSize.height - clipRect.maxY, offset.y)
                self.yq_scrollView.contentOffset = offset
            }
            
            // 更新内边距并显示旋转按钮/比例栏
            self.yq_update_main_scrollView_content_inset_scale()
        }
    }
}

extension JYClipImageView {
    private func yq_calculate_pan_edge(at point: CGPoint) -> JYClipImageView.ClipPanEdge {
        let frame = yq_clip_box_frame.insetBy(dx: -30, dy: -30)
        
        let cornerSize = CGSize(width: 60, height: 60)
        let topLeftRect = CGRect(origin: frame.origin, size: cornerSize)
        if topLeftRect.contains(point) {
            return .topLeft
        }
        
        let topRightRect = CGRect(origin: CGPoint(x: frame.maxX - cornerSize.width, y: frame.minY), size: cornerSize)
        if topRightRect.contains(point) {
            return .topRight
        }
        
        let bottomLeftRect = CGRect(origin: CGPoint(x: frame.minX, y: frame.maxY - cornerSize.height), size: cornerSize)
        if bottomLeftRect.contains(point) {
            return .bottomLeft
        }
        
        let bottomRightRect = CGRect(origin: CGPoint(x: frame.maxX - cornerSize.width, y: frame.maxY - cornerSize.height), size: cornerSize)
        if bottomRightRect.contains(point) {
            return .bottomRight
        }
        
        let topRect = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: cornerSize.height))
        if topRect.contains(point) {
            return .top
        }
        
        let bottomRect = CGRect(origin: CGPoint(x: frame.minX, y: frame.maxY - cornerSize.height), size: CGSize(width: frame.width, height: cornerSize.height))
        if bottomRect.contains(point) {
            return .bottom
        }
        
        let leftRect = CGRect(origin: frame.origin, size: CGSize(width: cornerSize.width, height: frame.height))
        if leftRect.contains(point) {
            return .left
        }
        
        let rightRect = CGRect(origin: CGPoint(x: frame.maxX - cornerSize.width, y: frame.minY), size: CGSize(width: cornerSize.width, height: frame.height))
        if rightRect.contains(point) {
            return .right
        }
        
        return .none
    }
    
    private func updateClipBoxFrame(point: CGPoint) {
        var frame = yq_clip_box_frame
        let originFrame = yq_clip_origin_frame
        
        var newPoint = point
        newPoint.x = max(yq_max_clip_frame.minX, newPoint.x)
        newPoint.y = max(yq_max_clip_frame.minY, newPoint.y)
        
        let diffX = ceil(newPoint.x - yq_begin_pan_point.x)
        let diffY = ceil(newPoint.y - yq_begin_pan_point.y)
        
        let whRatio = yq_current_radio.yq_width_height_ratio
        
        switch yq_pan_edge {
        case .left:
            frame.origin.x = originFrame.minX + diffX
            frame.size.width = originFrame.width - diffX
            if whRatio != 0 {
                frame.size.height = originFrame.height - diffX / whRatio
            }
        case .right:
            frame.size.width = originFrame.width + diffX
            if whRatio != 0 {
                frame.size.height = originFrame.height + diffX / whRatio
            }
        case .top:
            frame.origin.y = originFrame.minY + diffY
            frame.size.height = originFrame.height - diffY
            if whRatio != 0 {
                frame.size.width = originFrame.width - diffY * whRatio
            }
        case .bottom:
            frame.size.height = originFrame.height + diffY
            if whRatio != 0 {
                frame.size.width = originFrame.width + diffY * whRatio
            }
        case .topLeft:
            if whRatio != 0 {
                frame.origin.x = originFrame.minX + diffX
                frame.size.width = originFrame.width - diffX
                frame.origin.y = originFrame.minY + diffX / whRatio
                frame.size.height = originFrame.height - diffX / whRatio
            } else {
                frame.origin.x = originFrame.minX + diffX
                frame.size.width = originFrame.width - diffX
                frame.origin.y = originFrame.minY + diffY
                frame.size.height = originFrame.height - diffY
            }
        case .topRight:
            if whRatio != 0 {
                frame.size.width = originFrame.width + diffX
                frame.origin.y = originFrame.minY - diffX / whRatio
                frame.size.height = originFrame.height + diffX / whRatio
            } else {
                frame.size.width = originFrame.width + diffX
                frame.origin.y = originFrame.minY + diffY
                frame.size.height = originFrame.height - diffY
            }
        case .bottomLeft:
            if whRatio != 0 {
                frame.origin.x = originFrame.minX + diffX
                frame.size.width = originFrame.width - diffX
                frame.size.height = originFrame.height - diffX / whRatio
            } else {
                frame.origin.x = originFrame.minX + diffX
                frame.size.width = originFrame.width - diffX
                frame.size.height = originFrame.height + diffY
            }
        case .bottomRight:
            if whRatio != 0 {
                frame.size.width = originFrame.width + diffX
                frame.size.height = originFrame.height + diffX / whRatio
            } else {
                frame.size.width = originFrame.width + diffX
                frame.size.height = originFrame.height + diffY
            }
        default:
            break
        }
        
        let minSize: CGSize
        let maxSize: CGSize
        let yq_max_clip_frame: CGRect
        if whRatio != 0 {
            if whRatio >= 1 {
                minSize = CGSize(width: yq_min_clip_size.height * whRatio, height: yq_min_clip_size.height)
            } else {
                minSize = CGSize(width: yq_min_clip_size.width, height: yq_min_clip_size.width / whRatio)
            }
            if whRatio > self.yq_max_clip_frame.width / self.yq_max_clip_frame.height {
                maxSize = CGSize(width: self.yq_max_clip_frame.width, height: self.yq_max_clip_frame.width / whRatio)
            } else {
                maxSize = CGSize(width: self.yq_max_clip_frame.height * whRatio, height: self.yq_max_clip_frame.height)
            }
            yq_max_clip_frame = CGRect(origin: CGPoint(x: self.yq_max_clip_frame.minX + (self.yq_max_clip_frame.width - maxSize.width) / 2, y: self.yq_max_clip_frame.minY + (self.yq_max_clip_frame.height - maxSize.height) / 2), size: maxSize)
        } else {
            minSize = yq_min_clip_size
            maxSize = self.yq_max_clip_frame.size
            yq_max_clip_frame = self.yq_max_clip_frame
        }
        
        frame.size.width = min(maxSize.width, max(minSize.width, frame.size.width))
        frame.size.height = min(maxSize.height, max(minSize.height, frame.size.height))
        
        frame.origin.x = min(yq_max_clip_frame.maxX - minSize.width, max(frame.origin.x, yq_max_clip_frame.minX))
        frame.origin.y = min(yq_max_clip_frame.maxY - minSize.height, max(frame.origin.y, yq_max_clip_frame.minY))
        
        if yq_pan_edge == .topLeft || yq_pan_edge == .bottomLeft || yq_pan_edge == .left, frame.size.width <= minSize.width + CGFloat.ulpOfOne {
            frame.origin.x = originFrame.maxX - minSize.width
        }
        if yq_pan_edge == .topLeft || yq_pan_edge == .topRight || yq_pan_edge == .top, frame.size.height <= minSize.height + CGFloat.ulpOfOne {
            frame.origin.y = originFrame.maxY - minSize.height
        }
        
        yq_change_clip_box_frame(newFrame: frame, animate: false, updateInset: true)
    }
    
    /// 更新裁剪框Frame（含边界校验）
    /// - Parameters:
    ///   - newFrame: 新的裁剪框Frame
    ///   - animate: 是否开启动画
    ///   - updateInset: 是否更新滚动视图内边距
    ///   - fing: 是否结束编辑（更新遮罩层）
    private func yq_change_clip_box_frame(newFrame: CGRect, animate: Bool, updateInset: Bool, endEditing: Bool = false) {
        // 裁剪框未变化时直接返回（结束编辑时需更新遮罩层）
        guard yq_clip_box_frame != newFrame else {
            // 可能是拖拽图片和缩放图片，编辑区域未改变，这里也要调用下endUpdate
            if endEditing {
                yq_overlay_view.yq_end_update()
            }
            return
        }
        
        // 过滤无效尺寸
        if newFrame.width < CGFloat.ulpOfOne || newFrame.height < CGFloat.ulpOfOne {
            return
        }
        var frame = newFrame
        let maxClipFrame = self.yq_max_clip_frame
        
        // 左边界校验
        let originX = ceil(maxClipFrame.minX)
        let diffX = frame.minX - originX
        frame.origin.x = max(frame.minX, originX)
        if diffX < -CGFloat.ulpOfOne {
            frame.size.width += diffX
        }
        
        // 上边界校验
        let originY = ceil(maxClipFrame.minY)
        let diffY = frame.minY - originY
        frame.origin.y = max(frame.minY, originY)
        if diffY < -CGFloat.ulpOfOne {
            frame.size.height += diffY
        }
        
        // 右边界校验
        let maxW = maxClipFrame.width + maxClipFrame.minX - frame.minX
        frame.size.width = max(yq_min_clip_size.width, min(frame.width, maxW))
        
        // 下边界校验
        let maxH = maxClipFrame.height + maxClipFrame.minY - frame.minY
        frame.size.height = max(yq_min_clip_size.height, min(frame.height, maxH))
        
        yq_clip_box_frame = frame
        yq_overlay_view.yq_update_layers(frame, animate: animate, endEditing: endEditing)
        
        if updateInset {
            yq_update_main_scrollView_content_inset_scale()
        }
    }
    
    /// 更新滚动视图内边距和缩放比例
    private func yq_update_main_scrollView_content_inset_scale() {
        let frame = yq_clip_box_frame
        
        yq_scrollView.contentInset = UIEdgeInsets(top: frame.minY, left: frame.minX, bottom: yq_scrollView.frame.maxY - frame.maxY, right: yq_scrollView.frame.maxX - frame.maxX)
        
        let scale = max(frame.height / yq_edit_image.size.height, frame.width / yq_edit_image.size.width)
        yq_scrollView.minimumZoomScale = scale
        
        yq_scrollView.zoomScale = yq_scrollView.zoomScale
    }
    
    // MARK: - 裁剪范围计算
    /// 计算最大裁剪范围（屏幕可视区域，排除安全区、工具条）
    /// - Returns: 最大裁剪区域CGRect
    private func yq_calculate_max_clip_frame() -> CGRect {
        var insets = safeAreaInsets
        insets.top += 20
        var rect = CGRect.zero
        rect.origin.x = 15
        rect.origin.y = insets.top
        rect.size.width = UIScreen.main.bounds.width - 15 * 2
        rect.size.height = UIScreen.main.bounds.height - insets.top - 90 - 70 - 25
        return rect
    }
}

extension JYClipImageView {
    // MARK: - 动画处理
    /// 配置旋转/还原/切换比例的动画占位View
    private func yq_config_fake_animate_imageView() {
        yq_fake_animate_imageView.transform = .identity
        yq_fake_animate_imageView.image = yq_edit_image
        let originFrame = convert(yq_container_view.frame, from: yq_scrollView)
        yq_fake_animate_imageView.frame = originFrame
        insertSubview(yq_fake_animate_imageView, belowSubview: yq_overlay_view)
    }
    
    /// 执行图片动画（旋转/还原/切换比例）
    /// - Parameters:
    ///   - animations: 动画闭包
    ///   - completion: 完成闭包
    private func yq_animate_fake_imageView(animations: @escaping (() -> Void), completion: (() -> Void)? = nil) {
        
        yq_container_view.alpha = 0
        yq_is_being_animate = true
        
        UIView.animate(withDuration: 0.25) {
            animations()
        } completion: { _ in
            self.yq_container_view.alpha = 1
            self.yq_is_being_animate = false
            self.yq_fake_animate_imageView.removeFromSuperview()
            completion?()
        }
    }
}

extension JYClipImageView {
    /// 裁剪图片（根据当前裁剪框和旋转角度）
    /// - Returns: 裁剪后的图片 + 相对编辑图片的裁剪范围
    func yq_clip_image() -> (clipImage: UIImage, editRect: CGRect) {
        let frame = yq_convert_clip_rect_to_edit_image_rect()
        let clipImage = yq_edit_image.clipImage(angle: 0, editRect: frame, isCircle: yq_current_radio.yq_is_circle)
        return (clipImage, frame)
    }
    
    /// 将裁剪框Frame转换为相对编辑图片的裁剪范围
    /// - Returns: 相对编辑图片的CGRect
    private func yq_convert_clip_rect_to_edit_image_rect() -> CGRect {
        let imageSize = yq_edit_image.size
        let contentSize = yq_scrollView.contentSize
        let offset = yq_scrollView.contentOffset
        let insets = yq_scrollView.contentInset
        
        var frame = CGRect.zero
        // X坐标：滚动偏移 + 内边距 → 转换为图片相对坐标
        frame.origin.x = floor((offset.x + insets.left) * (imageSize.width / contentSize.width))
        frame.origin.x = max(0, frame.origin.x)
        
        // Y坐标：同上
        frame.origin.y = floor((offset.y + insets.top) * (imageSize.height / contentSize.height))
        frame.origin.y = max(0, frame.origin.y)
        
        // 宽度：裁剪框宽度 → 转换为图片相对宽度
        frame.size.width = ceil(yq_clip_box_frame.width * (imageSize.width / contentSize.width))
        frame.size.width = min(imageSize.width, frame.width)
        
        // 高度：同上
        frame.size.height = ceil(yq_clip_box_frame.height * (imageSize.height / contentSize.height))
        frame.size.height = min(imageSize.height, frame.height)
        
        return frame
    }
}
