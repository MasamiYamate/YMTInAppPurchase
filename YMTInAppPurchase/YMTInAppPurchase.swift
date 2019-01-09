//
//  YMTInAppPurchase.swift
//  YMTInAppPurchase
//
//  Created by MasamiYamate on 2019/01/04.
//  Copyright © 2019 MasamiYamate. All rights reserved.
//

import UIKit
import StoreKit

@objcMembers open class YMTInAppPurchase: NSObject {

    public static let shared: YMTInAppPurchase = YMTInAppPurchase()
    
    public override init() {
        super.init()
    }
    
    /// Set AppStore share key string
    ///
    /// - Parameter key: String
    open func setAppShareKey (_ key: String) {
        YMTPayment.shared.setAppShareKey(key)
    }
    
    /// Set validation server url
    ///
    /// - Parameters:
    ///   - regi: Registration validation Url
    ///   - restore: Restore validation url
    open func setValidationUrls (regist: String , restore: String) {
        YMTPayment.shared.setValidationUrl(regi: regist, restore: restore)
    }
    
    /// Set of sale item ids
    ///
    /// - Parameter ids: [String:String]
    ///   - callback: () -> Void?
    open func setProductIdss (_ ids: [String] , callback: (() -> Void)?) {
        YMTPayment.shared.setProductIds(ids, callback: {
            callback?()
        })
    }
    
    /// Get sale item total count
    ///
    /// - Returns: Int
    open func getProductsCnt () -> Int {
        return YMTPayment.shared.getProductsCnt()
    }
    
    /// Get sale items
    ///
    /// - Returns: SKProduct?
    open func getProduct (_ idx: Int) -> SKProduct? {
        return YMTPayment.shared.getProduct(_: idx)
    }
    
    /// Get sale items
    ///
    /// - Returns: [SKProduct]
    open func getProducts () -> [SKProduct] {
        return YMTPayment.shared.getProducts()
    }
    
    /// Get product localized title
    ///
    /// - Parameter product: SKProduct
    /// - Returns: String
    open func getProductLocalizedTitle (_ product: SKProduct) -> String {
        return YMTPayment.shared.getProductLocalizedTitle(_: product)
    }
    
    /// Get product localized body
    ///
    /// - Parameter product: SKProduct
    /// - Returns: String
    open func getProductLocalizedBody (_ product: SKProduct) -> String {
        return YMTPayment.shared.getProductLocalizedBody(_: product)
    }
    
    /// Get product localized price
    ///
    /// - Parameter product: SKProduct
    /// - Returns: String
    open func getProductLocalizedPrice (_ product: SKProduct) -> String {
        return YMTPayment.shared.getProductLocalizedPrice(_: product)
    }
    
    /// Fetch receipt
    ///
    /// - Parameter callback: (() -> Void)?
    open func fetchReceipt (callback: (() -> Void)?) {
        YMTPayment.shared.fetchReceipt(callback: {
            callback?()
        })
    }
    
    open func startTransaction (_ product: SKProduct , callback: ((String?) -> Void)?) {
        YMTPayment.shared.startTransaction(product, callback: { productId in
            callback?(productId)
        })
    }
    
    open func startRestore (callback: (([String]) -> Void)?) {
        YMTPayment.shared.startRestore(callback: { restoreIds in
            callback?(restoreIds)
        })
    }
    
}
