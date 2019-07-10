//
//  Level2.swift
//  TRAFOD
//
//  Created by adeiji on 6/25/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import Foundation
import GameKit
import SpriteKit

class Level2 : Level {
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.currentLevel = .LEVEL2
        self.playBackgroundMusic(fileName: "level3")
        self.setupPlayer()
        self.children.forEach { (node) in
            if let node = node as? FlipSwitch {
                node.setMovablePlatformWithTimeInterval(timeInterval: 3.0)
            }
        }
    }
    
    override func touchDown(atPoint pos: CGPoint) {
        super.touchDown(atPoint: pos)                
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        super.didBegin(contact)
        
        // Player hits the door for level3
        if PhysicsHandler.contactContains(strings: ["dawud", "level3"], contact: contact) {
            if let level3 = self.transitionToNextScreen(filename: "Level3") as? Level3 {
                level3.player = self.player
                level3.collectedElements = self.collectedElements
                level3.previousWorldPlayerPosition = self.player.position
                level3.previousWorldCameraPosition = self.camera?.position
                return
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)                
    }
}
