//
//  DoubleGravField.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class DoubleGravField : SKSpriteNode {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.NonInteractableObjects)
    }
    
    func gravitation (mass: CGFloat) -> CGVector {
        return CGVector(dx: 0, dy: (-9.8 * 4) * mass)
    }
}
