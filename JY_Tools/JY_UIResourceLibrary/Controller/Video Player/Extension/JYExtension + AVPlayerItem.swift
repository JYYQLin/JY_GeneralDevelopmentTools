//
//  JYExtension + AVPlayerItem.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/9/16.
//

import AVFoundation

public extension AVPlayerItem {
    
    var bufferProgress: Double {
        return currentBufferDuration / totalDuration
    }
    
    var currentBufferDuration: Double {
        guard let range = loadedTimeRanges.first else { return 0 }
        return Double(CMTimeGetSeconds(CMTimeRangeGetEnd(range.timeRangeValue)))
    }
    
    var currentDuration: Double {
        return Double(CMTimeGetSeconds(currentTime()))
    }
    
    var playProgress: Double {
        return currentDuration / totalDuration
    }
    
    var totalDuration: Double {
        return Double(CMTimeGetSeconds(asset.duration))
    }
    
}

extension AVPlayerItem {
    
    var isEnoughToPlay: Bool {
        guard
            let urlAsset = (asset as? AVURLAsset),
            let url = urlAsset.url.deconstructed,
            let configuration = try? JY_Video_Cache_Manager.cachedConfiguration(for: url)
        else { return false }
        
        return configuration.downloadedByteCount >= 1024 * 768
    }
    
    convenience init(loader url: URL) {
        if url.isFileURL || url.pathExtension == "m3u8" {
            self.init(url: url)
            return
        }
        
        guard let loaderURL = url.constructed else {
            JY_Video_Loader_Manager.shared.reportError?(NSError(
                domain: "me.gesen.player.loader",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Wrong url \(url.absoluteString)，unable to initialize Loader"]
            ))
            self.init(url: url)
            return
        }
        
        let urlAsset = AVURLAsset(url: loaderURL)
        urlAsset.resourceLoader.setDelegate(JY_Video_Loader_Manager.shared, queue: .main)
        
        self.init(asset: urlAsset)
    }
    
}
