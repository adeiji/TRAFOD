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
    }

    
}
