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
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.InteractableObjects)
        self.physicsBody?.pinned = true
        self.physicsBody?.affectedByGravity = false
        let constraint = SKConstraint.positionX(SKRange(constantValue: self.position.x))
        self.constraints = [constraint]
    }
}
