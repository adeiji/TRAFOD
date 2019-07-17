//
//  FlipGravity.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/10/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class ForcePhysicsBody : SKPhysicsBody {

    init(size: CGSize) {
        super.init()        

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

/**
 FlipGravity is a SpriteNode which applies a force equal to the oppositive of gravity * 2 to whatever object affected by gravity that is in contact with it
 FlipGravity does not affect the gravity of the entire world, but only to objects in contact with it, and the FlipGravity node does not have a width of the full screen
 but instead it's a fixed width of x
 */
class FlipGravity : SKSpriteNode {
    
    init(contactPosition: CGPoint) {
        super.init(texture: nil, color: .purple, size: CGSize(width: 200, height: 2000))
        self.position = contactPosition
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.NonInteractableObjects)
        self.physicsBody?.contactTestBitMask = 1
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Nothing)
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.pinned = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     Whatever the gravity is for the world currently, than we apply a force to all physics bodies in contact with it equal to the oppositive of the current force of gravity
     
     - Parameters:
        - forceOfGravity: CGFloat The current force applied to all objects within the physics world
        - camera: The camera node that is currently showing on the screen.  We need this to check if the physics body that is in contact with this node is actually on the screen
     */
    func applyFlipGravityToContactedBodies (forceOfGravity: CGFloat, camera: SKCameraNode?) {
        self.physicsBody?.allContactedBodies().forEach({ (body) in
            if let camera = camera?.parent {
                if let node = body.node {
                    if camera.contains(node.position) {
                        body.applyImpulse(CGVector(dx: 0, dy: (forceOfGravity * -1) * 5))
                        
                        if let player = node as? Player {
                            if let world = World.getMainWorldFromNode(node: player) {
                                world.player.flipPlayer(flipUpsideDown: true)
                            }
                        }
                    }
                }
            }
        })
    }
}
