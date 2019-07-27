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
    
    func mineralUsed (contactPosition: CGPoint, world:World) -> PhysicsAlteringObject? {
        let flipGravity = FlipGravity(contactPosition: contactPosition, size: CGSize(width: 200, height: 4000), color: .purple, anchorPoint: CGPoint(x: 0.5, y: 0))
        flipGravity.zPosition = -5
        return flipGravity
    }
}

class AntiGravityMineral : Mineral, UseMinerals {
    init() {
        super.init(mineralType: .ANTIGRAV)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func mineralUsed (contactPosition: CGPoint, world: World) throws  -> PhysicsAlteringObject? {
        
        if !world.forces.contains(.ANTIGRAV) {
            world.playSound(fileName: "antigrav")
            world.physicsWorld.gravity.dy = world.physicsWorld.gravity.dy / 2.2
            world.forces.append(.ANTIGRAV)
            
            let antiGravView = world.camera?.childNode(withName: world.antiGravViewKey)
            antiGravView?.isHidden = false
            
            let timeNode = SKLabelNode()
            timeNode.fontSize = 100
            timeNode.position = CGPoint(x: 0, y: 0)
            world.camera?.addChild(timeNode)
            world.gravityTimeLeft = 10
            let timeLabel = SKLabelNode()
            timeLabel.fontSize = 120
            timeLabel.fontName = "HelveticaNeue-Bold"
            timeLabel.position = CGPoint(x: 0, y: 0)
            timeLabel.zPosition = 5
            world.gravityTimeLeftLabel = timeLabel
            world.camera?.addChild(timeLabel)
            world.changeGravityWithTime(antiGravView: antiGravView, timeLabel: timeLabel)
        } else {
            world.gravityTimeLeft = 10
        }
        
        
        return nil
    }
}

class ImpulseMineral : Mineral, UseMinerals {
    init() {
        super.init(mineralType: .IMPULSE)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func mineralUsed (contactPosition: CGPoint, world:World) throws -> PhysicsAlteringObject? {        
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

class TeleportMineral : Mineral, SKPhysicsContactDelegate, UseMinerals {
    
    init() {
        super.init(mineralType: .TELEPORT)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func mineralUsed (contactPosition: CGPoint, world:World) -> PhysicsAlteringObject? {
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
