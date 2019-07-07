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
        self.showDoorParticles()        
        if let start = self.childNode(withName: "start") {
            self.player.position = start.position
        }
        
        self.showCityFire()
        
        if let node = self.childNode(withName: "Page1Text") {
            let fade = SKAction.fadeAlpha(to: 1.0, duration: 2.0)
            node.run(fade)
        }
        
        if let musicURL = Bundle.main.url(forResource: "story", withExtension: "wav") {
            self.backgroundMusic = SKAudioNode(url: musicURL)
            addChild(self.backgroundMusic)
        }
    }
    
    func showCityFire () {
        if let backgroundParticlesPath = Bundle.main.path(forResource: "Fire", ofType: "sks") {
            if let backgroundParticles = NSKeyedUnarchiver.unarchiveObject(withFile: backgroundParticlesPath) as? SKEmitterNode {
                backgroundParticles.particlePositionRange.dx = self.scene!.size.width                
                backgroundParticles.zPosition = -35
                backgroundParticles.position = CGPoint(x: 0, y: (self.scene!.size.height / -2.0) + 10)
                self.camera?.addChild(backgroundParticles)
            }
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
    
    override func moveCamera() {
        if self.player.position.x > self.camera!.position.x {
            if self.minCameraX == nil {
                self.minCameraX = self.camera!.position.x
            }
        }
        
        if ((self.minCameraX != nil) && (self.player.position.x >= self.minCameraX)) && self.player.position.x < 10000 {
            self.camera?.position.x = self.player.position.x
        }
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        super.didBegin(contact)
        
        let aName = contact.bodyA.node?.name ?? ""
        let bName = contact.bodyB.node?.name ?? ""
        
        if PhysicsHandler.contactContains(strings: ["firstLevel","dawud"], contactA: aName, contactB: bName) {
            self.showFirstLevel()
        }
    }
    
    func showFirstLevel () {                
        DispatchQueue.main.async {            
            let loading = Loading(fileNamed: "Loading")
            loading?.nextSceneName = "GameScene"
            loading?.player = self.player
            self.player.removeFromParent()
            let transition = SKTransition.moveIn(with: .right, duration: 0)
            loading?.scaleMode = SKSceneScaleMode.aspectFit
            self.view?.presentScene(loading!, transition: transition)
            
        }
    }
}
