//
//  MovablePlatform.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class MovablePlatform : SKSpriteNode {
    
    /**
     Whether the platform is at it's starting position or not.  If it is at it's starting position that means that it's finished moving
     */
    var finishedMoving = false;
    /**
     The point which to move the platform to
     */
    var moveToPoint:CGPoint?
    /**
     The length of time it should take in seconds from when the movement starts to when it finishes
     */
    var moveDuration:TimeInterval = 3.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        self.physicsBody?.collisionBitMask = 1 | UInt32(PhysicsCategory.InteractableObjects) | UInt32(PhysicsCategory.Player)
//        self.physicsBody?.categoryBitMask =  UInt32(PhysicsCategory.Ground)
//        self.physicsBody?.pinned = true
//        self.physicsBody?.affectedByGravity = false
//        self.physicsBody?.allowsRotation = false
    }
    
    /*
     Moves the platform from it's starting position to the moveToPoint position or to it's original starting position
     */
    func move () {
        if var offset = self.moveToPoint {
            if self.finishedMoving {
                offset.x = offset.x * -1
                offset.y = offset.y * -1
                self.finishedMoving = false
            } else {
                self.finishedMoving = true
            }
                
            let move = SKAction.move(to: CGPoint(x: offset.x, y: offset.y), duration: self.moveDuration)
            self.physicsBody?.pinned = false
            self.removeAllActions()
            self.run(move) {
                self.physicsBody?.pinned = true
            }
        }
    }
}
