# YMTInAppPurchaseFramework
This framework makes it easy to run the in-app purchase process.

## Description
Processing while purchasing an application takes time and effort such as receipt verification.
With this framework, we can easily handle such in-app purchase item processing.


## Installation 
Just add YMTVersionAlert.framework foloder to your project  
or use CocoaPods with Podfile:

```
pod 'YMTInAppPurchase'
```

Run 
```
pod install
```

## Usage
### Launch verification server
[iap-node-api](https://github.com/MasamiYamate/iap-node-api)

This framework is made on the premise to use in conjunction with iap-node-api.
It is necessary to launch iap-node-api so that it can be accessed from the outside.

### Import
 
```ViewController.swift
import YMTInAppPurchase
```

### Step1:Required key setting
In the AppDelegate.swift's didFinishLaunchingWithOptions, set the receipt verification URL and in-app purchase shared secret key.

```AppDelegate.swift
//
//  AppDelegate.swift
//  YMTInAppPurchaseSampleApp
//

import UIKit

// Framework import
import YMTInAppPurchase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Set In-App Purchase Shared Secret Key
        YMTInAppPurchase.shared.setAppShareKey("In-App Purchase Shared Secret Key")
        
        // Set registration setting and restoration confirmation API end point
        let registration = "registration url"
        let restore = "restore url"
        YMTInAppPurchase.shared.setValidationUrls(regist: registration, restore: restore)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}

}
```

### Step2:Confirm the items sold in the iTunes Store
Pass the ID of the item sold in the application to determine if it is a valid product.
Please execute before the item sales page is displayed.

```ViewController.swift
let productIds = ["productId" , "productId"]
YMTInAppPurchase.shared.setProductIdss(productIds, callback: {
	// Such view refresh event etc.
}
```

### Step3:Perform a transaction
It gets the SKProduct of the item specified by the user and passes it to the following method.
If it is executed and succeeded after the purchase process has ended, the ID of the item sold will be returned as String.

```ViewController.swift
YMTInAppPurchase.shared.startTransaction(product, callback: { productId in
    //ProductId is returned.
    //Perform function release etc. based on product ID.
    if productId != nil {
        //Perform function release etc.
    }
})
```

### Restore request
If the user has replaced the new iPhone and reinstalled the application, it is necessary to restore the purchased item.
It can be easily restored.
Simply execute the following method to get the ID of the item you want to restore.

```ViewController.swift
YMTInAppPurchase.shared.startRestore(callback: { restoreProductIds in
    //The product ID to be restored is returned.
    //Perform processing such as cancellation of functions based on the product ID
})
```

## Licence

[MIT](https://github.com/MasamiYamate/YMTVersionAlert/blob/master/LICENSE)

