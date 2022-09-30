//
//  Checkpoint.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/30/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

class Checkpoint: SKSpriteNode, ObjectWithManuallyGeneratedPhysicsBody {
    func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Nothing)
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.NonCollision)
        self.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.Player)
    }
    
    static func handleContact (contact: SKPhysicsContact, world: World) {
        guard
            let checkpoint = contact.getNodeOfType(Checkpoint.self),
            let player = contact.getNodeOfType(Player.self) else {
                return
            }
        
        guard let checkpointChild = checkpoint.children.first else {
            assertionFailure("A checkpoint node must have at least one child. The checkpoint child is the position where the player should start again if he dies")
            return
        }
        
        world.startPosition = checkpoint.convert(checkpointChild.position, to: world) 
    }
}
