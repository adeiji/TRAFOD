//
//  Story.swift
//  TRAFOD
//
//  Created by adeiji on 6/12/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Story : World {
    
    private var cameraPositions = [CGPoint(x: 0, y: 0),CGPoint(x: 1334, y: 0),
                                   CGPoint(x: 2512, y: 0), CGPoint(x: 3718, y: 0),
                                   CGPoint(x: 5280, y: 0), CGPoint(x: 6769, y: 0),
                                   CGPoint(x: 8123, y: 0)]
    private var fadeColor:SKSpriteNode!
    private var minCameraX:CGFloat!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.physicsWorld.contactDelegate = self
        self.createPlayer()
        self.showFireFlies()
        self.showBackgroundParticles()
        self.player.position.x = -200        
//        self.fadeColor = self.camera?.childNode(withName: "fadeColor") as! SKSpriteNode
//        self.playStory()
        
        if let node = self.childNode(withName: "Page1Text") {
            let fade = SKAction.fadeAlpha(to: 1.0, duration: 2.0)
            node.run(fade)
        }
        
        if let musicURL = Bundle.main.url(forResource: "Introduction Music", withExtension: "wav") {
            self.backgroundMusic = SKAudioNode(url: musicURL)
            addChild(self.backgroundMusic)
        }
    }
    
    func fade (duration: TimeInterval) {
        
        let fadeAction = SKAction.fadeAlpha(by: -1.0, duration: 3)
        self.fadeColor.run(fadeAction)
        
        let timer = SKAction.wait(forDuration: duration)
        let fadeBlock = SKAction.run {
            let fadeAction = SKAction.fadeAlpha(by: 1.0, duration: 3)
            self.fadeColor.run(fadeAction)
        }
        
        let sequence = SKAction.sequence([timer, fadeBlock])
        run(sequence)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        let dt = currentTime - self.lastUpdateTime
        self.moveCamera()
        self.handlePlayerRotation(dt: dt)
        self.lastUpdateTime = currentTime
    }
    
    func moveCamera() {
        if self.player.position.x > self.camera!.position.x {
            if self.minCameraX == nil {
                self.minCameraX = self.camera!.position.x
            }
        }
        
        if ((self.minCameraX != nil) && (self.player.position.x >= self.minCameraX)) && self.player.position.x < 8640 {
            self.camera?.position.x = self.player.position.x
        }
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        super.didBegin(contact)
        
        let aName = contact.bodyA.node?.name ?? ""
        let bName = contact.bodyB.node?.name ?? ""
        
        if contactContains(strings: ["firstLevel","dawud"], contactA: aName, contactB: bName) {
            self.showFirstLevel()
        }
    }
    
    func playStory (cameraPosition: CGPoint = CGPoint(x: 0, y: 0), duration: TimeInterval = 12, counter:Int = 0) {
        self.camera?.position = cameraPosition
        self.fade(duration: duration - 3)
        let timer = SKAction.wait(forDuration: duration)
        let storyBlock = SKAction.run {
            if counter == self.cameraPositions.count - 2 {
                let fadeAudio = SKAction.changeVolume(to: 0, duration: 5.0)
                self.backgroundMusic.run(fadeAudio)
            }
            
            if cameraPosition == self.cameraPositions.last {
                self.showFirstLevel()
            } else {
                
                var nextDuration:TimeInterval = 12
                
                if cameraPosition == self.cameraPositions[3] {
                    nextDuration = 28
                }
                
                self.playStory(cameraPosition: self.cameraPositions[counter + 1], duration: nextDuration, counter: counter + 1)
            }
        }
        
        let sequence = SKAction.sequence([timer, storyBlock])
        run(sequence)
        
    }
    
    func showFirstLevel () {
        // Take user to the first level
        let level1 = GameScene(fileNamed: "GameScene")
        let transition = SKTransition.moveIn(with: .right, duration: 1)
        level1?.scaleMode = SKSceneScaleMode.aspectFill
        self.view?.presentScene(level1!, transition: transition)
    }
}
