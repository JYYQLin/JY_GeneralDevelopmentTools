//
//  JY_Video_Loader.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/9/16.
//

import AVFoundation

protocol JY_Video_Loader_Delegate: AnyObject {
    
    func loader(_ loader: JY_Video_Loader, didFail error: Error)
    func loaderDidFinish(_ loader: JY_Video_Loader)
}

class JY_Video_Loader {
    
    weak var delegate: JY_Video_Loader_Delegate?
    
    let url: URL
    
    private let cacheHandler: JY_Video_Cache_Handler
    private let downloader: JY_Video_Downloader
    
    private var requestLoaders: [JY_Video_Request_Loader] = []
    
    init(url: URL) throws {
        self.url = url
        self.cacheHandler = try JY_Video_Cache_Handler(url: url)
        self.downloader = JY_Video_Downloader(url: url, cacheHandler: cacheHandler)
    }
    
    func append(request: AVAssetResourceLoadingRequest) {
        let requestLoader: JY_Video_Request_Loader
        
        if requestLoaders.count > 0 {
            let downloader = JY_Video_Downloader(url: url, cacheHandler: cacheHandler)
            requestLoader = JY_Video_Request_Loader(request: request, downloader: downloader)
        } else {
            requestLoader = JY_Video_Request_Loader(request: request, downloader: downloader)
        }
        
        requestLoaders.append(requestLoader)
        requestLoader.delegate = self
        requestLoader.start()
    }
    
    func remove(request: AVAssetResourceLoadingRequest) {
        if let index = requestLoaders.firstIndex(where: { $0.request == request }) {
            requestLoaders[index].finish()
            requestLoaders.remove(at: index)
        }
    }
    
    func cancel() {
        downloader.cancel()
        requestLoaders.removeAll()
    }
    
}

extension JY_Video_Loader: JY_Video_Request_Loader_Delegate {

    func loader(_ loader: JY_Video_Request_Loader, didFinish error: Error?) {
        remove(request: loader.request)
        
        if let error = error {
            delegate?.loader(self, didFail: error)
        } else if requestLoaders.isEmpty {
            delegate?.loaderDidFinish(self)
        }
    }
    
}
