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
    private var canContinue = false
    
    override func didMove(to view: SKView) {
        self.previousPlayerRunningState = .RUNNINGRIGHT
        self.createPlayer()
        self.player.position = CGPoint(x: 0, y: 0)
        self.showMineralParticles()
        self.showFireFlies()
        self.getProgress()
        self.showDoorParticles()
        
        self.physicsWorld.contactDelegate = self
        if let musicURL = Bundle.main.url(forResource: "dawudsong", withExtension: "wav") {
            let backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
    }
    
    func isSubscribed () {
        
    }
    
    override func showDoorParticles () {
        self.enumerateChildNodes(withName: "door") { (door, pointer) in
            if let fireFliesParticlesPath = Bundle.main.path(forResource: "Doors", ofType: "sks") {
                if let fireFliesParticles = NSKeyedUnarchiver.unarchiveObject(withFile: fireFliesParticlesPath) as? SKEmitterNode {
                    if self.canContinue == false {
                        if door.position.x > 0 {
                            fireFliesParticles.zPosition = 0
                            fireFliesParticles.position = door.position
                            self.addChild(fireFliesParticles)
                        }
                    } else {
                        fireFliesParticles.zPosition = 0
                        fireFliesParticles.position = door.position
                        self.addChild(fireFliesParticles)
                    }
                    
                }
            }
        }
    }
    
    func getProgress () {
        if let progress = ProgressTracker.getProgress() {
            if progress.currentLevel == GameLevels.level1 {
                if let continueNode = self.childNode(withName: "continue") {
                    continueNode.alpha = 1.0
                }
                
                self.canContinue = true
            }
            
            self.player.hasAntigrav = progress.hasAntigrav
            self.player.hasImpulse = progress.hasImpulse
        }
    }
    
    func getMineralCounts () {
        if let mineralCounts = ProgressTracker.getMineralCounts() {
            for mineralCount in mineralCounts {
                if mineralCount.mineral == Minerals.ANTIGRAV.rawValue {
                    self.player.mineralCounts[.ANTIGRAV] = mineralCount.count
                } else if mineralCount.mineral == Minerals.IMPULSE.rawValue {
                    self.player.mineralCounts[.IMPULSE] = mineralCount.count
                }
            }
        }
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        let aName = contact.bodyA.node?.name ?? ""
        let bName = contact.bodyB.node?.name ?? ""
        
        if contactContains(strings: ["story", "dawud"], contactA: aName, contactB: bName) {
            // Take user to the first level and remove all progress
            self.beginNewGame()
            return            
        }
        
        if contactContains(strings: ["dawud", "gotoLevel"], contactA: aName, contactB: bName) {
            if self.canContinue {
                self.loadSavedGame()
            }
        }
    }
    
    private func beginNewGame () {
        ProgressTracker.reset()
        let story = Story(fileNamed: "Story")
        story?.player = self.player
        self.player.removeFromParent()
        let transition = SKTransition.moveIn(with: .right, duration: 1)
        story?.scaleMode = SKSceneScaleMode.aspectFit
        self.view?.presentScene(story!, transition: transition)
    }
    
    /*
     
     Load a saved game, continue the story
     
     */
    private func loadSavedGame () {
        self.getMineralCounts()
        let loading = Loading(fileNamed: "Loading")
        loading?.nextSceneName = "GameScene"
        self.getCollectedElements(level: GameLevels.level1)
        loading?.collectedElements = self.collectedElements
        loading?.player = self.player
        self.player.removeFromParent()
        let transition = SKTransition.moveIn(with: .right, duration: 0)
        loading?.scaleMode = SKSceneScaleMode.aspectFit
        self.view?.presentScene(loading!, transition: transition)
    }
}
