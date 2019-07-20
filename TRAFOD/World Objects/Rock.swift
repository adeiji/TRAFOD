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
    }
    
    func setupPhysicsBody () {
        self.physicsBody?.collisionBitMask = 0b0010
        self.physicsBody?.restitution = 0
        self.physicsBody?.contactTestBitMask = 1 | UInt32(PhysicsCategory.InteractableObjects) | UInt32(PhysicsCategory.NonInteractableObjects) | UInt32(PhysicsCategory.Reset) | UInt32(PhysicsCategory.Player) | UInt32(PhysicsCategory.Portals)
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Rock)
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.CannonBall) | UInt32(PhysicsCategory.Ground)
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.friction = 0.5
    }
}
