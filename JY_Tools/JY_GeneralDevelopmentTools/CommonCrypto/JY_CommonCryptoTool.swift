//
//  JY_CommonCryptoTool.swift
//  JY_GeneralDevelopmentTools
//
//  Created by JYYQLin on 2025/12/23.
//

import CommonCrypto
import Foundation

// MARK: - String 加密/编码扩展（MD5/SHA256/Base64）
extension String {
    // MARK: 1. MD5 加密
    /// MD5加密（默认返回小写字符串）
    /// - Parameter uppercase: 是否返回大写，默认false
    /// - Returns: 加密后的字符串（失败返回空字符串）
    public func yq_md5(uppercase: Bool = false) -> String {
        guard let data = self.data(using: .utf8) else {
            print("MD5加密失败：字符串转Data失败")
            return ""
        }
        
        // 初始化MD5上下文
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        _ = data.withUnsafeBytes { bytes in
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        
        // 转换为16进制字符串
        let md5Str = digest.map { String(format: "%02hhx", $0) }.joined()
        return uppercase ? md5Str.uppercased() : md5Str
    }
    
    // MARK: 2. SHA256 加密
    /// SHA256加密（默认返回小写字符串）
    /// - Parameter uppercase: 是否返回大写，默认false
    /// - Returns: 加密后的字符串（失败返回空字符串）
    public func yq_sha256(uppercase: Bool = false) -> String {
        guard let data = self.data(using: .utf8) else {
            print("SHA256加密失败：字符串转Data失败")
            return ""
        }
        
        // 初始化SHA256上下文
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = data.withUnsafeBytes { bytes in
            CC_SHA256(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        
        // 转换为16进制字符串
        let sha256Str = digest.map { String(format: "%02hhx", $0) }.joined()
        return uppercase ? sha256Str.uppercased() : sha256Str
    }
    
    // MARK: 3. Base64 编码
    /// Base64编码（默认使用utf8编码）
    /// - Returns: 编码后的字符串（失败返回空字符串）
    public func yq_base64Encoded() -> String {
        guard let data = self.data(using: .utf8) else {
            print("Base64编码失败：字符串转Data失败")
            return self
        }
        return data.base64EncodedString()
    }
    
    // MARK: 4. Base64 解码
    /// Base64解码（默认使用utf8解码）
    /// - Returns: 解码后的字符串（失败返回nil）
    public func yq_base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else {
            print("Base64解码失败：无效的Base64字符串")
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
