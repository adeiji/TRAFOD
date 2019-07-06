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
    
    var temporarySwitches:[FlipSwitch]? = [FlipSwitch]()
    var weightSwitches:[WeightSwitch]? = [WeightSwitch]()
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.setupPlayer()
        self.getProgress()
        self.loadSavedGame(sceneName: GameLevels.level3, level: GameLevels.level3)
        self.showMineralCount()
        self.setWeightSwitchDefaults()
        
        if let tempSwitch = self.childNode(withName: "level3-switch2") as? FlipSwitch {
            tempSwitch.movablePlatform = self.childNode(withName: "level3-ground-switch2") as? MovablePlatform
            tempSwitch.movablePlatform?.moveToPoint = CGPoint(x: -693, y: 0)
            tempSwitch.movablePlatform?.moveDuration = 3.0
            
            self.temporarySwitches?.append(tempSwitch)
        }
    }
    
    func setWeightSwitchDefaults () {
        self.children.forEach { (node) in
            if let weightSwitch = node as? WeightSwitch {
                weightSwitch.setup();
                if let _ = node.childNode(withName: "weightSwitch1") {
                    weightSwitch.topOfSwitch?.verticalForce = 0
                } else if let _ = node.childNode(withName: "weightSwitch2") {
                    weightSwitch.topOfSwitch?.verticalForce = 10000
                } else if let _ = node.childNode(withName: "weightSwitch3") {
                    weightSwitch.topOfSwitch?.verticalForce = 10000
                } else if let _ = node.childNode(withName: "weightSwitch5") {
                    weightSwitch.topOfSwitch?.verticalForce = 10000
                }
                
                self.weightSwitches?.append(weightSwitch)
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
        
        if self.contactContains(strings: ["ground-weightSwitch", "bottomOfSwitch3"], contact: contact) {
            self.movePlatform(nodeName: "level3-ground-weightSwitch3", xOffset: 0, yOffset: 250, duration: 3.0)
            self.pinSwitch(contact: contact)
        }
        
        if (contact.bodyA.node is MultiDirectionalGravObject || contact.bodyB.node is MultiDirectionalGravObject) &&
           (contact.bodyA.node is WeightSwitchBottom || contact.bodyB.node is WeightSwitchBottom) {
            if let node = contact.bodyA.node?.parent as? WeightSwitch {
                if node.name == "WeightSwitch1" {
                    node.platform?.move()
                }
            }
        }
    }
    
    
    
    func pinSwitch (contact: SKPhysicsContact) {
        if let node = contact.bodyA.node as? WeightSwitch {
            node.physicsBody?.pinned = true
        } else if let node = contact.bodyB.node as? WeightSwitch {
            node.physicsBody?.pinned = true
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        self.temporarySwitches?.forEach({ (flipSwitch) in
            flipSwitch.flipSwitch()
        })
    }
}
