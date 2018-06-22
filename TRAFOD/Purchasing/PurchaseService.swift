//
//  PurchaseService.swift
//  TRAFOD
//
//  Created by adeiji on 6/21/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import Foundation
import StoreKit

class PurchaseService {
    
    static let shared = PurchaseService()
    
    func loadSubscriptionOptions () {
        
        let url = URL(string: "https://dephyned.com")
        if let url = url {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                
            }            
        }
        
    }
}
