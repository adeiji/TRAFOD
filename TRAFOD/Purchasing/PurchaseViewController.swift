//
//  PurchaseViewController.swift
//  TRAFOD
//
//  Created by adeiji on 6/22/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import UIKit

class PurchaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(userSubscribed), name: .UserSubscribed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userSubscribed), name: .SubscriptionRestored, object: nil)
    }
    
    @IBAction func restorePurchases(_ sender: Any) {
    }
    
    @objc func userSubscribed () {
        if let subscribedVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userSubscribed") as? ConfirmationViewController {
            self.navigationController?.pushViewController(subscribedVC, animated: true)
        }
    }
    
    @IBAction func websiteButtonClicked(_ sender: Any) {
        if let url = URL(string: "http://www.trafodgame.net") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
