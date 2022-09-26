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
    
    func setupPhysicsBody () {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Reset)
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Nothing)
        self.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.Rock)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.pinned = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.mass = 0.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let constraints = [ SKConstraint.positionX(SKRange(constantValue: self.position.x), y: SKRange(constantValue: self.position.y)) ]
        self.constraints = constraints
        
    }
}
