//
//  JY_TextField.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/24.
//

import UIKit

/// 自定义TextField（支持自定义placeholder样式、缩放比例、内边距适配）
open class JY_TextField: UITextField {
    // MARK: - 可配置属性（规范命名+合理默认值+边界校验）
    /// 缩放比例（默认1.0，仅支持正数，设置后触发布局和视觉缩放）
    public private(set) var scale: CGFloat = 1.0 {
        didSet {
            guard scale != oldValue, scale > 0 else { return }
            // 视觉缩放：整体缩放TextField
            transform = CGAffineTransform(scaleX: scale, y: scale)
            // 触发布局刷新，适配内边距
            setNeedsLayout()
        }
    }
    
    /// Placeholder颜色（默认使用系统占位符文本色，适配iOS系统规范）
    public var placeholderColor: UIColor = .placeholderText {
        didSet {
            guard placeholderColor != oldValue else { return }
            updatePlaceholderStyle()
        }
    }
    
    /// Placeholder字体（默认系统17号字体，与系统TextField默认样式一致）
    public var placeholderFont: UIFont = .systemFont(ofSize: 17) {
        didSet {
            guard placeholderFont != oldValue else { return }
            updatePlaceholderStyle()
        }
    }
    
    // MARK: - 重写系统属性（触发placeholder样式自动更新）
    open override var placeholder: String? {
        didSet {
            updatePlaceholderStyle()
        }
    }
    
    open override var font: UIFont? {
        didSet {
            // 系统字体变化时，同步更新placeholder字体（保持样式一致性）
            guard let newFont = font, placeholderFont == oldValue else { return }
            placeholderFont = newFont
        }
    }
    
    // MARK: - 初始化方法（支持代码创建 + XIB/Storyboard创建）
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    // MARK: - 布局更新（移除无效代码，仅保留必要逻辑）
    open override func layoutSubviews() {
        super.layoutSubviews()
        // 如需基于scale自定义布局（如调整子视图位置），可在此补充
        // 示例：subviews.forEach { $0.center = self.center }
    }
    
    // MARK: - 自定义内边距（基于scale动态调整）
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        // 内边距随scale缩放：左右8pt * scale，上下4pt * scale
        return bounds.insetBy(dx: 8 * scale, dy: 4 * scale)
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        // 编辑状态复用普通状态的内边距（也可单独自定义）
        return textRect(forBounds: bounds)
    }
}

// MARK: - 私有方法（核心逻辑封装，对外不可见）
private extension JY_TextField {
    /// 初始化子视图（子类可重写此方法添加自定义子视图）
    func setupSubviews() {
        // 基础样式初始化（可选扩展）
        backgroundColor = .white
        borderStyle = .none
    }
    
    /// 更新Placeholder样式（使用系统公开API，无审核/兼容风险）
    func updatePlaceholderStyle() {
        guard let placeholderText = placeholder, !placeholderText.isEmpty else {
            attributedPlaceholder = nil
            return
        }
        
        // 用NSAttributedString设置placeholder样式（系统公开方案）
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor,
            .font: placeholderFont
        ]
        attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: placeholderAttributes
        )
    }
}

// MARK: - 外部公开方法（规范命名+参数校验）
extension JY_TextField {
    /// 设置缩放比例（对外公开方法，增加参数校验）
    /// - Parameter scale: 缩放比例（必须大于0，否则不生效）
    public func set(scale: CGFloat) {
        self.scale = max(scale, 0.1) // 限制最小缩放比例为0.1，避免过度缩小
    }
}
