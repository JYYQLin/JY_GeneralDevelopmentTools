//
//  JY_Video_Cache_Handler.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/9/16.
//

import Foundation

private let packageLength = 1024 * 512

public class JY_Video_Cache_Handler {
    
    private(set) var configuration: JY_Video_Cache_Configuration
    
    private let readFileHandle: FileHandle
    private let writeFileHandle: FileHandle
    
    public init(url: URL) throws {
        let fileManager = FileManager.default
        let filePath = JY_Video_Cache_Manager.cachedFilePath(for: url)
        let fileURL = URL(fileURLWithPath: filePath)
        let fileDirectory = filePath.deletingLastPathComponent
        
        if !fileManager.fileExists(atPath: fileDirectory) {
            try fileManager.createDirectory(
                atPath: fileDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        
        if !fileManager.fileExists(atPath: filePath) {
            fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
        
        configuration = try JY_Video_Cache_Configuration.configuration(for: filePath)
        readFileHandle = try FileHandle(forReadingFrom: fileURL)
        writeFileHandle = try FileHandle(forWritingTo: fileURL)
    }
    
    deinit {
        readFileHandle.closeFile()
        writeFileHandle.closeFile()
    }
    
    func actions(for range: NSRange) -> [JY_Video_Cache_Action] {
        guard range.location != NSNotFound else { return [] }
        
        var localActions = [JY_Video_Cache_Action]()
        
        for fragment in configuration.fragments {
            let intersection = NSIntersectionRange(range, fragment)

            guard intersection.length > 0 else {
                if fragment.location >= range.upperBound {
                    break
                } else {
                    continue
                }
            }

            let package = intersection.length.double / packageLength.double
            let max = intersection.location + intersection.length

            for i in 0 ..< package.rounded(.up).int {
                let offset = intersection.location + i * packageLength
                let length = (offset + packageLength) > max ? max - offset : packageLength

                localActions.append(JY_Video_Cache_Action(
                    actionType: .local,
                    range: NSRange(location: offset, length: length)
                ))
            }
        }
        
        guard localActions.isEmpty == false else {
            return [JY_Video_Cache_Action(actionType: .remote, range: range)]
        }
        
        if let info = configuration.info {
            if range.location >= info.contentLength {
                return []
            }
        }
        
        var localRemoteActions = [JY_Video_Cache_Action]()
        
        for (i, action) in localActions.enumerated() {
            if i == 0 {
                if range.location < action.range.location {
                    localRemoteActions.append(JY_Video_Cache_Action(
                        actionType: .remote,
                        range: NSRange(
                            location: range.location,
                            length: action.range.location - range.location
                        )
                    ))
                }
                localRemoteActions.append(action)
            } else if let lastOffset = localRemoteActions.last?.range.upperBound {
                if lastOffset < action.range.location {
                    localRemoteActions.append(JY_Video_Cache_Action(
                        actionType: .remote,
                        range: NSRange(
                            location: lastOffset,
                            length: action.range.location - lastOffset
                        )
                    ))
                }
                localRemoteActions.append(action)
            }
            
            if i == localActions.count - 1, action.range.upperBound < range.upperBound {
                localRemoteActions.append(JY_Video_Cache_Action(
                    actionType: .remote,
                    range: NSRange(
                        location: action.range.upperBound,
                        length: range.upperBound - action.range.upperBound
                    )
                ))
            }
        }
        
        return localRemoteActions
    }
    
    func cache(data: Data, for range: NSRange) -> Bool {
        objc_sync_enter(writeFileHandle)
        defer {
            objc_sync_exit(writeFileHandle)
        }
        guard let availableSpace = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).resourceValues(forKeys: [.volumeAvailableCapacityKey]).volumeAvailableCapacity,
              availableSpace > Int64(data.count) else {
            return false
        }
        if #available(iOS 13.4, *), #available(macOS 10.15.4, *) {
            do
            {
                try writeFileHandle.seekToEnd()
            }
            catch
            {
                objc_sync_exit(writeFileHandle)
                return false
            }
        } else {
            // Fallback on earlier versions
        }
        writeFileHandle.seek(toFileOffset: UInt64(range.location))
        writeFileHandle.write(data)
        configuration.add(fragment: range)
        return true
    }
    
    func cachedData(for range: NSRange) -> Data {
        objc_sync_enter(readFileHandle)
        readFileHandle.seek(toFileOffset: UInt64(range.location))
        let data = self.readFileHandle.readData(ofLength: range.length)
        objc_sync_exit(readFileHandle)
        return data
    }
    
    func set(info: JY_Video_Info) {
        objc_sync_enter(writeFileHandle)
        configuration.info = info
        writeFileHandle.truncateFile(atOffset: UInt64(info.contentLength))
        writeFileHandle.synchronizeFile()
        objc_sync_exit(writeFileHandle)
    }
    
    func save() {
        objc_sync_enter(writeFileHandle)
        writeFileHandle.synchronizeFile()
        configuration.save()
        objc_sync_exit(writeFileHandle)
    }
    
}
