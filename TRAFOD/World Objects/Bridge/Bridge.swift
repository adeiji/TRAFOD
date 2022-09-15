//
//  Bridge.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/14/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

class Bridge:Ground {
    
    override init(size: CGSize, anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
//        let bridgeTexture = SKTexture(imageNamed: Textures.Bridge)
        super.init(size: size, anchorPoint: anchorPoint)
//        self.texture = bridgeTexture
        self.physicsBody?.mass = 100
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.pinned = true
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Ground)
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Ground) | UInt32(PhysicsCategory.Player)        
    }        
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
