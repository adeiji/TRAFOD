//
//  Fire.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/20/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class Fire : SKSpriteNode, ObjectWithManuallyGeneratedPhysicsBody {    
    func setupPhysicsBody() {
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.mass = 0
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Fire)
    }
}
