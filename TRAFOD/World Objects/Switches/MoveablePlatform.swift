//
//  MovablePlatform.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

enum MoveablePlatformDirection {
    case vertical
    case horizontal        
}

/**
 A vertical Moveable Platform only moves along it's y-axis
 */
class MoveablePlatform : Ground {
    
    private let direction:MoveablePlatformDirection
    
    private let velocity:Double
    
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
    
    init(switchParams: FlipSwitchParams) {
        self.velocity = switchParams.velocity
        self.direction = switchParams.direction
        super.init(size: switchParams.platformSize)
        
        self.setupPhysicsBody()
        self.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.color = .green
        self.position = switchParams.startPos
        self.originalPosition = switchParams.startPos
        self.zPosition = 1000
        
        let constraint = SKConstraint.zRotation(SKRange(constantValue: self.zRotation))
        
        if direction == .vertical {
            let xConstraint = SKConstraint.positionX(SKRange(constantValue: switchParams.startPos.x))
            self.constraints = [constraint, xConstraint]
        } else {
            let yConstraint = SKConstraint.positionY(SKRange(constantValue: switchParams.startPos.y))
            self.constraints = [constraint, yConstraint]
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.direction = .horizontal
        self.velocity = 100
        super.init(coder: aDecoder)
        
        self.originalPosition = self.position
    }
    
    override func setupPhysicsBody() {
        self.physicsBody?.mass = 10000
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Player) | UInt32(PhysicsCategory.Minerals) | UInt32(PhysicsCategory.Rock)
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Ground)
        self.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.Player) | UInt32(PhysicsCategory.Minerals)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.friction = 5.0
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    /**
     Sets the velocity of this object and then returns whether or not the object is moving towards it's final position or not
     */
    @discardableResult private func setVelocityAndGetIsMovingForward (moveToPoint: CGPoint) -> Bool {
        
        let yVector = self.position.y < moveToPoint.y ? self.velocity : -self.velocity
        let xVector = self.position.x < moveToPoint.x ? self.velocity : -self.velocity
        
        var isMovingForward = false
        
        switch self.direction {
        case .horizontal:
            if self.position.x < moveToPoint.x {
                isMovingForward = true
            } else {
                isMovingForward = false
            }
            
            
//            self.physicsBody?.velocity = CGVector(dx: xVector, dy: 0)
        case.vertical:
            if self.position.y < moveToPoint.y {
                isMovingForward = true
            } else {
                isMovingForward = false
            }
            
//            self.physicsBody?.velocity = CGVector(dx: 0, dy: yVector)
        }
        
        return isMovingForward
    }
    
    /*
     Moves the platform from it's starting position to the moveToPoint position or to it's original starting position
     */
    func move () {
        guard let moveToPoint = self.finishedMoving == false ? self.moveToPoint : self.originalPosition else {
            return
        }
                        
        self.physicsBody?.velocity = .zero
        self.physicsBody?.isDynamic = true
        
        let isMovingForward = self.setVelocityAndGetIsMovingForward(moveToPoint: moveToPoint)
        self.finishedMoving = !self.finishedMoving
        
        let action = SKAction.move(to: moveToPoint, duration: 3.0)
        self.run(action) {
            self.physicsBody?.isDynamic = false
        }
    }
}
