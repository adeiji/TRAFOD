//
//  WeightSwitch.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/5/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class WeightSwitch : MultiDirectionalGravObject {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.contactTestBitMask = 1 | UInt32(PhysicsCategory.InteractableObjects) | UInt32(PhysicsCategory.NonInteractableObjects) | UInt32(PhysicsCategory.Minerals)
//        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.InteractableObjects)
    }
    
    var collisionImpulseRequired = 10
}
