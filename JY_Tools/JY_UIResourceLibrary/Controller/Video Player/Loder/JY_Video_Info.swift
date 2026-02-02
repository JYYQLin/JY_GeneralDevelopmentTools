//
//  JY_Video_Info.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/9/16.
//

import Foundation

struct JY_Video_Info: Codable {
    
    var contentLength: Int
    var contentType: String
    var isByteRangeAccessSupported: Bool
    
    init(contentLength: Int, contentType: String, isByteRangeAccessSupported: Bool) {
        self.contentLength = contentLength
        self.contentType = contentType
        self.isByteRangeAccessSupported = isByteRangeAccessSupported
    }
    
}
