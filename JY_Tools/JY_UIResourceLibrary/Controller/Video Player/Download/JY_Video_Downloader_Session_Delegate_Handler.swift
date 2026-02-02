//
//  JY_Video_Downloader_Session_Delegate_Handler.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/9/16.
//

import Foundation

private let bufferSize = 1024 * 256

protocol JY_Video_Downloader_Session_Delegate_Handler_Delegate: AnyObject {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)

}

class JY_Video_Downloader_Session_Delegate_Handler: NSObject {
    
    weak var delegate: JY_Video_Downloader_Session_Delegate_Handler_Delegate?
    
    var buffer = Data()
    
    init(delegate: JY_Video_Downloader_Session_Delegate_Handler_Delegate) {
        self.delegate = delegate
    }
    
}

extension JY_Video_Downloader_Session_Delegate_Handler: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        delegate?.urlSession(session, didReceive: challenge, completionHandler: completionHandler)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        delegate?.urlSession(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
        
        guard buffer.count > bufferSize else { return }
        
        callbackBuffer(session: session, dataTask: dataTask)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if buffer.count > 0 && error == nil {
            callbackBuffer(session: session, dataTask: task as! URLSessionDataTask)
        }
        
        delegate?.urlSession(session, task: task, didCompleteWithError: error)
    }
    
}

private extension JY_Video_Downloader_Session_Delegate_Handler {
    
    private func callbackBuffer(session: URLSession, dataTask: URLSessionDataTask) {
        let range: Range<Int> = 0 ..< buffer.count
        let chunk = buffer.subdata(in: range)
        
        buffer.replaceSubrange(range, with: [], count: 0)
        
        delegate?.urlSession(session, dataTask: dataTask, didReceive: chunk)
    }
    
}
