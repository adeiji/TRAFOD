//
//  NegateForceField.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/26/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

protocol NegateForceField {
    static func negateForceForObjectInContact(contact: SKPhysicsContact)
    static func removeNegatedForcesFromObjectInContact(contact: SKPhysicsContact)
}

class NegateForceFieldBase : SKSpriteNode, ObjectWithManuallyGeneratedPhysicsBody {
    func setupPhysicsBody() {
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.categoryBitMask  = UInt32(PhysicsCategory.NegateForceField)
        self.physicsBody?.mass = 0
        self.physicsBody?.pinned = true
        self.physicsBody?.affectedByGravity = false
    }
}

class NegateFlipGravField: NegateForceFieldBase, NegateForceField {
    
    class func negateForceForObjectInContact (contact: SKPhysicsContact) {
        let otherObject = contact.bodyA.node as? AffectedByNegationField != nil ? contact.bodyA.node as? AffectedByNegationField : contact.bodyB.node as? AffectedByNegationField
        
        if var otherObject = otherObject {
            otherObject.negatedForces[.FLIPGRAVITY] = true
        }
    }
    
    class func removeNegatedForcesFromObjectInContact (contact: SKPhysicsContact) {
        let otherObject = contact.bodyA.node as? AffectedByNegationField != nil ? contact.bodyA.node as? AffectedByNegationField : contact.bodyB.node as? AffectedByNegationField
        
        if var otherObject = otherObject {
            otherObject.negatedForces.removeValue(forKey: .FLIPGRAVITY)
        }
    }
}

class NegateAllForcesField: NegateForceFieldBase, NegateForceField {
    static func negateForceForObjectInContact(contact: SKPhysicsContact) {
        let otherObject = contact.bodyA.node as? BaseWorldObject != nil ? contact.bodyA.node as? BaseWorldObject : contact.bodyB.node as? BaseWorldObject
        
        if var otherObject = otherObject {
            otherObject.allowExternalForces = false
        }
    }
    
    
    static func removeNegatedForcesFromObjectInContact (contact: SKPhysicsContact) {
        let otherObject = contact.bodyA.node as? BaseWorldObject != nil ? contact.bodyA.node as? BaseWorldObject : contact.bodyB.node as? BaseWorldObject
        
        if var otherObject = otherObject {
            otherObject.allowExternalForces = true
        }
    }
    
}
