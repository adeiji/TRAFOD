//
//  AntiGravPlatformHeavy.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class AntiGravPlatformHeavy : MultiDirectionalGravObject {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.verticalForce = 8000
    }

    override func applyUpwardForce() {
        super.applyUpwardForce()
    }
}
