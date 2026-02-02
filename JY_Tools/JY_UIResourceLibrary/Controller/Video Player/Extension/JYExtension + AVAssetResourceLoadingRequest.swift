//
//  JYExtension + AVAssetResourceLoadingRequest.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/9/16.
//

import AVFoundation

extension AVAssetResourceLoadingRequest {
    
    var url: URL? {
        request.url?.deconstructed
    }
    
}
