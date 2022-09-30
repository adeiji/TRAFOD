//
//  Arrow.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/15/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

class Arrow: SKSpriteNode, ProjectileProtocol {
    required init(cannon: LaunchingProtocol) {
        let texture = SKTexture(imageNamed: "cannonball")
        super.init(texture: texture, color: .clear, size: CGSize(width: texture.size().width / 5.0, height: texture.size().height / 10.0) )
        
        self.name = "arrow"
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.mass = 1
        self.physicsBody?.contactTestBitMask =
            UInt32(PhysicsCategory.Ground) |
            UInt32(PhysicsCategory.Portals) |
            UInt32(PhysicsCategory.PhysicsAltering) |
            UInt32(PhysicsCategory.CannonBall) |
            UInt32(PhysicsCategory.Magnetic) |
            UInt32(PhysicsCategory.Impulse) |
            UInt32(PhysicsCategory.ForceField) |
            UInt32(PhysicsCategory.Player)
        
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.CannonBall)
        self.physicsBody?.collisionBitMask =  UInt32(PhysicsCategory.Rock) |  UInt32(PhysicsCategory.Player) | UInt32(PhysicsCategory.Ground) 
        self.physicsBody?.isDynamic = true
        self.physicsBody?.restitution = 0
        self.physicsBody?.allowsRotation = true
        
        cannon.addChild(self)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     Check whether or not an arrow has hit the ground, and then handle that event
     
     - Parameters:
        - contact: The SKPhysicsContact object created for the contact between an arrow and some other object
     
     - returns: Whether or not an arrow hit the ground
     
     */
    static func hitGround (_ contact: SKPhysicsContact) -> Bool {
        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: GroundProtocol.self, nodeBType: Arrow.self) {
            // Remove the arrow from the screen.
            if let arrow = contact.getNodeOfType(Arrow.self) {
                arrow.removeFromParent()
            }
            
            return true
        }
                 
        return false
    }
    
    //  TODO: Check whether or not an arrow has hit any player in the game
    
    /**
      
     Check whether or not an arrow has hit the main player, and then handle that event
     
     - Parameters:
        - contact: The SKPhysicsContact object created for the contact between an arrow and some other object
     
     - returns: Whether or not an arrow hit the main player
     
     */
    static func didHitPlayer (_ contact: SKPhysicsContact) -> Bool {
        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: Player.self, nodeBType: Arrow.self) {
            return true
        }
        
        return false
    }        
}
