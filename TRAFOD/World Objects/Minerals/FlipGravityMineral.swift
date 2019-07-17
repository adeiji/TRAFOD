//
//  FlipGravityMineral.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/10/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class RetrieveMineralNode : SKSpriteNode, SKPhysicsContactDelegate {
    
    var world:World?
    var mineralType:Minerals!

    init(texture: SKTexture) {
        super.init(texture: texture, color: .clear, size: texture.size())
        self.physicsBody = SKPhysicsBody(rectangleOf: self.texture?.size() ?? CGSize(width: 50, height: 50))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Nothing)
        self.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.Player)
        self.physicsBody?.isDynamic = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     Adds the current element to the elements that the user has collected
     
     - parameters:
     - node The node that has been collected. ie: antigrav-mineral1
     
     */
    func addToCollectedElements (node:SKNode) {
        node.removeFromParent()
        if let level = self.world?.currentLevel {
            if self.world?.collectedElements[level] == nil {
                self.world?.collectedElements[level] = [String]()
            }
            
            if let name = node.name {
                self.world?.collectedElements[level]?.append(name)
                if let currentLevel = self.world?.currentLevel {
                    ProgressTracker.updateElementsCollected(level: currentLevel.rawValue, node: name)
                }
            }
        }
    }
    
    /**
     
     When the player collides with a mineral and retrieves it if it's the first time then we display a box that shows player how to use the mineral or it simply adds ten more minerals to the player's mineral count
     
     - Parameter type: The type of Mineral that the player is getting
     
     */
    func getMineral (type: Minerals) {
        if var mineralCount = self.world?.player.mineralCounts[type] {
            mineralCount = mineralCount + 10
            self.world?.player.mineralCounts[type] = mineralCount
            ProgressTracker.updateMineralCount(myMineral: type.rawValue, count: mineralCount)
        } else {
            self.world?.player.mineralCounts[type] = 10;
            ProgressTracker.updateMineralCount(myMineral: type.rawValue, count: 10)
        }
        
        self.world?.playMineralSound()
        self.world?.showMineralCount()
    }
}

class MineralGroup : SKNode { }

class FlipGravityRetrieveMineral : RetrieveMineralNode {
    override init(texture: SKTexture) {
        super.init(texture: texture)
        
        self.mineralType = .FLIPGRAVITY
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

class Mineral: SKSpriteNode {
    
    class func throwMineral (imageName: String, player: Player, world: World, mineralNode: Mineral) {
        mineralNode.position = player.position
        let width = mineralNode.texture?.size().width
        let height = mineralNode.texture?.size().height
        
        mineralNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width! / 2.0 , height: height! / 2.0))
        mineralNode.physicsBody?.affectedByGravity = true
        mineralNode.physicsBody?.categoryBitMask = 2
        mineralNode.physicsBody?.isDynamic = true
        mineralNode.physicsBody?.contactTestBitMask = 1 | UInt32(PhysicsCategory.InteractableObjects)
        mineralNode.physicsBody?.categoryBitMask = 0b0001
        mineralNode.physicsBody?.collisionBitMask = 0 | UInt32(PhysicsCategory.InteractableObjects)
        mineralNode.physicsBody?.allowsRotation = false
        world.addChild(mineralNode)
        
        if player.previousRunningState == .RUNNINGRIGHT {
            mineralNode.position.x = player.position.x + mineralNode.size.width
            mineralNode.physicsBody?.applyImpulse(CGVector(dx: 50, dy: -30))
        } else {
            mineralNode.position.x = player.position.x - mineralNode.size.width
            mineralNode.physicsBody?.applyImpulse(CGVector(dx: -50, dy: -30))
        }
        
    }
    
    init(texture: SKTexture) {
        let width = texture.size().width * 0.5
        let height = texture.size().height * 0.5
        super.init(texture: texture , color: .clear, size:CGSize(width: width, height: height))
        
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: height))
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.categoryBitMask = 2
        self.physicsBody?.isDynamic = true
        self.physicsBody?.contactTestBitMask = 1 | UInt32(PhysicsCategory.InteractableObjects)
        self.physicsBody?.categoryBitMask = 0b0001
        self.physicsBody?.collisionBitMask = 0 | UInt32(PhysicsCategory.InteractableObjects)
        self.physicsBody?.allowsRotation = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func showMineralCrash (withColor color: UIColor, contact: SKPhysicsContact, duration: TimeInterval = 5) {
        if let crashPath = Bundle.main.path(forResource: "GroundParticle", ofType: "sks") {
            if let crash = NSKeyedUnarchiver.unarchiveObject(withFile: crashPath) as? SKEmitterNode {
                crash.position = contact.contactPoint
                crash.position.y = crash.position.y + 10
                crash.particleColor = color
                crash.particleColorSequence = nil
                self.addChild(crash)
                
                let timeToShowSpark = SKAction.wait(forDuration: duration)
                let removeSparkBlock = SKAction.run {
                    crash.removeFromParent()
                }
                
                let sequence = SKAction.sequence([timeToShowSpark, removeSparkBlock])
                self.run(sequence)
            }
        }
    }
}

class FlipGravityMineral : Mineral, SKPhysicsContactDelegate {
    
    var mineralCrashColor: UIColor = .purple
    
    init() {
        let texture = SKTexture(imageNamed: ImageNames.BlueCrystal.rawValue)
        super.init(texture: texture)
    }
    
    class func throwMineral (imageName: String, player: Player, world: World) {
        let mineralNode = FlipGravityMineral()
        super.throwMineral(imageName: imageName, player: player, world: world, mineralNode: mineralNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func mineralUsed (contactPosition: CGPoint) throws -> FlipGravity {
        guard let world = self.parent as? World else {
            throw WorldError.worldDoesNotExist
        }
        
        let flipGravity = FlipGravity(contactPosition: contactPosition)
        if world.player.previousRunningState == .RUNNINGLEFT {
            flipGravity.position.x = flipGravity.position.x - flipGravity.size.width
        }
        
        flipGravity.zPosition = -5
        return flipGravity
    }
}
