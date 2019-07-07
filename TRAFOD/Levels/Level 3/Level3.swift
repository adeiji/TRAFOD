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
        self.playBackgroundMusic(fileName: "level3")
    }
    
    func setWeightSwitchDefaults () {
        self.children.forEach { (node) in
            if let node = node as? FlipSwitch {
                node.setMovablePlatformWithTimeInterval(timeInterval: 3.0)
                self.temporarySwitches?.append(node)
            }
            if let weightSwitch = node as? WeightSwitch {
                weightSwitch.setup();
                if let _ = weightSwitch.childNode(withName: "weightSwitch1") {
                    weightSwitch.topOfSwitch?.verticalForce = 5
                } else if let _ = weightSwitch.childNode(withName: "weightSwitch2") {
                    weightSwitch.topOfSwitch?.verticalForce = 1000
                } else if let _ = node.childNode(withName: "weightSwitch3") {
                    weightSwitch.topOfSwitch?.verticalForce = 3000
                } else if let _ = node.childNode(withName: "weightSwitch5") {
                    weightSwitch.topOfSwitch?.verticalForce = 10000
                }
                
                self.weightSwitches?.append(weightSwitch)
            }
        }
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        super.didBegin(contact)
        
        if PhysicsHandler.shouldSwitch(contact: contact) {
            FlipSwitch.flipSwitch(contact: contact)
        }
        
        if (contact.bodyA.node is MultiDirectionalGravObject || contact.bodyB.node is MultiDirectionalGravObject) &&
           (contact.bodyA.node is WeightSwitchBottom || contact.bodyB.node is WeightSwitchBottom) {
            if let node = contact.bodyA.node?.parent as? WeightSwitch {
                if node.platform?.finishedMoving == false {
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
        
        self.weightSwitches?.forEach({ (weightSwitch) in
            weightSwitch.topOfSwitch?.applyUpwardForce()
        })
    }
}
