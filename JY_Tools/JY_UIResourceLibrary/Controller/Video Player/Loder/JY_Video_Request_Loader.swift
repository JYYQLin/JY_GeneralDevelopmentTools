//
//  JY_Video_Request_Loader.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/9/16.
//

import AVFoundation

protocol JY_Video_Request_Loader_Delegate: AnyObject {
    
    func loader(_ loader: JY_Video_Request_Loader, didFinish error: Error?)
    
}

class JY_Video_Request_Loader {
    
    weak var delegate: JY_Video_Request_Loader_Delegate?
    
    let request: AVAssetResourceLoadingRequest
    
    private let downloader: JY_Video_Downloader
    
    init(request: AVAssetResourceLoadingRequest, downloader: JY_Video_Downloader) {
        self.request = request
        self.downloader = downloader
        self.downloader.delegate = self
        self.fulfillContentInfomation()
    }
    
    func start() {
        guard
            let dataRequest = request.dataRequest else {
            return
        }
        
        var offset = Int(dataRequest.requestedOffset)
        let length = Int(dataRequest.requestedLength)

        if dataRequest.currentOffset != 0 {
            offset = Int(dataRequest.currentOffset)
        }
        
        if dataRequest.requestsAllDataToEndOfResource {
            downloader.downloadToEnd(from: offset)
        } else {
            downloader.download(from: offset, length: length)
        }
    }
    
    func cancel() {
        downloader.cancel()
    }
    
    func finish() {
        if !request.isFinished {
            request.finishLoading(with: NSError(
                domain: "me.gesen.player.loader",
                code: NSURLErrorCancelled,
                userInfo: [NSLocalizedDescriptionKey: "Video load request is canceled"])
            )
        }
    }
    
}

extension JY_Video_Request_Loader: JY_Video_Downloader_Delegate {
    
    func downloader(_ downloader: JY_Video_Downloader, didReceive response: URLResponse) {
        fulfillContentInfomation()
    }
    
    func downloader(_ downloader: JY_Video_Downloader, didReceive data: Data) {
        
        request.dataRequest?.respond(with: data)
    }
    
    func downloader(_ downloader: JY_Video_Downloader, didFinished error: Error?) {
        guard (error as NSError?)?.code != NSURLErrorCancelled else { return }
        
        if error == nil {
            request.finishLoading()
        } else {
            request.finishLoading(with: error)
        }
        
        delegate?.loader(self, didFinish: error)
    }
    
}

private extension JY_Video_Request_Loader {
    
    func fulfillContentInfomation() {
        guard
            let info = downloader.info,
            request.contentInformationRequest != nil else {
            return
        }
        
        request.contentInformationRequest?.contentType = info.contentType
        request.contentInformationRequest?.contentLength = Int64(info.contentLength)
        request.contentInformationRequest?.isByteRangeAccessSupported = info.isByteRangeAccessSupported
    }
    
}
