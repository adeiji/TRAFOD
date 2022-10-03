//
//  Rock.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class Rock : Ground, BaseWorldObject {
    
    var massConstant: CGFloat?
    
    /** The position where the rock enters the scene at */
    var startingPos:CGPoint!
    
    var allowExternalForces: Bool = true {
        didSet {
            if self.allowExternalForces == false {
                self.physicsBody?.fieldBitMask = 0
            } else {
                self.physicsBody?.fieldBitMask = UInt32(PhysicsCategory.Magnetic)
            }
        }
    }
    
    override init(size: CGSize, anchorPoint:CGPoint = CGPoint(x: 0.5, y: 0.5)) {
        super.init(size: size)
        self.anchorPoint = anchorPoint
        self.color = .blue
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.setupPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.startingPos = self.position
        self.isImmovableGround = false
    }
    
    override func setupPhysicsBody () {
        self.physicsBody?.restitution = 0
        self.physicsBody?.contactTestBitMask =
            UInt32(PhysicsCategory.FlipSwitch) |
            UInt32(PhysicsCategory.Reset) |
            UInt32(PhysicsCategory.Player) |
            UInt32(PhysicsCategory.Portals) |
            UInt32(PhysicsCategory.PhysicsAltering) |
            UInt32(PhysicsCategory.Rock) |
            UInt32(PhysicsCategory.Minerals) |
            UInt32(PhysicsCategory.Magnetic) |
            UInt32(PhysicsCategory.Impulse) |
            UInt32(PhysicsCategory.NegateForceField) |
            UInt32(PhysicsCategory.ForceField)            
        self.physicsBody?.fieldBitMask = UInt32(PhysicsCategory.Magnetic)
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Rock)
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.CannonBall) |
            UInt32(PhysicsCategory.Ground) |
            UInt32(PhysicsCategory.Rock) |
            UInt32(PhysicsCategory.Cannon)        
        self.physicsBody?.friction = 0.2
        self.massConstant = self.physicsBody?.mass
        self.physicsBody?.allowsRotation = true
    }
    
    func update () {
        var shouldChangeMassToOriginalValue = true
        
        // If the object is in joined with any objects that alter physics
        self.physicsBody?.joints.forEach({ joint in
            if joint.bodyB.node is PhysicsAlteringObject || joint.bodyA.node is PhysicsAlteringObject {
                shouldChangeMassToOriginalValue = false
            }
        })
        
        // If the object is not in contact with an antigrav field
        if self.physicsBody?.allContactedBodies().contains(where: { $0.node is AntiGravityField }) == true {
            shouldChangeMassToOriginalValue = false
        }
        
        if shouldChangeMassToOriginalValue {
            self.physicsBody?.mass = self.massConstant ?? 10
        }
    }
}

class NegateFlipGravFieldRock : Rock, AffectedByNegationField {
    var negatedForces: [Minerals : Bool] = [Minerals : Bool]()
}
