//
//  JY_JSONUtils.swift
//  JY_GeneralDevelopmentTools
//
//  Created by JYYQLin on 2025/12/24.
//

import Foundation

/// JSON处理工具类（iOS开发通用）
final class JY_JSONUtils {
    
    // MARK: - 私有化构造器，禁止实例化
    private init() {}
    
}

// MARK: - 类型转JSON字符串
extension JY_JSONUtils {
    /// 【单独方法】将[String: Any]转为JSON字符串（满足需求1）
    /// - Parameter dict: 字典对象（需符合JSON序列化规则）
    /// - Parameter prettyPrinted: 是否格式化输出（默认false，紧凑格式）
    /// - Returns: 可选JSON字符串（失败返回nil）
    static func convertDictionaryToString(_ dict: [String: Any], prettyPrinted: Bool = false) -> String? {
        return convertAnyToString(dict, prettyPrinted: prettyPrinted)
    }
    
    /// 【合并方法】将Any类型（Any/[String:Any]/String/[[String:Any]]）转为JSON字符串（合并需求2/3/4）
    /// - Parameter value: 任意可序列化对象（数组/字典/字符串等）
    /// - Parameter prettyPrinted: 是否格式化输出（默认false）
    /// - Returns: 可选JSON字符串（失败返回nil）
    static func convertAnyToString(_ value: Any, prettyPrinted: Bool = false) -> String? {
        // 1. 处理String类型直接返回（需求4）
        if let str = value as? String {
            return str
        }
        
        // 2. 处理可序列化对象（数组/字典等，需求2/3）
        do {
            let options: JSONSerialization.WritingOptions = prettyPrinted ? .prettyPrinted : []
            let jsonData = try JSONSerialization.data(withJSONObject: value, options: options)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("JY_JSONUtils: 数据转字符串失败（编码错误）")
                return nil
            }
            return jsonString
        } catch {
            print("JY_JSONUtils: 序列化失败 - \(error.localizedDescription)")
            return nil
        }
    }
    
}

// MARK: - JSON字符串转对象
extension JY_JSONUtils {
    /// 将JSON字符串转成[String: Any]字典（需求6）
    /// - Parameter jsonString: JSON格式字符串
    /// - Returns: 可选字典对象（失败返回nil）
    static func convertToDictionary(_ jsonString: String) -> [String: Any]? {
        guard let anyObject = convertToAny(jsonString),
              let dict = anyObject as? [String: Any] else {
            print("JY_JSONUtils: JSON字符串无法转为字典")
            return nil
        }
        return dict
    }
    
    /// 将JSON字符串转成Any类型（需求7）
    /// - Parameter jsonString: JSON格式字符串
    /// - Returns: 可选Any对象（失败返回nil）
    static func convertToAny(_ jsonString: String) -> Any? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("JY_JSONUtils: 字符串转数据失败（编码错误）")
            return nil
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
            return jsonObject
        } catch {
            print("JY_JSONUtils: 反序列化失败 - \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - 扩展：iOS开发常用JSON辅助方法
extension JY_JSONUtils {
    
    /// JSON字符串转指定模型（Codable）- iOS开发高频场景
    /// - Parameters:
    ///   - jsonString: JSON格式字符串
    ///   - type: 模型类型（需遵守Codable协议）
    /// - Returns: 可选模型对象
    static func convertToModel<T: Codable>(_ jsonString: String, type: T.Type) -> T? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        do {
            let model = try JSONDecoder().decode(type, from: jsonData)
            return model
        } catch {
            print("JY_JSONUtils: 模型解析失败 - \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 模型转JSON字符串（Codable）- iOS开发高频场景
    /// - Parameter model: 遵守Codable的模型对象
    /// - Returns: 可选JSON字符串
    static func convertModelToString<T: Codable>(_ model: T) -> String? {
        do {
            let jsonData = try JSONEncoder().encode(model)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("JY_JSONUtils: 模型序列化失败 - \(error.localizedDescription)")
            return nil
        }
    }
}

extension JY_JSONUtils {
    /// 格式化JSON字符串（便于调试）
    /// - Parameter jsonString: 原始JSON字符串
    /// - Returns: 格式化后的字符串（失败返回原字符串）
    static func prettyFormat(jsonString: String) -> String {
        guard let anyObject = convertToAny(jsonString) else {
            return jsonString
        }
        return convertAnyToString(anyObject, prettyPrinted: true) ?? jsonString
    }
}
