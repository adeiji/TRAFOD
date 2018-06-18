//
//  MainMenu.swift
//  TRAFOD
//
//  Created by adeiji on 6/11/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import SpriteKit
import GameplayKit

class MainMenu: World {

    private var newGameButton:SKNode!
    
    override func didMove(to view: SKView) {
        self.previousPlayerRunningState = .RUNNINGRIGHT
        self.createPlayer()
        self.player.position = CGPoint(x: 0, y: 0)
        self.showMineralParticles()
        self.showFireFlies()
        
        self.physicsWorld.contactDelegate = self
        if let musicURL = Bundle.main.url(forResource: "dawudsong", withExtension: "wav") {
            let backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        let aName = contact.bodyA.node?.name ?? ""
        let bName = contact.bodyB.node?.name ?? ""
        
        if contactContains(strings: ["story", "dawud"], contactA: aName, contactB: bName) {
            // Take user to the first level
            let story = Story(fileNamed: "Story")
            let transition = SKTransition.moveIn(with: .right, duration: 1)
            story?.scaleMode = SKSceneScaleMode.aspectFill
            self.view?.presentScene(story!, transition: transition)
        }
    }
}
