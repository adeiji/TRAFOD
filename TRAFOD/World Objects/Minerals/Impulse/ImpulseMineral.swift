//
//  ImpulseMineral.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 8/6/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class ImpulseMineral : Mineral, UseMinerals {
    init() {
        super.init(mineralType: .IMPULSE)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func mineralUsed (contactPosition: CGPoint, world:World, objectHitByMineral:SKNode? = nil) -> PhysicsAlteringObject? {
        if world.impulses.count < 3 {
            let impulseNode = Impulse(contactPosition: contactPosition, anchorPoint: CGPoint(x: 0.5, y: 0))
            impulseNode.position = contactPosition
            if let portalPath = Bundle.main.path(forResource: "Doors", ofType: "sks") {
                if let portal = NSKeyedUnarchiver.unarchiveObject(withFile: portalPath) as? SKEmitterNode {
                    portal.particleBirthRate = portal.particleBirthRate * 2.0
                    
                    portal.particlePositionRange.dx = portal.particlePositionRange.dx * 2.0
                    portal.particleColor = .orange
                    impulseNode.addChild(portal)
                }
            }
            
            if world.player.previousRunningState == .RUNNINGRIGHT {
                impulseNode.position.x = impulseNode.position.x + 75
            } else {
                impulseNode.position.x = impulseNode.position.x - 75
            }
            
            impulseNode.zPosition = -5
            impulseNode.position.y = impulseNode.position.y + impulseNode.size.height / 2.0
            world.addChild(impulseNode)
            world.impulses.append(.IMPULSE)
        }
        
        return nil
    }
}

class Impulse : PhysicsAlteringObject {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(contactPosition: CGPoint, size: CGSize? = nil, color: UIColor? = .clear, anchorPoint: CGPoint) {
        super.init(contactPosition: contactPosition, size: size ?? CGSize(width: 60, height: 200), color: color ?? .purple, anchorPoint: anchorPoint)
        self.setCategoryBitmask()
    }
    
    internal override func setCategoryBitmask() {
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Impulse)
    }
    
    override func applyForceToPhysicsBodies(forceOfGravity: CGFloat, camera: SKCameraNode?) {
        
    }
    
    class func applyImpulseToNodeInContact (contact: SKPhysicsContact) {
        if let nodeInContact = contact.bodyA.node as? Impulse == nil ? contact.bodyA.node : contact.bodyB.node {
            nodeInContact.physicsBody?.applyImpulse(CGVector(dx: (nodeInContact.physicsBody!.velocity.dx > 0 ? 600 : -600) * (nodeInContact.physicsBody?.mass ?? 1), dy: 250))
            if let player = nodeInContact as? Player {
                player.state = .INAIR
            }
        }
    }
}
