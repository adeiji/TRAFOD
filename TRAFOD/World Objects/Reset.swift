//
//  Reset.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class Reset: SKSpriteNode {
    var startingPos:CGPoint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Reset)
        let constraints = [ SKConstraint.positionX(SKRange(constantValue: self.position.x), y: SKRange(constantValue: self.position.y)) ]
        self.constraints = constraints
    }
}
