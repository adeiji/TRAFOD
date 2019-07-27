//
//  DoubleGravField.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class DoubleGravField : SKSpriteNode, ObjectWithManuallyGeneratedPhysicsBody {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func gravitation (mass: CGFloat) -> CGVector {
        return CGVector(dx: 0, dy: (-9.8 * 4) * mass)
    }
    
    func setupPhysicsBody() {
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.ForceField)
        self.physicsBody?.collisionBitMask = 0
    }
}
