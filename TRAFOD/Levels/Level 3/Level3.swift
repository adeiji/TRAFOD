//
//  Level3.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class Level3 : Level {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.setupPlayer()
        self.getProgress()
        self.loadSavedGame(sceneName: GameLevels.level3, level: GameLevels.level3)
        self.showMineralCount()
        self.setWeightSwitchDefaults()
        
    }
    
    func setWeightSwitchDefaults () {
        enumerateChildNodes(withName: "ground-weightSwitch") { (node, pointer) in
            if let weightSwitch = node as? WeightSwitch {
                if let _ = node.childNode(withName: "weightSwitch1") {
                    weightSwitch.collisionImpulseRequired = 100
                    weightSwitch.verticalForce = 0
                    weightSwitch.applyUpwardForce()
                } else if let _ = node.childNode(withName: "weightSwitch2") {
                    weightSwitch.collisionImpulseRequired = 500
                    weightSwitch.verticalForce = 10000
                    weightSwitch.applyUpwardForce()
                }
            }            
        }
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        super.didBegin(contact)
        
        var flipSwitch:FlipSwitch?
        if let mySwitch = contact.bodyA.node as? FlipSwitch {
            flipSwitch = mySwitch
        }
        
        if let mySwitch = contact.bodyB.node as? FlipSwitch {
            flipSwitch = mySwitch
        }
        
        // When the player activates the first switch then pull up the first bridge
        if self.contactContains(strings: ["level3-switch1", "rock"], contact: contact) {
            self.movePlatform(nodeName: "level3-ground-switch1", xOffset: 0, yOffset:  330, duration: 3.0)
            self.flipSwitchOn(node: flipSwitch)
        }
        
        if self.contactContains(strings: ["ground-weightSwitch", "bottomOfSwitch1"], contact: contact) {
            self.movePlatform(nodeName: "level3-ground-weightSwitch1", xOffset: 0, yOffset: -490, duration: 3.0)
            self.pinSwitch(contact: contact)
        }
        
        if self.contactContains(strings: ["ground-weightSwitch", "bottomOfSwitch2"], contact: contact) {
            self.movePlatform(nodeName: "level3-ground-weightSwitch2", xOffset: 0, yOffset: 360, duration: 3.0)
            self.pinSwitch(contact: contact)
        }
    }
    
    func pinSwitch (contact: SKPhysicsContact) {
        if let node = contact.bodyA.node as? WeightSwitch {
            node.physicsBody?.pinned = true
        } else if let node = contact.bodyB.node as? WeightSwitch {
            node.physicsBody?.pinned = true
        }
    }
}
