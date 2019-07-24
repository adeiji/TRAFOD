//
//  Mineral.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/22/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

protocol MineralProtocol {
    static func throwIt(player: Player, world: World) 
}

/**
 The mineral object is the base for all of our minerals that can be actually used within the game.
 
 Throwing and handling of showing the crash from the throw are all handled from within this object.
 
 - Note: The functions that can be called within this object are the following
    ```
    class func throwMineral (imageName: String, player: Player, world: World, mineralNode: Mineral)
    func showMineralCrash (withColor color: UIColor, contact: SKPhysicsContact, duration: TimeInterval = 5)
    ```
 
 */
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
