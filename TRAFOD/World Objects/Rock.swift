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
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.friction = 0.2
        self.massConstant = self.physicsBody?.mass
    }
    
    func update () {
        if self.physicsBody?.allContactedBodies().contains(where: { $0.node is AntiGravityField }) == false {
            self.physicsBody?.mass = self.massConstant ?? 10
        }
    }
}

class NegateFlipGravFieldRock : Rock, AffectedByNegationField {
    var negatedForces: [Minerals : Bool] = [Minerals : Bool]()
}
