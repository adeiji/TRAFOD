//
//  RockNoFipGravity.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/22/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class RockNoFlipGravity : Rock, ObjectWithManuallyGeneratedPhysicsBody {
    
    override func setupPhysicsBody() {
        super.setupPhysicsBody()
        
        self.physicsBody?.contactTestBitMask = 1 | UInt32(PhysicsCategory.InteractableObjects) | UInt32(PhysicsCategory.NonInteractableObjects) | UInt32(PhysicsCategory.Reset) | UInt32(PhysicsCategory.Player) | UInt32(PhysicsCategory.Portals)
    }    
}

