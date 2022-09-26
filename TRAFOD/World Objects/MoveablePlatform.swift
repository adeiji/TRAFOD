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
    
    init(startingPosition: CGPoint, size: CGSize, direction: MoveablePlatformDirection) {
        self.direction = direction
        super.init(size: size)
        
        self.setupPhysicsBody()
        self.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.color = .green
        self.position = startingPosition
        self.originalPosition = startingPosition
        self.zPosition = 1000
        
        let constraint = SKConstraint.zRotation(SKRange(constantValue: self.zRotation))
        
        if direction == .vertical {
            let xConstraint = SKConstraint.positionX(SKRange(constantValue: startingPosition.x))
            self.constraints = [constraint, xConstraint]
        } else {
            let yConstraint = SKConstraint.positionY(SKRange(constantValue: startingPosition.y))
            self.constraints = [constraint, yConstraint]
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.direction = .horizontal
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
    
    /*
     Moves the platform from it's starting position to the moveToPoint position or to it's original starting position
     */
    func move () {
        guard let moveToPoint = self.finishedMoving == false ? self.moveToPoint : self.originalPosition else {
            return
        }
                        
        self.physicsBody?.velocity = .zero
        let yVector = self.position.y < moveToPoint.y ? 100 : -100
        let xVector = self.position.x < moveToPoint.x ? 100 : -100
        
        var isMovingForward = false
        self.physicsBody?.isDynamic = true
        
        switch self.direction {
        case .horizontal:
            if self.position.x < moveToPoint.x {
                isMovingForward = true
            } else {
                isMovingForward = false
            }
            self.physicsBody?.velocity = CGVector(dx: xVector,dy: 0)
        case.vertical:
            if self.position.y < moveToPoint.y {
                isMovingForward = true
            } else {
                isMovingForward = false
            }
            
            self.physicsBody?.velocity = CGVector(dx: 0,dy: yVector)
        }
        
        self.finishedMoving = !self.finishedMoving
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            
            func stopMoving () {
                self.physicsBody?.velocity = .zero
                timer.invalidate()
                self.physicsBody?.isDynamic = false
            }
            
            let moveToPointAxis = self.direction == .vertical ? moveToPoint.y : moveToPoint.x
            let positionAxis = self.direction == .vertical ? self.position.y : self.position.x
            
            switch isMovingForward {
            case true:
                if positionAxis >= moveToPointAxis {
                    stopMoving()
                }
            case false:
                if positionAxis <= moveToPointAxis {
                    stopMoving()
                }
            }
        }
    }
}
