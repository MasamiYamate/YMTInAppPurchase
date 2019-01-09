//
//  HttpRequestManager.swift
//  YMTInAppPurchase
//
//  Created by MasamiYamate on 2019/01/04.
//  Copyright © 2019 MasamiYamate. All rights reserved.
//

import UIKit
import SystemConfiguration

class YMTHttpRequest: NSObject {
    
    static let share: YMTHttpRequest = YMTHttpRequest()
    
    override init() {
        super.init()
    }
    
    func syncGet (_ reqPath: String) -> Data? {
        if !isNetworkActive(reqPath) {
            return nil
        }
        guard let requestUrl: URL = URL(string: reqPath) else {
            return nil
        }
        var result: Data?
        let semaphore = DispatchSemaphore.init(value: 0)
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60.0
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: requestUrl) { (data: Data?, res: URLResponse?, err: Error?) in
            result = data
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return result
    }
    
    func asyncGet (_ reqPath: String , callback: ((Data? , URLResponse? , Error?) -> Void)?) {
        if !isNetworkActive(reqPath) {
            callback?(nil , nil , nil)
            return
        }
        guard let requestUrl: URL = URL(string: reqPath) else {
            callback?(nil , nil , nil)
            return
        }
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60.0
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: requestUrl) { (data: Data?, res: URLResponse?, err: Error?) in
            callback?(data , res , err)
        }
        task.resume()
    }
    
    func syncPost (_ reqPath: String , reqParm: [String:Any]) -> Data? {
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: reqParm, options: [])
        return syncPost(reqPath, reqJsonParm: jsonData)
    }
    
    func syncPost (_ reqPath: String , reqJsonParm: Data?) -> Data? {
        if !isNetworkActive(reqPath) {
            return nil
        }
        guard let requestUrl: URL = URL(string: reqPath) else {
            return nil
        }
        var result: Data?
        let semaphore = DispatchSemaphore.init(value: 0)
        var urlRequest: URLRequest = URLRequest(url: requestUrl, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 1000.0)
        let session: URLSession = URLSession.shared
        
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = reqJsonParm
        
        let task = session.dataTask(with: urlRequest) { (data: Data?, res: URLResponse?, err: Error?) in
            if err != nil {
                semaphore.signal()
            }
            if data != nil {
                result = data
                semaphore.signal()
            }
        }
        task.resume()
        semaphore.wait()
        return result
    }
    
    func asyncPost (_ reqPath: String , reqParm: [String:Any] , callback: ((Data? , URLResponse? , Error?) -> Void)?){
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: reqParm, options: .prettyPrinted)
        asyncPost(reqPath, reqJsonParm: jsonData, callback: {(data: Data?, res: URLResponse?, err: Error?) in
            callback?(data , res , err)
        })
    }
    
    func asyncPost (_ reqPath: String , reqJsonParm: Data? , callback: ((Data? , URLResponse? , Error?) -> Void)?) {
        if !isNetworkActive(reqPath) {
            callback?(nil , nil , nil)
        }
        guard let requestUrl: URL = URL(string: reqPath) else {
            callback?(nil , nil , nil)
            return
        }
        var urlRequest: URLRequest = URLRequest(url: requestUrl, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        let session: URLSession = URLSession.shared
        
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = reqJsonParm
        
        let task = session.dataTask(with: urlRequest) { (data: Data?, res: URLResponse?, err: Error?) in
            callback?(data , res , err)
        }
        task.resume()
    }
    
    func isNetworkActive (_ requestPath: String) -> Bool {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, requestPath) else {
            return false
        }
        var flags = SCNetworkReachabilityFlags.connectionAutomatic
        if !SCNetworkReachabilityGetFlags(reachability, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
}
