//
//  ConfirmationViewController.swift
//  TRAFOD
//
//  Created by adeiji on 6/22/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func websiteButtonClicked(_ sender: Any) {
        if let url = URL(string: "http://www.trafodgame.net") {
            UIApplication.shared.open(url, options: [:])
        }
    }
}
