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
        self.setupPlayer()
    }
    
    func playBackgroundMusic () {
        if let musicURL = Bundle.main.url(forResource: "level2_theme", withExtension: "mp3") {
            self.backgroundMusic = SKAudioNode(url: musicURL)
            addChild(self.backgroundMusic)
        }
        
        if let musicURL = Bundle.main.url(forResource: "birdschirping", withExtension: "wav") {
            self.ambiance = SKAudioNode(url: musicURL)
            self.ambiance.run(SKAction.changeVolume(by: -0.7, duration: 0))
            addChild(self.ambiance)
        }
    }
    
    override func touchDown(atPoint pos: CGPoint) {
        super.touchDown(atPoint: pos)
        
        if let camera = self.camera, let zoomOut = camera.childNode(withName: "zoomOut") {
            if self.nodes(at: pos).contains(zoomOut) {
                if camera.xScale == 1 {
                    self.camera?.xScale = 2
                    self.camera?.yScale = 2
                } else if camera.xScale == 2 {
                    camera.xScale = 1
                    camera.yScale = 1
                }
            }
        }
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        super.didBegin(contact)
        
        // Player hits the door for level3
        if contactContains(strings: ["dawud", "level3"], contact: contact) {
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
