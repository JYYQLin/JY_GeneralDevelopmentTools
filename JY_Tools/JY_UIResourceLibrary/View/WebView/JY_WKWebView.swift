//
//  JY_WKWebView.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/24.
//

import UIKit
import WebKit

open class JY_WKWebView: JY_View {
    
    public var urlString: String = ""
    
    private lazy var wkWebView: WKWebView = {
        let webConfig = WKWebViewConfiguration()
        // 基础配置：允许JS、自动播放等（可根据需求调整）
       
        // 1. 通用Preferences配置（全版本有效）
        let preferences = WKPreferences()
        // JS弹窗/新开窗口权限（全版本都在WKPreferences里）
        preferences.javaScriptCanOpenWindowsAutomatically = false
        webConfig.preferences = preferences
        
        // 2. iOS 14+ 适配：JS执行权限（替代废弃的javaScriptEnabled）
        if #available(iOS 14.0, *) {
            let webpagePrefs = WKWebpagePreferences()
            webpagePrefs.allowsContentJavaScript = true // 允许网页执行JS
            webConfig.defaultWebpagePreferences = webpagePrefs
        } else {
            // iOS 14以下：使用废弃的API（向下兼容）
            preferences.javaScriptEnabled = true
        }
        
        let webView = WKWebView(frame: .zero, configuration: webConfig)
        webView.navigationDelegate = self
//        webView.uiDelegate = self
        webView.scrollView.bounces = true
        webView.backgroundColor = .white
        
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        
        return webView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        // 进度条颜色（可自定义）
        progressView.progressTintColor = UIColor(named: "AccentColor")
        // 进度条背景色
        progressView.trackTintColor = .lightGray.withAlphaComponent(0.3)
        // 初始隐藏
        progressView.isHidden = true
        return progressView
    }()
}

extension JY_WKWebView {
    open override func yq_add_subviews() {
        super.yq_add_subviews()
        
        addSubview(wkWebView)
        addSubview(progressView)
    }
}

extension JY_WKWebView {
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        wkWebView.frame = bounds
        wkWebView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: safeAreaInsets.bottom, right: 0)
        progressView.frame = CGRect(x: 0, y: 0, width: frame.width, height: 2 * yq_scale)
        progressView.tintColor = UIColor(named: "AccentColor")
    }
}

extension JY_WKWebView {
    public func set(url: String) {
        urlString = url
        
        guard let url1 = URL(string: urlString) else {
            JY_TipHUD.showDanger(tip: "无效的URL地址")
            return
        }
        
        let request = URLRequest(url: url1)
        wkWebView.load(request)
    }
}

// MARK: - WKNavigationDelegate（监听加载状态和进度）
extension JY_WKWebView: WKNavigationDelegate {
    /// 开始加载网页
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
        progressView.setProgress(0.0, animated: false)
    }
    
    /// 实时更新加载进度
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // 监听estimatedProgress的KVO（也可以用闭包监听，这里用KVO更经典）
        webView.addObserver(self,
                            forKeyPath: "estimatedProgress",
                            options: .new,
                            context: nil)
    }
    
    /// 加载完成
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 进度条动画到100%后隐藏
        UIView.animate(withDuration: 0.3, animations: {
            self.progressView.setProgress(1.0, animated: true)
        }) { _ in
            self.progressView.isHidden = true
            self.progressView.setProgress(0.0, animated: false)
        }
        // 移除KVO监听
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    /// 加载失败
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        showLoadError(message: "网页加载失败：\(error.localizedDescription)")
        progressView.isHidden = true
        progressView.setProgress(0.0, animated: false)
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    // MARK: - KVO监听进度
    open override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress", let webView = object as? WKWebView {
            // 同步进度条进度（动画过渡）
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
}
