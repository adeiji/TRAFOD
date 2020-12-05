//
//  Ground.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 8/1/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit


protocol GroundProtocol {
    var isImmovableGround:Bool { get set }
}

class Fence: SKSpriteNode, ObjectWithManuallyGeneratedPhysicsBody {
    
    func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.restitution = 0
        self.physicsBody?.mass = 0
        self.physicsBody?.isDynamic = false
        self.physicsBody?.pinned = true
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Fence)
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Nothing)
        self.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.Player)
        self.physicsBody?.fieldBitMask = UInt32(PhysicsCategory.Nothing)
        self.physicsBody?.allowsRotation = false
    }                
}

class Ground : SKSpriteNode, GroundProtocol, ObjectWithManuallyGeneratedPhysicsBody {
    
    var isImmovableGround = false
    
    init(size: CGSize, anchorPoint:CGPoint = CGPoint(x: 0.5, y: 0.5)) {
        super.init(texture: nil, color: .clear, size: size)
        self.anchorPoint = anchorPoint
        self.color = .blue
        self.physicsBody = SKPhysicsBody(rectangleOf: size, center: CGPoint(x: self.position.x + self.size.width / 2.0, y: self.position.y))
        self.setupPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isImmovableGround = true
    }
    
    func setupPhysicsBody () {
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.restitution  = 0
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Ground)
        self.physicsBody?.contactTestBitMask = 1 | UInt32(PhysicsCategory.Player) | UInt32(PhysicsCategory.Minerals)
        self.physicsBody?.collisionBitMask = 1 | UInt32(PhysicsCategory.Player) | UInt32(PhysicsCategory.Minerals)
        self.physicsBody?.friction = 1.0
        if self.isImmovableGround {
            self.physicsBody?.mass = 100000
            self.physicsBody?.pinned = true
            self.physicsBody?.allowsRotation = false
        }
    }
    
    func pinIt () {
        self.physicsBody?.pinned = true
        self.physicsBody?.allowsRotation = false
    }
}
