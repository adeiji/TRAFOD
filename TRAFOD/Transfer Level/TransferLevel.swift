//
//  TransferLevel.swift
//  TRAFOD
//
//  Created by adeiji on 6/13/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

class TransferLevel : Level {
    
    private var showRunning = false
    private var shouldShowNextLevelAction = false
    private var throwMineral = false    
    private var sceneState:SceneState!
    private var websiteButton:SKLabelNode?
    
    enum SceneState {
        case MOVIE
        case REWIND
        case NORMAL
    }
    
    func showMineralsReceived () {
        if let antiGravCount = self.player.mineralCounts[.ANTIGRAV] {
            if let myNode = self.childNode(withName: "antiGravCounter") as? SKLabelNode {
                myNode.text = "Collected \(antiGravCount) of 220"
            }
        }
        
        if let impulseCount = self.player.mineralCounts[.IMPULSE] {
            if let node = self.childNode(withName: "impulseCounter") as? SKLabelNode {
                node.text = "Collected \(impulseCount) of 330"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.player.position = CGPoint(x: -(self.scene!.size.width / 2.0) + 100 , y: 0)
        self.showMineralsReceived()
        
        if let musicURL = Bundle.main.url(forResource: "birdschirping", withExtension: "wav") {
            self.backgroundMusic = SKAudioNode(url: musicURL)
            let volume = SKAction.changeVolume(to: 0.7, duration: 0.0)
            self.backgroundMusic.run(volume)
            addChild(self.backgroundMusic)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if self.throwMineral == true {
            if let freezeMineral = self.childNode(withName: "mineralFreeze") as? SKSpriteNode {
                freezeMineral.alpha = 1.0
                freezeMineral.physicsBody = SKPhysicsBody(rectangleOf: freezeMineral.texture!.size())
                freezeMineral.physicsBody?.affectedByGravity = true
                freezeMineral.physicsBody?.categoryBitMask = 2
                freezeMineral.physicsBody?.isDynamic = true
                freezeMineral.physicsBody?.contactTestBitMask = 1
                freezeMineral.physicsBody?.categoryBitMask = 0b0001
                freezeMineral.physicsBody?.allowsRotation = false
                freezeMineral.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -1000))
                
                if let index = self.forces.index(of: .ANTIGRAV) {
                    self.forces.remove(at: index)
                }
                
            }
            self.throwMineral = false
        }                
        
        if self.showRunning {
            self.player.state = .INAIR
            self.showRunning(currentTime: currentTime)
            self.jumpButton?.removeFromParent()

            if self.shouldShowNextLevelAction == true {
                self.showNextLevelAction()
                self.shouldShowNextLevelAction = false
            }
        }
        
        self.lastUpdateTime = currentTime
    }
    
    
    override func touchDown(atPoint pos: CGPoint) {
        super.touchDown(atPoint: pos)
        
        if let websiteButton = self.websiteButton {
            if self.nodes(at: pos).contains(websiteButton) {
                if let url = URL(string: "http://www.trafodgame.net") {
                    UIApplication.shared.open(url, options: [:])
                }
            }
        }
    }
    
    override func touchMoved(toPoint pos: CGPoint) {
        if self.sceneState == .MOVIE {
            return
        } else {
            super.touchMoved(toPoint: pos)
        }
    }
    
    func showNextLevelAction () {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.player.physicsBody?.applyImpulse(CGVector(dx: -500, dy: 5))
        let zeroGravView = SKSpriteNode(color: .green, size: self.scene!.size)
        zeroGravView.zPosition = -25
        zeroGravView.alpha = 0.5
        zeroGravView.position = CGPoint(x: 0, y: 0)
        self.camera?.addChild(zeroGravView)
        self.gravityTimeLeftLabel.removeFromParent()
        var wait = SKAction.wait(forDuration: 5.0)
        let blackScreen = SKSpriteNode(color: .black, size: self.scene!.size)
        blackScreen.alpha = 0        
        self.camera?.addChild(blackScreen)
        let fade = SKAction.fadeAlpha(to: 1.0, duration: 5.0)
        blackScreen.run(fade)
        if let speech = self.camera?.childNode(withName: "speech") {
            let speechBlock = SKAction.run {
                speech.alpha = 1.0
            }
            
            var sequence = SKAction.sequence([wait, speechBlock])
            run(sequence)
            
            wait = SKAction.wait(forDuration: 10.0)
            
            let nextLevelBlock = SKAction.run {
                self.loadAndGotoNextLevel(level: .Level2)
            }
            
            sequence = SKAction.sequence([wait, nextLevelBlock])
            run(sequence)
        }
    }
    
    func showSubscriptionPage() {
        let subscriptionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "subscribe")
        self.view?.window?.rootViewController = subscriptionVC
    }
    
    override func moveCameraWithPlayer () {
        self.camera?.position.y = self.player.position.y
        
        for node in self.children {
            if node.name == "story" {
                let distance = self.player.position.y - node.position.y
                if distance > -500 && distance < 500  {
                    let alpha = 1 - (distance / 500)
                    let fade = SKAction.fadeAlpha(to: alpha, duration: 1.0)
                    node.run(fade)
                } else {
                    let fade = SKAction.fadeAlpha(to: 0.0, duration: 1.0)
                    node.run(fade)
                }
            }
        }
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        super.didBegin(contact)
        
        let aName = contact.bodyA.node?.name ?? ""
        let bName = contact.bodyB.node?.name ?? ""
        
        // If the player hits the door to take them to level 1
        if PhysicsHandler.contactContains(strings: ["level1", "dawud"], contactA: aName, contactB: bName) {
            // Load the level 1 screen
            self.loadAndGotoNextLevel(level: .Level1)
        }
        
        if PhysicsHandler.contactContains(strings: ["ground", "mineralFreeze"], contactA: aName, contactB: bName) {
            self.sounds?.playSound(sound: .MINERALCRASH)            
            self.showRunning = true
            if let node = getContactNode(name: "mineralFreeze", contact: contact) {
                node.removeFromParent()
            }
        }
        
        if PhysicsHandler.self.contactContains(strings: ["dawud", "level2"], contactA: aName, contactB: bName) {
            if contact.contactNormal.dy > 0 {
                self.sceneState = .MOVIE
                self.throwMineral = true
            }
        } else if PhysicsHandler.self.contactContains(strings: ["mineralFreeze", "ground"], contactA: aName, contactB: bName) {
            self.shouldShowNextLevelAction = true            
        }
    }
    
    func throwFreezeMineral () {
        self.throwMineral = true
    }
}
