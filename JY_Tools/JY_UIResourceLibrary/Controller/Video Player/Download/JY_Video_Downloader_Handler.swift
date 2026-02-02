//
//  JY_Video_Downloader_Handler.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/9/16.
//

import Foundation

extension Notification.Name {
    
    public static let VideoDownloadProgressDidChanged = Notification.Name(rawValue: "me.gesen.player.downloader.progress.changed")
    
    public static let VideoDownloadDidFinished = Notification.Name("me.gesen.player.downloader.finished")
    
}

private let delegateQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 2
    return queue
}()

protocol JY_Video_Downloader_Handler_Delegate: AnyObject {
    
    func handler(_ handler: JY_Video_Downloader_Handler, didReceive response: URLResponse)
    func handler(_ handler: JY_Video_Downloader_Handler, didReceive data: Data, isLocal: Bool)
    func handler(_ handler: JY_Video_Downloader_Handler, didFinish error: Error?)
    
}

class JY_Video_Downloader_Handler {
    
    weak var delegate: JY_Video_Downloader_Handler_Delegate?
    
    private let url: URL
    private var actions: [JY_Video_Cache_Action]
    private let cacheHandler: JY_Video_Cache_Handler
    
    private var session: URLSession?
    private var sessionDelegate: JY_Video_Downloader_Session_Delegate_Handler?
    private var task: URLSessionDataTask?
    
    private var isCancelled = false
    private var startOffset = 0
    private var lastNotifyTime: TimeInterval = 0
    
    init(url: URL, actions: [JY_Video_Cache_Action], cacheHandler: JY_Video_Cache_Handler) {
        self.url = url
        self.actions = actions
        self.cacheHandler = cacheHandler
    }
    
    deinit {
        cancel()
    }
    
    func start() {
        processActions()
    }
    
    func cancel() {
        session?.invalidateAndCancel()
        isCancelled = true
    }
    
    func resume() {
        task?.resume()
    }
    
    func suspend() {
        task?.suspend()
    }
    
}

extension JY_Video_Downloader_Handler: JY_Video_Downloader_Session_Delegate_Handler_Delegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let trust = challenge.protectionSpace.serverTrust
        completionHandler(.useCredential, trust != nil ? URLCredential(trust: trust!) : nil)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        #if !os(macOS)
        guard
            let mimeType = response.mimeType,
            mimeType.contains("video/")
            else { completionHandler(.cancel); return }
        #endif
        
        delegate?.handler(self, didReceive: response)
        
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard !isCancelled else { return }
        
        let range = NSRange(location: startOffset, length: data.count)
        if cacheHandler.cache(data: data, for: range)
        {
            cacheHandler.save()
            
            startOffset += data.count
            
            delegate?.handler(self, didReceive: data, isLocal: false)
            notifyProgress(flush: false)
        }
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        cacheHandler.save()
        
        if let error = error {
            delegate?.handler(self, didFinish: error)
            notifyFinished(error: error)
        } else {
            notifyProgress(flush: true)
            notifyFinished(error: nil)
            processActions()
        }
    }
    
}

private extension JY_Video_Downloader_Handler {
    
    func processActions() {
        guard !isCancelled else { return }
        guard let action = actions.first else {
            delegate?.handler(self, didFinish: nil)
            return
        }
        
        actions.removeFirst()
        
        guard action.actionType == .remote else {
            let data = cacheHandler.cachedData(for: action.range)
            delegate?.handler(self, didReceive: data, isLocal: true)
            processActions()
            return
        }
        
        sessionDelegate = JY_Video_Downloader_Session_Delegate_Handler(delegate: self)
        
        session = URLSession(
            configuration: .ephemeral,
            delegate: JY_Video_Downloader_Session_Delegate_Handler(delegate: self),
            delegateQueue: .main
        )
        
        var urlRequest = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 60
        )
        
        let start = action.range.location
        let end = action.range.location + action.range.length - 1
        urlRequest.addValue("bytes=\(start)-\(end)", forHTTPHeaderField: "Range")
        
        for field in JY_Video_Loader_Manager.shared.customHTTPHeaderFields?(url) ?? [:] {
            urlRequest.addValue(field.value, forHTTPHeaderField: field.key)
        }
        
        startOffset = start
        
        task = session?.dataTask(with: urlRequest)
        task?.resume()
    }
    
    func notifyProgress(flush: Bool) {
        let currentTime = CFAbsoluteTimeGetCurrent()
        guard lastNotifyTime < currentTime - 0.1 || flush else { return }
        lastNotifyTime = currentTime
        
        let configuration = cacheHandler.configuration
        NotificationCenter.default.post(
            name: .VideoDownloadProgressDidChanged,
            object: nil,
            userInfo: ["configuration": configuration]
        )
    }
    
    func notifyFinished(error: Error?) {
        let configuration = cacheHandler.configuration
        var userInfo: [AnyHashable: Any] = ["configuration": configuration]
        if let error = error { userInfo[NSURLErrorKey] = error }
        
        NotificationCenter.default.post(
            name: .VideoDownloadDidFinished,
            object: nil,
            userInfo: userInfo
        )
    }
    
}
