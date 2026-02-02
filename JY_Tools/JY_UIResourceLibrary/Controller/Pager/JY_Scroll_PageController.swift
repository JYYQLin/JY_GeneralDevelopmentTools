//
//  JY_Scroll_PageController.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2026/1/7.
//

import UIKit

open class JY_Scroll_PageController: JY_PageController {

    /**
     滚动百分比，只有在transitionStyle == .scroll, navigationOrientation == .horizontal时才会启用
     direction：滚动方向Page
     percentage：百分比
     */
    public var yq_scroll_percentage_block: ((_ direction: UIPageViewController.NavigationDirection, _ percentage: CGFloat) -> Void)?
    
    private(set) lazy var yq_last_contentOffset_X: CGFloat = 0

    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: navigationOrientation)
    }
    
    required public init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension JY_Scroll_PageController {
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 查找 UIPageViewController 内部的 UIScrollView
        for subview in view.subviews {
            if let scrollView = subview as? UIScrollView {
                scrollView.delegate = self
                break
            }
        }
    }
}

extension JY_Scroll_PageController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let pageWidth = scrollView.bounds.width
        let offsetX = scrollView.contentOffset.x
        
        let originPercentage = offsetX / pageWidth
        let percentage = (offsetX.truncatingRemainder(dividingBy: pageWidth) / pageWidth)

        if offsetX > yq_last_contentOffset_X {
             // 向右滚动
            yq_scroll_percentage_block?(.forward, percentage)
//             print("百分比: \(percentage * 100)%")
         } else if offsetX < yq_last_contentOffset_X {
             // 向左滚动
             yq_scroll_percentage_block?(.reverse, (1 - percentage))
//             print("百分比: \(100 - percentage * 100)%")
         }

         yq_last_contentOffset_X = offsetX
    }
}
