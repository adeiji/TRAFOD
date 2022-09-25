//
//  PhysicsAlteringFieldJoint.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/25/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

class PhysicsAlteringFieldJoint: SKPhysicsJointFixed {
        
    var type:PhysicsAlteringObjectTypes?
            
    class func fieldJoint(withBodyA bodyA: SKPhysicsBody, bodyB: SKPhysicsBody, anchor: CGPoint) -> PhysicsAlteringFieldJoint? {
        return SKPhysicsJointFixed.joint(withBodyA: bodyA, bodyB: bodyB, anchor: anchor) as? PhysicsAlteringFieldJoint
    }
    
}
