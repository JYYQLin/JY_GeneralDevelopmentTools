//
//  JY_Video_Cache_Configuration.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/9/16.
//

import Foundation

//  MARK: 视频缓存配置
public struct JY_Video_Cache_Configuration: Codable {
    
    static func configuration(for videoFilePath: String) throws -> JY_Video_Cache_Configuration {
        let filePath = configurationFilePath(for: videoFilePath)
        
        guard
            FileManager.default.fileExists(atPath: filePath),
            let data = FileManager.default.contents(atPath: filePath)
            else { return JY_Video_Cache_Configuration(filePath: filePath) }
        
        var configuration = try JSONDecoder().decode(JY_Video_Cache_Configuration.self, from: data)
        configuration.filePath = filePath
        
        return configuration
    }
    
    static func configurationFilePath(for filePath: String) -> String {
        return filePath.appendingPathExtension("cfg")!
    }
    
    var info: JY_Video_Info?

    private(set) var fragments: [NSRange] = []
    
    var downloadedByteCount: Int {
        return fragments.reduce(0) { $0 + $1.length }
    }
    
    var progress: Double {
        return Double(downloadedByteCount) / Double(info?.contentLength ?? -1)
    }
    
    private var filePath: String
    
    private init(filePath: String) {
        self.filePath = filePath
    }
    
    mutating func add(fragment: NSRange) {
        guard
            fragment.location != NSNotFound,
            fragment.length > 0
            else { return }
        
        if fragments.count == 0 {
            fragments.append(fragment)
            return
        }
        
        var indexSet = IndexSet()
        
        for (i, range) in fragments.enumerated() {
            if fragment.upperBound <= range.location {
                if indexSet.count == 0 { indexSet.insert(i) }
                break
            } else if fragment.location <= range.upperBound && fragment.upperBound > range.location {
                indexSet.insert(i)
            } else if fragment.location >= range.upperBound {
                if i == fragments.count - 1 { indexSet.insert(i) }
            }
        }
        
        guard
            let firstIndex = indexSet.first,
            let lastIndex = indexSet.last
            else { return }
        
        if indexSet.count == 1 {
            
            var range1 = fragments[firstIndex]
            range1.length += 1
            
            var range2 = fragment
            range2.length += 1
            
            let intersection = NSIntersectionRange(range1, range2)
            
            if intersection.length == 0 {
                if fragment.location < fragments[firstIndex].location {
                    fragments.insert(fragment, at: firstIndex)
                } else {
                    fragments.insert(fragment, at: lastIndex + 1)
                }
                return
            }
        }
        
        let location = min(fragments[firstIndex].location, fragment.location)
        let upperBound = max(fragments[lastIndex].upperBound, fragment.upperBound)
        let combine = NSRange(location: location, length: upperBound - location)
        
        fragments = fragments
            .enumerated()
            .compactMap { indexSet.contains($0.0) ? nil : $0.1 }
        
        fragments.insert(combine, at: firstIndex)
    }
    
    func save() {
        do {
            if FileManager.default.fileExists(atPath: filePath) {
                try FileManager.default.removeItem(atPath: filePath)
            }
            
            if !FileManager.default.createFile(
                atPath: filePath,
                contents: try JSONEncoder().encode(self),
                attributes: nil
            ) {
                throw NSError(
                    domain: "me.gesen.player.cache",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to create file"]
                )
            }
        } catch {
            JY_Video_Loader_Manager.shared.reportError?(error)
        }
    }
}
