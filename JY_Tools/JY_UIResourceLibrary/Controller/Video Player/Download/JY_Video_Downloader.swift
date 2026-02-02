//
//  JY_Video_Downloader.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/9/16.
//

import Foundation

public protocol JY_Video_Downloader_Delegate: AnyObject {
    
    func downloader(_ downloader: JY_Video_Downloader, didReceive response: URLResponse)
    func downloader(_ downloader: JY_Video_Downloader, didReceive data: Data)
    func downloader(_ downloader: JY_Video_Downloader, didFinished error: Error?)
    
}

public class JY_Video_Downloader {
    
    public weak var delegate: JY_Video_Downloader_Delegate?
    
    public let url: URL
    
    var info: JY_Video_Info? { return cacheHandler.configuration.info }
    
    private let cacheHandler: JY_Video_Cache_Handler
    private var downloaderHandler: JY_Video_Downloader_Handler?
    
    public init(url: URL, cacheHandler: JY_Video_Cache_Handler) {
        self.url = url
        self.cacheHandler = cacheHandler
    }
    
    public func downloadToEnd(from offset: Int) {
        download(from: offset, length: (info?.contentLength ?? offset) - offset)
    }
    
    public func download(from offset: Int, length: Int) {
        let actions = cacheHandler.actions(for: NSRange(location: offset, length: length))

        downloaderHandler = JY_Video_Downloader_Handler(url: url, actions: actions, cacheHandler: cacheHandler)
        downloaderHandler?.delegate = self
        downloaderHandler?.start()
    }
    
    public func resume() {
        downloaderHandler?.resume()
    }
    
    public func suspend() {
        downloaderHandler?.suspend()
    }
    
    public func cancel() {
        downloaderHandler?.cancel()
        downloaderHandler = nil
    }
    
}

extension JY_Video_Downloader: JY_Video_Downloader_Handler_Delegate {
    
    func handler(_ handler: JY_Video_Downloader_Handler, didReceive response: URLResponse) {
        
        if info == nil, let httpResponse = response as? HTTPURLResponse {
            
            let contentLength = String(httpResponse
                .value(forHeaderKey: "Content-Range")?
                .split(separator: "/").last ?? "0").int ?? 0
            
            let contentType = httpResponse
                .value(forHeaderKey: "Content-Type") ?? ""
            
            let isByteRangeAccessSupported = httpResponse
                .value(forHeaderKey: "Accept-Ranges")?
                .contains("bytes") ?? false
            
            cacheHandler.set(info: JY_Video_Info(
                contentLength: contentLength,
                contentType: contentType,
                isByteRangeAccessSupported: isByteRangeAccessSupported
            ))
        }
        
        delegate?.downloader(self, didReceive: response)
    }
    
    func handler(_ handler: JY_Video_Downloader_Handler, didReceive data: Data, isLocal: Bool) {
        delegate?.downloader(self, didReceive: data)
    }
    
    func handler(_ handler: JY_Video_Downloader_Handler, didFinish error: Error?) {
        delegate?.downloader(self, didFinished: error)
    }
    
}

private extension HTTPURLResponse {
    
    func value(forHeaderKey key: String) -> String? {
        return allHeaderFields
            .first { $0.key.description.caseInsensitiveCompare(key) == .orderedSame }?
            .value as? String
    }
    
}
