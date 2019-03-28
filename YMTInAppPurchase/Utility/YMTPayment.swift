//
//  YMTPayment.swift
//  YMTInAppPurchase
//
//  Created by MasamiYamate on 2019/01/04.
//  Copyright © 2019 MasamiYamate. All rights reserved.
//

import UIKit
import StoreKit

class YMTPayment: NSObject , SKProductsRequestDelegate , SKPaymentTransactionObserver {
    
    let PRODUCT_REQUEST     = Notification.Name.init("PRODUCT_REQUEST")
    let FETCH_REQUEST       = Notification.Name.init("FETCH_REQUEST")
    let TRANSACTION_REQUEST = Notification.Name.init("TRANSACTION_REQUEST")
    let RESTORE_REQUEST     = Notification.Name.init("RESTORE_REQUEST")
    
    static let shared: YMTPayment = YMTPayment()
    
    //Available items
    private var effectiveProducts: [SKProduct]  = []
    //Invalid item ids
    private var invalidProductIds: [String]     = []
    //Latest transaction ids
    private var latestTransactionIds: [String]  = []
    
    //Application shared key
    private var appShareKey: String?
    
    //Validation server url
    private var restoreUrl      : String?
    private var registrationUrl : String?
    
    override init() {
        super.init()
    }
    
    //MARK: - Initialize methods
    /// Set AppStore share key string
    ///
    /// - Parameter key: String
    func setAppShareKey (_ key: String) {
        appShareKey = key
    }
    
    /// Set validation url
    ///
    /// - Parameters:
    ///   - regi: Registration validation Url
    ///   - restore: Restore validation url
    func setValidationUrl (regi: String , restore: String) {
        restoreUrl = restore
        registrationUrl = regi
    }
    
    /// Set of sale item ids
    ///
    /// - Parameter ids: [String:String]
    ///   - callback: () -> Void?
    func setProductIds (_ ids: [String] , callback: (() -> Void)?) {
        let productReq = SKProductsRequest(productIdentifiers: Set(ids))
        productReq.delegate = self
        productReq.start()
        NotificationCenter.default.addObserver(forName: PRODUCT_REQUEST, object: nil, queue: nil, using: {_ in
            NotificationCenter.default.removeObserver(self)
            callback?()
        })
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        effectiveProducts = response.products
        invalidProductIds = response.invalidProductIdentifiers
        NotificationCenter.default.post(name: PRODUCT_REQUEST, object: nil)
    }
    
    /// Get sale item total count
    ///
    /// - Returns: Int
    func getProductsCnt () -> Int {
        return effectiveProducts.count
    }
    
    /// Get product
    ///
    /// - Returns: SKProduct?
    func getProduct (_ idx: Int) -> SKProduct? {
        if idx < effectiveProducts.count {
            return effectiveProducts[idx]
        }else{
            return nil
        }
    }
    
    /// Get products
    ///
    /// - Returns: [SKProduct]
    func getProducts () -> [SKProduct] {
        return effectiveProducts
    }
    
    /// Get product localized title
    ///
    /// - Parameter product: SKProduct
    /// - Returns: String
    func getProductLocalizedTitle (_ product: SKProduct) -> String {
        return product.localizedTitle
    }
    
    /// Get product localized body
    ///
    /// - Parameter product: SKProduct
    /// - Returns: String
    func getProductLocalizedBody (_ product: SKProduct) -> String {
        return product.localizedDescription
    }
    
    /// Get product localized price
    ///
    /// - Parameter product: SKProduct
    /// - Returns: String
    func getProductLocalizedPrice (_ product: SKProduct) -> String {
        return product.price.stringValue
    }

    /// Get product id
    ///
    /// - Parameter product: SKProduct
    /// - Returns: String
    func getProductId (_ product: SKProduct) -> String {
        return product.productIdentifier
    }
    
    //MARK: Receipt process methods
    func fetchReceipt (callback: (() -> Void)?) {
        let request = SKReceiptRefreshRequest()
        request.delegate = self
        request.start()
        NotificationCenter.default.addObserver(forName: FETCH_REQUEST, object: nil, queue: nil, using: {_ in
            NotificationCenter.default.removeObserver(self)
            callback?()
        })
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("Receipt refresh finish")
        NotificationCenter.default.post(name: FETCH_REQUEST, object: nil)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Receipt refresh error")
        NotificationCenter.default.post(name: FETCH_REQUEST, object: nil)
    }
    
    private func getLocalReceipt () -> String? {
        guard let receiptFilePath: URL = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        guard let data: Data = try? Data(contentsOf: receiptFilePath) else {
            return nil
        }
        let base64Receipt: String = data.base64EncodedString(options: [])
        return base64Receipt
    }
    
