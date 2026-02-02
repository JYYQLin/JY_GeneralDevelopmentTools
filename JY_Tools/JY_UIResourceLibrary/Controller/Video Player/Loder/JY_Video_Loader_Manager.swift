//
//  JY_Video_Loader_Manager.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/9/16.
//

import AVFoundation

public class JY_Video_Loader_Manager: NSObject {
    
    public static let shared = JY_Video_Loader_Manager()
    
    public var reportError: ((Error) -> Void)?
    
    public var customHTTPHeaderFields: ((URL) -> [String: String]?)?
    
    private(set) var loaderMap: [URL: JY_Video_Loader] = [:]
    
}

extension JY_Video_Loader_Manager: AVAssetResourceLoaderDelegate {

    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        guard let url = loadingRequest.url else {
            reportError?(NSError(
                domain: "me.gesen.player.loader",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Unsupported load request (\(loadingRequest))"]
            ))
            return false
        }
        
        JY_Video_Preload_Manager.shared.remove(url: url)
        
        do {
            if let loader = loaderMap[url] {
                loader.append(request: loadingRequest)
            } else {
                let loader = try JY_Video_Loader(url: url)
                loader.delegate = self
                loader.append(request: loadingRequest)
                loaderMap[url] = loader
            }
            return true
        } catch {
            reportError?(error)
            return false
        }
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        
        guard let url = loadingRequest.url, let loader = loaderMap[url] else {
            return
        }
        
        loader.remove(request: loadingRequest)
    }
    
}

extension JY_Video_Loader_Manager: JY_Video_Loader_Delegate {
    
    func loader(_ loader: JY_Video_Loader, didFail error: Error) {
        reportError?(error)
        loaderMap.removeValue(forKey: loader.url)
    }
    
    func loaderDidFinish(_ loader: JY_Video_Loader) {
        loaderMap.removeValue(forKey: loader.url)
    }
}
