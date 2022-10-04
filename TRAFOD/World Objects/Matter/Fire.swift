//
//  Fire.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/20/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

/**
 A player cannot go through a fire object, however other items can go through just fine
 */
class Fire : SKSpriteNode, ObjectWithManuallyGeneratedPhysicsBody {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.mass = 0
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Element)
        self.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.Player) | UInt32(PhysicsCategory.Element)
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Nothing)
        self.physicsBody?.pinned = true
    }
}


/**
 A player cannot go through a fire object, however other items can go through just fine
 */
class Water : SKSpriteNode, ObjectWithManuallyGeneratedPhysicsBody {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.mass = 0
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Element)
        self.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.Player) | UInt32(PhysicsCategory.Element)
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Nothing)
        self.physicsBody?.pinned = true
    }
    
    class func handleContact (_ contact: SKPhysicsContact, world: World) {
        guard
            let _ = contact.getNodeOfType(Water.self),
            let fire = contact.getNodeOfType(Fire.self)
        else {
            return
        }
        
        fire.removeFromParent()
    }
}
