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

class TransferLevel : World {
    
    private var showRunning = false
    private var shouldShowNextLevelAction = false
    private var throwMineral = false    
    private var sceneState:SceneState!
    
    enum SceneState {
        case MOVIE
        case REWIND
        case NORMAL
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.addThrowButton()
        self.addThrowImpulseButton()
        
        self.showBackgroundParticles()
        self.showFireFlies()
        self.physicsWorld.contactDelegate = self
        self.createPlayer()
        self.player.position = CGPoint(x: -(self.scene!.size.width / 2.0) + 100 , y: 0)
        self.player.hasAntigrav = true
//        self.addChild(self.player)
    }
    
    func checkIfFalling () {
        if let point = self.lastPointOnGround {
            if self.playerIsFalling(){
                if (self.player.position.y < point.y) && (abs(self.player.position.y - point.y) > 400) {
                    self.rewindPointCounter = self.rewindPoints.count - 1
                    self.playerState = .INAIR
                    self.sceneState = .REWIND
                    self.player.texture = SKTexture(imageNamed: "spinning")
                    self.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                }
            }
        }
    }
    
    func rewind () {
        if self.rewindPointCounter >= 0 && self.rewindPointCounter < self.rewindPoints.count {
            self.player.position = self.rewindPoints[self.rewindPointCounter]
            self.rewindPointCounter = self.rewindPointCounter - 1
        } else {
            self.sceneState = .NORMAL
            self.rewindPointCounter = 0
            self.lastPointOnGround = self.rewindPoints[0]
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        self.moveCamera()
        
        if self.sceneState == .REWIND {
            let dt = currentTime - self.lastUpdateTime
            self.handlePlayerRotation(dt: dt)
            rewind()
            return
        }
        
        self.checkIfFalling()
        
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
            self.playerState = .INAIR
            self.showRunning(currentTime: currentTime)
            self.jumpButton.removeFromParent()
            self.throwButton.removeFromParent()
            self.throwImpulseButton.removeFromParent()

            if self.shouldShowNextLevelAction == true {
                self.showNextLevelAction()
                self.shouldShowNextLevelAction = false
            }
        }
        
        let dt = currentTime - self.lastUpdateTime
        self.handlePlayerRotation(dt: dt)
        self.lastUpdateTime = currentTime
    }
    
    override func handlePlayerRotation (dt: TimeInterval) {
        if self.playerState == .INAIR && self.sceneState == .MOVIE {
            self.rotateJumpingPlayer(rotation: -Double(dt * 1000))
        } else {
            super.handlePlayerRotation(dt: dt)
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
        let wait = SKAction.wait(forDuration: 5.0)
        let blackScreen = SKSpriteNode(color: .black, size: self.scene!.size)
        blackScreen.alpha = 0
        self.camera?.addChild(blackScreen)
        let fade = SKAction.fadeAlpha(to: 1.0, duration: 5.0)
        blackScreen.run(fade)
        
        let speechBlock = SKAction.run {
            let speech = self.childNode(withName: "speech")
            speech?.alpha = 1.0
        }
        
        let sequence = SKAction.sequence([wait, speechBlock])
        run(sequence)
    }
    
    func moveCamera () {
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
        
        if contactContains(strings: ["ground", "mineralFreeze"], contactA: aName, contactB: bName) {
            self.showMineralCrash(withColor: UIColor.Style.ANTIGRAVMINERAL, contact: contact)
            self.playMineralCrashSound()
            self.showRunning = true
            if let node = getContactNode(string: "mineralFreeze", contact: contact) {
                node.removeFromParent()
            }
        }
        
        if self.contactContains(strings: ["dawud", "level2"], contactA: aName, contactB: bName) {
            if contact.contactNormal.dy > 0 {
                self.sceneState = .MOVIE
                self.throwMineral = true
            }
        } else if self.contactContains(strings: ["mineralFreeze", "ground"], contactA: aName, contactB: bName) {
            self.shouldShowNextLevelAction = true            
        }
    }
    
    func throwFreezeMineral () {
        self.throwMineral = true
    }
}
