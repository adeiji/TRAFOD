//
//  Rock.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class Rock : SKSpriteNode {
    
    var startingPos:CGPoint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.startingPos = self.position
        self.physicsBody?.collisionBitMask = 0b0010
        self.physicsBody?.restitution = 0
        self.physicsBody?.contactTestBitMask = 1 | UInt32(PhysicsCategory.InteractableObjects) | UInt32(PhysicsCategory.NonInteractableObjects) | UInt32(PhysicsCategory.Reset)
        self.physicsBody?.allowsRotation = true
    }
}
