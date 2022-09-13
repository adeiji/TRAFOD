//
//  FlipGravityMineral.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/10/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class FlipGravityMineral : Mineral, SKPhysicsContactDelegate, UseMinerals {
    
    init() {
        super.init(mineralType: .FLIPGRAVITY)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func mineralUsed (contactPosition: CGPoint, world:World, objectHitByMineral:SKNode? = nil) -> PhysicsAlteringObject? {
        let flipGravity = FlipGravity(contactPosition: contactPosition, size: CGSize(width: 200, height: 4000), color: .purple, anchorPoint: CGPoint(x: 0.5, y: 0))
        flipGravity.zPosition = -5
        return flipGravity
    }
}

class TeleportRetrievalMineral: RetrieveMineralNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup (name: String) {
        super.setup(name: name)
        self.mineralType = .TELEPORT
        let texture = SKTexture(imageNamed: MineralImageNames.Teleport)
        let action = SKAction.setTexture(texture, resize: true)
        self.run(action)
    }
}

class TeleportMineral : Mineral, SKPhysicsContactDelegate, UseMinerals {
    
    init() {
        super.init(mineralType: .TELEPORT)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func mineralUsed (contactPosition: CGPoint, world:World, objectHitByMineral:SKNode? = nil) -> PhysicsAlteringObject? {
        let teleportNode = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 200))
        teleportNode.position = contactPosition
        
        if let portalPath = Bundle.main.path(forResource: "Doors", ofType: "sks") {
            if let portal = NSKeyedUnarchiver.unarchiveObject(withFile: portalPath) as? SKEmitterNode {
                portal.particleBirthRate = portal.particleBirthRate * 2.0
                
                portal.particlePositionRange.dx = portal.particlePositionRange.dx * 2.0
                portal.particleColor = .orange
                teleportNode.addChild(portal)
            }
        }
        
        teleportNode.position.x = teleportNode.position.x
        teleportNode.zPosition = -5
        teleportNode.position.y = teleportNode.position.y + teleportNode.size.height / 2.0
        teleportNode.name = "mineral-used"
        teleportNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: teleportNode.size.height))
        teleportNode.physicsBody?.allowsRotation = false
        teleportNode.physicsBody?.pinned = false
        teleportNode.physicsBody?.affectedByGravity = false
        teleportNode.physicsBody?.isDynamic = true
        teleportNode.physicsBody?.collisionBitMask = 0
        teleportNode.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Portals)
        
        world.teleportNode = teleportNode
        world.addChild(teleportNode)
        
        return nil
    }
}
