//
//  PurchaseViewController.swift
//  TRAFOD
//
//  Created by adeiji on 6/22/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import UIKit

class PurchaseViewController: UIViewController {

    @IBOutlet weak var myTitle: UILabel!
    @IBOutlet weak var section1: UILabel!
    @IBOutlet weak var section2: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var websitePitch: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.button.layer.cornerRadius = 5.0
        if let title = PurchaseService.shared.title {
            self.myTitle.text = title
        }
        
        if let messages = PurchaseService.shared.messages {
            if let message1 = messages.first {
                self.section1.text = message1
            }
            if messages.count > 1 {
                let message2 = messages[1]
                self.section2.text = message2
            }
        }
        
        if let websitePitch = PurchaseService.shared.websitePitch {
            self.websitePitch.text = websitePitch
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(userSubscribed), name: .UserSubscribed, object: nil)
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
    
    @IBAction func subscribePressed(_ sender: Any) {
        guard let product = PurchaseService.shared.products?.first else {
            return
        }
        
        PurchaseService.shared.purchase(product: product)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
