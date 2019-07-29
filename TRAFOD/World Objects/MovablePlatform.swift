//
//  MovablePlatform.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class MovablePlatform : Ground {
    
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
    
    var originalPosition:CGPoint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.originalPosition = self.position
    }
    
    override func setupPhysicsBody() {
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Player) | UInt32(PhysicsCategory.Minerals) | UInt32(PhysicsCategory.Rock)
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Ground)
        self.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.Player) | UInt32(PhysicsCategory.Minerals)
        self.physicsBody?.pinned = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    /*
     Moves the platform from it's starting position to the moveToPoint position or to it's original starting position
     */
    func move () {
        guard let moveToPoint = self.finishedMoving == false ? self.moveToPoint : self.originalPosition else {
            return
        }
        
        let move = SKAction.move(to: CGPoint(x: moveToPoint.x, y: moveToPoint.y), duration: self.moveDuration)
        self.physicsBody?.pinned = false
        self.removeAllActions()
        self.run(move) {
            if let name = self.name {
                if name.contains("pin") {
                    self.physicsBody?.pinned = true
                }
            }
            self.finishedMoving = !self.finishedMoving
        }
    }
}
