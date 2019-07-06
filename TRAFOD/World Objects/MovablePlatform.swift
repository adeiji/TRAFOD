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
    
    var finishedMoving = false;
    var moveToPoint:CGPoint?
    var moveDuration:TimeInterval = 3.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.InteractableObjects)
        self.physicsBody?.pinned = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        let constraint = SKConstraint.positionX(SKRange(constantValue: self.position.x))
        self.constraints = [constraint]
    }
    
    /**
     Moves a node to a specificied position
     
     - Parameter nodeName: The name of the node to move
     - Parameter xOffset: How far to move in the x direction
     - Parameter yOffset: How far to move in the y direction
     - Parameter duration: How long to take to move the node
     
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
