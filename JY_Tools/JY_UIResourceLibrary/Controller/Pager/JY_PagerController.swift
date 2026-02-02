//
//  JY_PagerController.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2026/1/7.
//

import UIKit

open class JY_PageController: UIPageViewController {
    // MARK: - 回调闭包（优化命名：小驼峰+语义化，保留yq_前缀）
    /** 即将翻动到下一页的block
     direction：翻页方向
     willPage：即将出现的页面
     */
    public var yq_WillScrollPageBlock: ((_ direction: NavigationDirection, _ currentPage: Int, _ willPage: Int) -> Void)?
    
    /** 页码变动的block */
    public var yq_pageIndexBlock: ((_ index: Int) -> Void)?
    
    // MARK: - 核心属性（优化命名+简化初始化）
    public lazy var yq_currentPageIndex: Int = 0 {
        didSet {
            yq_pageIndexBlock?(yq_currentPageIndex)
        }
    }
        
    public lazy var yq_controllerArray: [UIViewController] = []
    
    // MARK: - 初始化（优化：提供默认初始化参数，更易用）
    override init(
        transitionStyle style: TransitionStyle = .scroll,
        navigationOrientation: NavigationOrientation = .horizontal,
        options: [OptionsKey : Any]? = nil
    ) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 生命周期
extension JY_PageController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
    }
}

// MARK: - 核心业务方法（优化：修复索引更新、内存管理、逻辑冗余）
extension JY_PageController {
    /// 设置指定页码（优化：动画完成后更新索引，避免数据不一致）
    public func set(
        pageIndex: Int,
        direction: NavigationDirection? = nil,
        animated: Bool = true
    ) {
        // 边界校验：索引合法+非当前页
        guard pageIndex >= 0,
              pageIndex < yq_controllerArray.count,
              pageIndex != yq_currentPageIndex else {
            return
        }
        
        let targetVC = yq_controllerArray[pageIndex]
        // 自动推导翻页方向（简化冗余逻辑）
        let finalDirection = direction ?? (pageIndex < yq_currentPageIndex ? .reverse : .forward)
        
        // 执行翻页，动画完成后更新索引（weak self 避免循环引用）
        setViewControllers([targetVC], direction: finalDirection, animated: animated) { [weak self] completed in
            guard let self = self, completed else { return }
            self.yq_currentPageIndex = pageIndex
        }
    }
    
    /// 替换控制器数组（优化：正确处理控制器生命周期，避免内存泄漏）
    public func set(
        controllerArray: [UIViewController],
        animated: Bool = false
    ) {
        // 1. 移除旧控制器（完整生命周期处理）
        yq_controllerArray.forEach { vc in
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
        yq_controllerArray.removeAll()
        
        // 2. 添加新控制器（建立父子关系，符合UIKit规范）
        yq_controllerArray = controllerArray
        yq_controllerArray.forEach { vc in
            addChild(vc)
        }
        
        // 3. 显示第一个控制器（动画完成后更新索引）
        guard let firstVC = yq_controllerArray.first else { return }
        setViewControllers([firstVC], direction: .forward, animated: animated) { [weak self] _ in
            guard let self = self else { return }
            self.yq_currentPageIndex = 0
        }
    }
    
    /// 追加控制器数组（优化：添加父子关系，避免视图层级异常）
    public func yq_Add(
        controllerArray: [UIViewController],
        animated: Bool = true,
        autoScroll: Bool = false
    ) {
        // 给新控制器建立父子关系
        controllerArray.forEach { vc in
            addChild(vc)
        }
        yq_controllerArray.append(contentsOf: controllerArray)
        
        // 自动滚动到新添加的第一个控制器
        if autoScroll, let firstVC = controllerArray.first, let targetIndex = safeIndex(of: firstVC) {
            set(pageIndex: targetIndex, animated: animated)
        }
    }
    
    /// 插入控制器数组到头部（优化：修复原逻辑错误，autoScroll滚动到最后一个插入的控制器）
    public func yq_Inset(
        controllerArray: [UIViewController],
        animated: Bool = true,
        autoScroll: Bool = false
    ) {
        // 给新控制器建立父子关系
        controllerArray.forEach { vc in
            addChild(vc)
        }
        yq_controllerArray.insert(contentsOf: controllerArray, at: 0)
        
        // 自动滚动到最后一个插入的控制器（修复原逻辑错误：原代码取controllerArray.last但方向是reverse，现在直接用set方法自动推导方向）
        if autoScroll, let lastVC = controllerArray.last, let targetIndex = safeIndex(of: lastVC) {
            set(pageIndex: targetIndex, animated: animated)
        }
    }
}

// MARK: - 私有辅助方法（优化：统一索引查找逻辑，提升健壮性）
private extension JY_PageController {
    /// 安全查找控制器索引（用引用比较===，比Equatable更可靠）
    func safeIndex(of vc: UIViewController?) -> Int? {
        guard let vc = vc else { return nil }
        return yq_controllerArray.firstIndex { $0 === vc }
    }
}

// MARK: - UIPageViewControllerDataSource（优化：使用safeIndex，提升健壮性）
extension JY_PageController: UIPageViewControllerDataSource {
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let currentIndex = safeIndex(of: viewController), currentIndex > 0 else {
            return nil
        }
        return yq_controllerArray[currentIndex - 1]
    }
    
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let currentIndex = safeIndex(of: viewController),
              currentIndex < yq_controllerArray.count - 1 else {
            return nil
        }
        return yq_controllerArray[currentIndex + 1]
    }
}

// MARK: - UIPageViewControllerDelegate（优化：使用safeIndex，修复索引查找异常）
extension JY_PageController: UIPageViewControllerDelegate {
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let currentVC = pageViewController.viewControllers?.first,
              let currentIndex = safeIndex(of: currentVC) else {
            return
        }
        yq_currentPageIndex = currentIndex
    }
    
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]
    ) {
        guard let nextVC = pendingViewControllers.first,
              let nextIndex = safeIndex(of: nextVC) else {
            return
        }
        
        let direction: NavigationDirection = nextIndex > yq_currentPageIndex ? .forward : .reverse
        yq_WillScrollPageBlock?(direction, yq_currentPageIndex, nextIndex)
    }
}
