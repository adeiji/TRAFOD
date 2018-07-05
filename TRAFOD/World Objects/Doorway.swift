//
//  Doorway.swift
//  TRAFOD
//
//  Created by adeiji on 7/5/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import SpriteKit
import GameKit

class Doorway : SKSpriteNode {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
            self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.NonInteractableObjects)
            self.physicsBody?.collisionBitMask = 0
            self.physicsBody?.allowsRotation = false
            self.physicsBody?.affectedByGravity = false
            self.physicsBody?.pinned = true
        }
    }
}
