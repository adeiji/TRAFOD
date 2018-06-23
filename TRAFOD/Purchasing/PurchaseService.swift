//
//  PurchaseService.swift
//  TRAFOD
//
//  Created by adeiji on 6/21/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import Foundation
import StoreKit

class PurchaseService: NSObject, SKProductsRequestDelegate {
    
    static let shared = PurchaseService()
    var title:String?
    var messages:[String]?
    var buttonText:String?
    var products:[SKProduct]?
    var websitePitch:String?
    var hasReceiptData:Bool = false
    var isSubscriptionExpired = true
    
    func loadSubscriptionOptions () {
        let url = URL(string: "https://dephyned.com/salesPitch")
        if let url = url {
            let task = URLSession.shared.dataTask(with: url) { (promotionInfo, response, error) in
                if let promotionInfo = promotionInfo {
                    let json = try? JSONSerialization.jsonObject(with: promotionInfo, options: [])
                    if let promotionInfo = json as? [String:Any] {
                        self.title = promotionInfo["title"] as? String
                        self.buttonText = promotionInfo["buttonText"] as? String
                        self.messages = promotionInfo["messages"] as? [String]
                        self.websitePitch = promotionInfo["website"] as? String
                        if let ids = promotionInfo["productIds"] as? [String] {
                            let idsSet = Set(ids)
                            let request = SKProductsRequest(productIdentifiers: idsSet)
                            request.delegate = self
                            request.start()
                        }
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func restorePurchases () {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKProductsRequest {
            print("Subscription Options failed loading: \(error.localizedDescription)")
        }
    }
    
    func purchase (product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func uploadReceipt (completion: ((Bool?) -> Void)? = nil) {
        if let receiptUrl = Bundle.main.appStoreReceiptURL {
            let receipt = try? Data(contentsOf: receiptUrl)
            if receipt == nil {
                // Error
                return
            }
            
            let receiptDictionary = ["receipt-data": receipt?.base64EncodedString(options: []), "password": "c4c05a361d8d4136a741fd52a47c9e4b"]
            let requestData = try? JSONSerialization.data(withJSONObject: receiptDictionary, options: .prettyPrinted)
            if let url = URL(string: "https://buy.itunes.apple.com/verifyReceipt") {
                var request = URLRequest(url: url)
                request.setValue("application/application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                request.httpBody = requestData
                
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard let data = data, error == nil else {
                        if let completion = completion {
                            completion(false)
                        }
                        
                        return
                    }
                    
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                        self.hasReceiptData = true
                        if let expirationDate = self.expirationDateFromResponse(jsonResponse: jsonResponse) {
                            self.updateIAPExpirationDate(expirationDate: expirationDate)
                        }
                        
                        if let completion = completion {
                            completion(true)
                        }
                    }
                }
                
                task.resume()
            }
        }
    }
    
    func updateIAPExpirationDate (expirationDate: Date) {
        let expDateKey = "expDate"
        let userDefaults = UserDefaults.standard
        if let previousExpDate = userDefaults.object(forKey: expDateKey) as? Date {
            
            if expirationDate.timeIntervalSince(Date()) > 0 {
                self.isSubscriptionExpired = false
            }
            
            // The subscription has been renewed
            if previousExpDate.timeIntervalSince(expirationDate) < 0 {
                userDefaults.set(expirationDate, forKey: expDateKey)
            }
            
            if previousExpDate.timeIntervalSince(expirationDate) > 0 {
                // Subscription has expired, most likely cancelled
            }
        } else {
            userDefaults.set(expirationDate, forKey: expDateKey)
            userDefaults.synchronize()
        }
    }
    
    func expirationDateFromResponse(jsonResponse: NSDictionary?) -> Date? {
        if let jsonResponse = jsonResponse {
            if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
                let lastReceipt = receiptInfo.lastObject as! NSDictionary
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
                let expirationDate = formatter.date(from: lastReceipt["expires_date"] as! String) as Date?
                return expirationDate
            } else {
                return nil
            }
        } else {
            return nil
        }
        
    }
}
