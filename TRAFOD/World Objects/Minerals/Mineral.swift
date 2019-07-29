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
}

/**
 The mineral object is the base for all of our minerals that can be actually used within the game.
 
 Throwing and handling of showing the crash from the throw are all handled from within this object.
 
 - Note: The functions that can be called within this object are the following
    ```
    class func throwMineral (imageName: String, player: Player, world: World, self: Mineral)
    func showMineralCrash (withColor color: UIColor, contact: SKPhysicsContact, duration: TimeInterval = 5)
    ```
 
 */
class Mineral: SKSpriteNode {
    
    var type:Minerals = .ANTIGRAV
    var mineralCrashColor: UIColor = .purple
    
    func throwMineral (player: Player, world: World) {
        if world.thrownMineral != nil {
            return
        }
        
        self.position = player.position
        let width = self.texture?.size().width
        let height = self.texture?.size().height
        
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width! / 2.0 , height: height! / 2.0))
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.categoryBitMask = 2
        self.physicsBody?.isDynamic = true
        self.physicsBody?.contactTestBitMask = 1 | UInt32(PhysicsCategory.FlipGravity) | UInt32(PhysicsCategory.Cannon)
        self.physicsBody?.collisionBitMask = 1 | UInt32(PhysicsCategory.Ground) | UInt32(PhysicsCategory.Cannon)
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Minerals)
        self.physicsBody?.allowsRotation = false
        
        world.addChild(self)
        world.thrownMineral = self
        
        if player.previousRunningState == .RUNNINGRIGHT {
            self.position.x = player.position.x + self.size.width
            self.physicsBody?.applyImpulse(CGVector(dx: 10, dy: -30))
        } else {
            self.position.x = player.position.x - self.size.width
            self.physicsBody?.applyImpulse(CGVector(dx: -10, dy: -30))
        }
        
    }
    
    init(mineralType: Minerals) {
        var texture:SKTexture?
        self.type = mineralType
        
        switch mineralType {
        case .ANTIGRAV:
            texture = SKTexture(imageNamed: ImageNames.BlueCrystal.rawValue)
        case .IMPULSE:
            texture = SKTexture(imageNamed: ImageNames.RedCrystal.rawValue)
        case .TELEPORT:
            texture = SKTexture(imageNamed: ImageNames.RedCrystal.rawValue)
        case .USED_TELEPORT:
            break
        case .FLIPGRAVITY:
            texture = SKTexture(imageNamed: ImageNames.BlueCrystal.rawValue)
        case .MAGNETIC:
            texture = SKTexture(imageNamed: ImageNames.BlueCrystal.rawValue)
        }
        
        let width = texture!.size().width * 0.5
        let height = texture!.size().height * 0.5
        super.init(texture: texture , color: .clear, size:CGSize(width: width, height: height))
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