    //MARK: - Transaction process methods
    
    
    func startTransaction (_ product: SKProduct , callback: ((String?) -> Void)?) {
        endUnfinishedTransaction()
        SKPaymentQueue.default().add(self)
        let payment: SKPayment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        NotificationCenter.default.addObserver(forName: TRANSACTION_REQUEST, object: nil, queue: nil, using: { noti in
            var isErr: Bool = true
            NotificationCenter.default.removeObserver(self)
            if let transaction: SKPaymentTransaction = noti.object as? SKPaymentTransaction {
                var transactionId = transaction.original?.transactionIdentifier
                if transactionId == nil {
                    transactionId = transaction.transactionIdentifier
                }
                if let reqTransactionId: String = transactionId {
                    let code = self.confirmRegistrationIntegrity(reqTransactionId)
                    if code == 0 {
                        let productId: String = transaction.payment.productIdentifier
                        isErr = false
                        callback?(productId)
                    }
                }
            }
            if isErr {
                callback?(nil)
            }
        })
    }
    
    func startRestore (callback: (([String]) -> Void)?) {
        endUnfinishedTransaction()
        latestTransactionIds = []
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
        NotificationCenter.default.addObserver(forName: RESTORE_REQUEST, object: nil, queue: nil, using: {_ in
            NotificationCenter.default.removeObserver(self)
            var restoreProductIds: [String] = []
            for tmpId in self.latestTransactionIds {
                let productId: String = self.confirmRestorationIntegrity(tmpId)
                if productId != "error" {
                    restoreProductIds.append(productId)
                }
            }
            callback?(restoreProductIds)
        })
    }
    
    func endUnfinishedTransaction () {
        if SKPaymentQueue.default().transactions.count > 0 {
            for transaction in SKPaymentQueue.default().transactions {
                //Except everything during purchase, end all
                if transaction.transactionState != SKPaymentTransactionState.purchasing {
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                //Purchase complete
                queue.finishTransaction(transaction)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: self.TRANSACTION_REQUEST, object: transaction as Any)
                }
            case .failed:
                //Purchase failed
                queue.finishTransaction(transaction)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: self.TRANSACTION_REQUEST, object: nil)
                }
            case .restored:
                //Restore complete
                setLatestTransactionId(transaction)
                queue.finishTransaction(transaction)
            case .deferred:
                //Delay
                queue.finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print("Purchase all task complete")
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("Restore all task complete")
        NotificationCenter.default.post(name: RESTORE_REQUEST, object: nil)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("Restore error")
        print(error)
        NotificationCenter.default.post(name: RESTORE_REQUEST, object: nil)
    }
    
    func setLatestTransactionId (_ transaction: SKPaymentTransaction) {
        if transaction.transactionState == SKPaymentTransactionState.restored {
            if let orgTransactionId: String = transaction.original?.transactionIdentifier {
                latestTransactionIds.append(orgTransactionId)
            }
        }
    }
    
    func confirmRestorationIntegrity (_ transactionId: String) -> String {
        let errCode: String = "error"
        guard let base64Receipt: String = getLocalReceipt() else {
            return errCode
        }
        guard let useSecretKey: String = appShareKey else {
            return errCode
        }
        let requestParm: [String:Any] = [
            "base64Receipt": base64Receipt,
            "transactionID": transactionId,
            "secretKey": useSecretKey
        ]
        guard let requestUrl: String = restoreUrl else {
            return errCode
        }
        if !YMTHttpRequest.share.isNetworkActive(requestUrl) {
            return errCode
        }
        guard let resultData: Data = YMTHttpRequest.share.syncPost(requestUrl, reqParm: requestParm) else {
            return errCode
        }
        guard let anyObj = try? JSONSerialization.jsonObject(with: resultData, options: []) else {
            return errCode
        }
        guard let jsonDic: [String:Any] = anyObj as? [String:Any] else {
            return errCode
        }
        guard let productId: String = jsonDic["id"] as? String else {
            return errCode
        }
        return productId
    }
    
    func confirmRegistrationIntegrity (_ transactionId: String) -> Int {
        let errCode: Int = -1
        guard let base64Receipt: String = getLocalReceipt() else {
            return errCode
        }
        guard let useSecretKey: String = appShareKey else {
            return errCode
        }
        let requestParm: [String:Any] = [
            "base64Receipt": base64Receipt,
            "transactionID": transactionId,
            "secretKey": useSecretKey
        ]
        guard let requestUrl: String = registrationUrl else {
            return errCode
        }
        if !YMTHttpRequest.share.isNetworkActive(requestUrl) {
            return errCode
        }
        guard let resultData: Data = YMTHttpRequest.share.syncPost(requestUrl, reqParm: requestParm) else {
            return errCode
        }
        guard let anyObj = try? JSONSerialization.jsonObject(with: resultData, options: []) else {
            return errCode
        }
        guard let jsonDic: [String:Any] = anyObj as? [String:Any] else {
            return errCode
        }
        guard let statusCode: Int = jsonDic["status"] as? Int else {
            return errCode
        }
        return statusCode
    }
    
}
