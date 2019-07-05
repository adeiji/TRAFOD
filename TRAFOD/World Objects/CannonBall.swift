//
//  CannonBall.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class CannonBall : SKSpriteNode {
    
    init(cannon: Cannon) {
        let texture = SKTexture(imageNamed: "cannonball")
        super.init(texture: texture, color: .clear, size: CGSize(width: texture.size().width / 5.0, height: texture.size().height / 10.0) )
        
        self.name = "cannonball"
        self.physicsBody = SKPhysicsBody(circleOfRadius: 25 )
        self.physicsBody?.mass = 15
        self.physicsBody?.collisionBitMask = 0b0010
        self.physicsBody?.contactTestBitMask = 1 | UInt32(PhysicsCategory.NonInteractableObjects)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.restitution = 1.0
        self.physicsBody?.allowsRotation = false
        self.showResetParticles(node: self)
        
        
        cannon.addChild(self)
    }
    
    func showResetParticles (node: SKSpriteNode) {
        if let fireFliesParticlesPath = Bundle.main.path(forResource: "Doors", ofType: "sks") {
            if let fireFliesParticles = NSKeyedUnarchiver.unarchiveObject(withFile: fireFliesParticlesPath) as? SKEmitterNode {
                fireFliesParticles.zPosition = 0
                fireFliesParticles.particleBirthRate = fireFliesParticles.particleBirthRate / 8.0
                fireFliesParticles.particleLifetime = fireFliesParticles.particleLifetime / 8.0
                fireFliesParticles.particlePositionRange.dx = node.size.width
                fireFliesParticles.particlePositionRange.dy = node.size.height
                fireFliesParticles.particleSize = CGSize(width: fireFliesParticles.particleSize.width / 10.0, height: fireFliesParticles.particleSize.width / 10.0)
                fireFliesParticles.particleColor = .white
                node.addChild(fireFliesParticles)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
