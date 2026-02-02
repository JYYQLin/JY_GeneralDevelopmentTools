//
//  JY_TextPaginationTool.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2026/1/30.
//

//import UIKit
//import CommonCrypto // 用于MD5生成缓存key（若项目禁用CommonCrypto，可替换为其他哈希方式）
//
///// 文字分页工具类（小说阅读专用，异步优先+同步兜底+缓存+任务取消）
//class JY_TextPaginationTool: NSObject {
//    // MARK: - 分页配置模型（全可配置，贴合小说阅读排版）
//    struct PaginationConfig: Hashable { // 实现Hashable用于缓存key生成
//        var font: UIFont = UIFont.systemFont(ofSize: 17) // 阅读字体
//        var textColor: UIColor = .black // 文字颜色（暂用于排版，可扩展）
//        var lineSpacing: CGFloat = 6.0 // 行间距
//        var paragraphSpacing: CGFloat = 10.0 // 段间距
//        var containerSize: CGSize // 阅读区域尺寸（宽高，核心）
//        var contentInset: UIEdgeInsets = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16) // 阅读区域内边距
//        var lineBreakMode: NSLineBreakMode = .byWordWrapping // 换行模式
//    }
//    
//    // MARK: - 类型定义
//    /// 分页回调闭包（主线程执行，可直接更新UI）
//    typealias PaginationCompletion = ([String]?, Error?) -> Void
//    /// 分页错误类型
//    enum PaginationError: LocalizedError {
//        case emptyText // 文本为空
//        case invalidContainerSize // 容器尺寸无效（宽/高≤0）
//        case fontError // 字体初始化失败
//        case unknownError // 未知错误
//        
//        var errorDescription: String? {
//            switch self {
//            case .emptyText: return "待分页文本不能为空"
//            case .invalidContainerSize: return "阅读区域尺寸无效（宽高需大于0）"
//            case .fontError: return "字体初始化失败，请检查字体名称"
//            case .unknownError: return "分页失败，请重试"
//            }
//        }
//    }
//    
//    // MARK: - 缓存配置（单例+NSCache，自动清理内存）
//    static let shared = JY_TextPaginationTool()
//    private let paginationCache = NSCache<NSString, NSArray>()
//    private override init() {} // 私有化构造，单例
//    
//    // MARK: - 核心异步分页方法（支持任务取消，推荐使用）
//    /// 异步分页（子线程计算，主线程回调，支持取消无效任务）
//    /// - Parameters:
//    ///   - text: 待分页完整文本（小说章节文本）
//    ///   - config: 分页排版配置
//    ///   - completion: 分页完成回调（主线程，返回分页数组/错误）
//    /// - Returns: DispatchWorkItem 分页任务（用于取消）
//    static func paginateAsync(text: String,
//                              config: PaginationConfig,
//                              completion: @escaping PaginationCompletion) -> DispatchWorkItem {
//        // 封装分页任务为DispatchWorkItem，支持取消
//        let workItem = DispatchWorkItem(qos: .utility, flags: .enforceQoS) {
//            do {
//                // 1. 前置校验（失败直接抛错）
//                try preCheck(text: text, config: config)
//                // 2. 先查缓存，有则直接返回，无则计算
//                let cacheKey = generateCacheKey(text: text, config: config)
//                if let cachePages = shared.paginationCache.object(forKey: cacheKey as NSString) as? [String], !cachePages.isEmpty {
//                    DispatchQueue.main.async { completion(cachePages, nil) }
//                    return
//                }
//                // 3. 核心分页计算（TextKit）
//                let pages = calculatePages(text: text, config: config)
//                // 4. 缓存结果
//                shared.paginationCache.setObject(pages as NSArray, forKey: cacheKey as NSString)
//                // 5. 主线程返回结果
//                DispatchQueue.main.async { completion(pages, nil) }
//            } catch {
//                // 异常情况主线程返回错误
//                DispatchQueue.main.async { completion(nil, error) }
//            }
//        }
//        // 执行任务（全局并发队列，低优先级不占用CPU）
//        DispatchQueue.global(qos: .utility).async(execute: workItem)
//        return workItem
//    }
//    
//    // MARK: - 同步分页方法（兜底使用，短文本快速分页）
//    /// 同步分页（主线程执行，短文本使用，大文本慎用）
//    /// - Parameters:
//    ///   - text: 待分页完整文本
//    ///   - config: 分页排版配置
//    /// - Returns: 分页数组
//    /// - Throws: 分页错误
//    static func paginateSync(text: String, config: PaginationConfig) throws -> [String] {
//        try preCheck(text: text, config: config)
//        // 查缓存
//        let cacheKey = generateCacheKey(text: text, config: config)
//        if let cachePages = shared.paginationCache.object(forKey: cacheKey as NSString) as? [String], !cachePages.isEmpty {
//            return cachePages
//        }
//        // 计算并缓存
//        let pages = calculatePages(text: text, config: config)
//        shared.paginationCache.setObject(pages as NSArray, forKey: cacheKey as NSString)
//        return pages
//    }
//    
//    // MARK: - 清除缓存（可选，如内存警告时调用）
//    /// 清除指定文本+配置的分页缓存
//    static func clearCache(for text: String, config: PaginationConfig) {
//        let cacheKey = generateCacheKey(text: text, config: config)
//        shared.paginationCache.removeObject(forKey: cacheKey as NSString)
//    }
//    
//    /// 清除所有分页缓存
//    static func clearAllCache() {
//        shared.paginationCache.removeAllObjects()
//    }
//}
//
//// MARK: - 私有核心方法（排版计算/校验/缓存key生成）
//private extension JY_TextPaginationTool {
//    /// 前置校验（文本/容器/字体）
//    static func preCheck(text: String, config: PaginationConfig) throws {
//        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            throw PaginationError.emptyText
//        }
//        if config.containerSize.width <= 0 || config.containerSize.height <= 0 {
//            throw PaginationError.invalidContainerSize
//        }
//        if config.font.pointSize <= 0 || config.font.familyName.isEmpty {
//            throw PaginationError.fontError
//        }
//    }
//    
//    /// 核心排版计算（TextKit三大组件实现分页，核心逻辑）
//    static func calculatePages(text: String, config: PaginationConfig) -> [String] {
//        // 1. 初始化TextKit三大核心组件
//        let textStorage = NSTextStorage()
//        let layoutManager = NSLayoutManager()
//        // 配置文本容器（匹配阅读区域）
//        let textContainer = NSTextContainer(size: config.containerSize)
//        textContainer.lineFragmentPadding = 0 // 去除默认内边距，避免排版偏差
//        textContainer.insets = config.contentInset // 设置阅读区域内边距
//        textContainer.lineBreakMode = config.lineBreakMode // 换行模式
//        textContainer.maximumNumberOfLines = 0 // 不限制行数
//        
//        // 2. 绑定TextKit组件
//        textStorage.addLayoutManager(layoutManager)
//        layoutManager.addTextContainer(textContainer)
//        
//        // 3. 配置富文本属性（字体/行间距/段间距）
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = config.lineSpacing
//        paragraphStyle.paragraphSpacing = config.paragraphSpacing
//        paragraphStyle.lineBreakMode = config.lineBreakMode
//        paragraphStyle.alignment = .left // 小说阅读默认左对齐
//        
//        let attrString = NSMutableAttributedString(string: text)
//        let fullRange = NSRange(location: 0, length: text.count)
//        attrString.addAttributes([
//            .font: config.font,
//            .foregroundColor: config.textColor,
//            .paragraphStyle: paragraphStyle
//        ], range: fullRange)
//        textStorage.setAttributedString(attrString)
//        
//        // 4. 逐页计算并分割文字（核心分页逻辑）
//        var pages: [String] = []
//        var currentLocation = 0 // 当前分页起始位置
//        let totalTextLength = textStorage.length
//        
//        while currentLocation < totalTextLength {
//            // 计算当前页可容纳的文字范围（基于glyph，排版更准确）
//            let glyphRange = layoutManager.glyphRange(forBoundingRect: CGRect(origin: .zero, size: config.containerSize), in: textContainer)
//            if glyphRange.length == 0 { break } // 无文字可分，退出循环
//            
//            // 转换为字符串范围，截取当前页文字
//            let stringRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
//            let pageText = (text as NSString).substring(with: stringRange)
//            pages.append(pageText)
//            
//            // 移动到下一页起始位置
//            currentLocation += stringRange.length
//            
//            // 重置布局管理器，准备下一页计算（避免排版缓存影响）
//            layoutManager.invalidateLayout(for: textStorage, range: NSRange(location: currentLocation, length: totalTextLength - currentLocation), actualRange: nil)
//        }
//        
//        return pages
//    }
//    
//    /// 生成缓存key（文本MD5 + 配置哈希值，保证唯一）
//    static func generateCacheKey(text: String, config: PaginationConfig) -> String {
//        // 文本MD5（避免相同文本重复计算）
//        let textMD5 = text.yq_md5()
//        // 配置哈希值（配置变化则重新计算）
//        let configHash = config.hashValue
//        // 组合成唯一key
//        return "\(textMD5)_\(configHash)"
//    }
//}
//
//// MARK: - UIViewController内存警告扩展（清除分页缓存）
//extension UIViewController {
//    /// 内存警告时清除分页缓存（推荐在阅读页面重写didReceiveMemoryWarning调用）
//    func clearPaginationCache() {
//        JY_TextPaginationTool.clearAllCache()
//    }
//}
