//
//  ViewController.swift
//  YMTInAppPurchaseSampleApp
//
//  Created by MasamiYamate on 2019/01/08.
//  Copyright © 2019 MasamiYamate. All rights reserved.
//

import UIKit
import YMTInAppPurchase
import StoreKit

class ViewController: UIViewController {
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingCircle: UIActivityIndicatorView!
    
    @IBOutlet weak var itemTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemTableView.delegate = self
        itemTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Loading view methods
    /// Open loading view
    ///
    /// - Parameter callback: (() -> Void)?
    func openLoadingView (callback: (() -> Void)?) {
        loadingView.alpha = 0.0
        loadingView.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.loadingView.alpha = 1.0
        }, completion: {_ in
            callback?()
        })
    }
    
    /// Close loading view
    ///
    /// - Parameter callback: (() -> Void)?
    func closeLoadingview (callback: (() -> Void)?) {
        UIView.animate(withDuration: 0.5, animations: {
            self.loadingView.alpha = 0.0
        }, completion: { _ in
            self.loadingView.isHidden = true
            callback?()
        })
    }
    
    // MARK: - Payment processing methods
    /// Get the product object of SKProduct from product ID
    func loadProducts () {
        // Only when the number of acquired products is 0, we will load the product.
        // Items that have been loaded are valid until the application ends.
        if YMTInAppPurchase.shared.getProductsCnt() == 0 {
            // In App store connect, enter the set product ID.
            // In Json, it is recommended to manage multiple product IDs and read the array of IDs.
            let productIds = ["productId" , "productId"]
            openLoadingView(callback: {
                YMTInAppPurchase.shared.setProductIdss(productIds, callback: {
                    self.itemTableView.reloadData()
                    self.closeLoadingview(callback: nil)
                })
            })
        }else{
            DispatchQueue.main.async {
                self.itemTableView.reloadData()
            }
        }
    }
    
    /// Start restore
    func startRestore () {
        openLoadingView(callback: {
            YMTInAppPurchase.shared.startRestore(callback: { restoreProductIds in
                //The product ID to be restored is returned.
                //Perform processing such as cancellation of functions based on the product ID
                self.closeLoadingview(callback: nil)
            })
        })
    }
    
    /// Start transaction
    func startTransaction (product: SKProduct) {
        openLoadingView(callback: {
            YMTInAppPurchase.shared.startTransaction(product, callback: { productId in
                //ProductId is returned.
                //Perform function release etc. based on product ID.
                if productId != nil {
                    //Perform function release etc.
                }
                self.closeLoadingview(callback: nil)
            })
        })
    }
    
    
}

extension ViewController: UITableViewDelegate , UITableViewDataSource {
    // MARK: - UITableview delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // To generate a restore cell, add 1
        return YMTInAppPurchase.shared.getProductsCnt() + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case YMTInAppPurchase.shared.getProductsCnt():
            // Generate a restore cell
            let restoreCell = UITableViewCell(style: .default, reuseIdentifier: nil)
            restoreCell.accessoryType = .disclosureIndicator
            restoreCell.textLabel?.text = "restore"
            return restoreCell
        default:
            // Generate product cell
            let productCell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            if let product: SKProduct = YMTInAppPurchase.shared.getProduct(indexPath.row) {
                let title   : String = YMTInAppPurchase.shared.getProductLocalizedTitle(product)
                //let body    : String = YMTInAppPurchase.shared.getProductLocalizedBody(product)
                let price   : String = YMTInAppPurchase.shared.getProductLocalizedPrice(product)
                productCell.textLabel?.text = title
                productCell.detailTextLabel?.text = price
                productCell.accessoryType = .disclosureIndicator
            }
            return productCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case YMTInAppPurchase.shared.getProductsCnt():
            startRestore()
        default:
            guard let product: SKProduct = YMTInAppPurchase.shared.getProduct(indexPath.row) else {
                return
            }
            startTransaction(product: product)
        }
    }
    
}
