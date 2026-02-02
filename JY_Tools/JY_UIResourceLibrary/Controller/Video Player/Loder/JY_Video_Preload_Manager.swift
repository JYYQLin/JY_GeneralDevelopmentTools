//
//  JY_Video_Preload_Manager.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/9/16.
//

import Foundation

public class JY_Video_Preload_Manager: NSObject {
    
    public static let shared = JY_Video_Preload_Manager()
    
    public var preloadByteCount: Int = 1024 * 1024 // = 1M
    
    public var didStart: (() -> Void)?
    public var didPause: (() -> Void)?
    public var didFinish: ((Error?) -> Void)?
    
    private var downloader: JY_Video_Downloader?
    private var isAutoStart: Bool = true
    private var waitingQueue: [URL] = []
    
    public func set(waiting: [URL]) {
        downloader = nil
        waitingQueue = waiting
        if isAutoStart { start() }
    }
    
    func start() {
        guard downloader == nil, waitingQueue.count > 0 else {
            downloader?.resume()
            return
        }
        
        isAutoStart = true
        
        let url = waitingQueue.removeFirst()
        
        guard
            !JY_Video_Loader_Manager.shared.loaderMap.keys.contains(url),
            let cacheHandler = try? JY_Video_Cache_Handler(url: url) else {
            return
        }
        
        downloader = JY_Video_Downloader(url: url, cacheHandler: cacheHandler)
        downloader?.delegate = self
        downloader?.download(from: 0, length: preloadByteCount)
        
        if cacheHandler.configuration.downloadedByteCount < preloadByteCount {
            didStart?()
        }
    }
    
    func pause() {
        downloader?.suspend()
        didPause?()
        isAutoStart = false
    }
    
    func remove(url: URL) {
        if let index = waitingQueue.firstIndex(of: url) {
            waitingQueue.remove(at: index)
        }
        
        if downloader?.url == url {
            downloader = nil
        }
    }
}

extension JY_Video_Preload_Manager: JY_Video_Downloader_Delegate {
    
    public func downloader(_ downloader: JY_Video_Downloader, didReceive response: URLResponse) {
    }
    
    public func downloader(_ downloader: JY_Video_Downloader, didReceive data: Data) {
    }
    
    public func downloader(_ downloader: JY_Video_Downloader, didFinished error: Error?) {
        self.downloader = nil
        start()
        didFinish?(error)
    }
}
