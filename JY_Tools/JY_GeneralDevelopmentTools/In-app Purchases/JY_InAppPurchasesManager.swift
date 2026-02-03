//
//  JY_InAppPurchasesManager.swift
//  JY_GeneralDevelopmentTools
//
//  Created by JYYQLin on 2026/1/15.
//

//import SwiftyStoreKit
//import StoreKit
//import Alamofire
//
//// MARK: - 内购工具类（支持两种验证模式切换）
//final class JY_InAppPurchasesManager: NSObject {
//    // MARK: - 单例（线程安全）
//    static let shared: JY_InAppPurchasesManager = {
//        let instance = JY_InAppPurchasesManager()
//        
//        return instance
//    }()
//    
//    // MARK: - 环境配置（可根据业务切换，建议抽离到配置文件）
//    lazy var yq_isSandbox: Bool = false // 测试环境：true，生产环境：false
//    
//    // MARK: - 初始化（私有化）
//    private override init() {
//        super.init()
//    }
//    
//    func set(isSandbox: Bool) {
//        yq_isSandbox = isSandbox
//    }
//}
//
//// MARK: - 公开方法（业务层调用）
//extension JY_InAppPurchasesManager {
//    
//    //  支付成功后回调，通知界面验证订单
//    func yq_payItem(productID: String, userID: String = "", completion: @escaping (JY_PurchaseResult) -> Void) {
//        
//        SwiftyStoreKit.purchaseProduct(productID, quantity: 1, atomically: false, applicationUsername: "") { [weak self] purchaseResult in
//            
//            guard let self = self else { return }
//            
//            DispatchQueue.main.async {
//                switch purchaseResult {
//                case .success(let purchase):
//                    // 2. 购买成功（App Store层面），开始获取收据并服务器验证
//                    guard let receiptData = self.getReceiptData(from: purchase) else {
//                        completion(.receiptEmpty)
//                        // 兜底：收据为空时结束交易，避免交易挂起
//                        SwiftyStoreKit.finishTransaction(purchase.transaction)
//                        return
//                    }
//                    
//                    completion(.success(purchase.transaction, receiptData))
//                    
//                case .error(let error):
//                    // 购买失败（如网络错误、余额不足、商品不存在等）
//                    completion(.failure(error.localizedDescription))
//                }
//            }
//            
//        }
//    }
//}
//
//extension JY_InAppPurchasesManager {
//    /// 获取订单收据（优先从交易中取，兜底读本地文件）
//    /// - Parameter purchase: 购买结果对象
//    /// - Returns: 收据二进制数据（nil表示获取失败）
//    private func getReceiptData(from purchase: PurchaseDetails) -> Data? {
//        
//        // 方式1：从交易对象直接获取收据（优先）
//        if let receipt = SwiftyStoreKit.localReceiptData {
//            return receipt
//        }
//        
//        // 方式2：兜底读取本地收据文件（App Store自动保存的收据）
//        guard let receiptURL = Bundle.main.appStoreReceiptURL,
//              FileManager.default.fileExists(atPath: receiptURL.path) else {
//            return nil
//        }
//        
//        return try? Data(contentsOf: receiptURL)
//    }
//}
