//
//  Loading.swift
//  TRAFOD
//
//  Created by adeiji on 6/15/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import SpriteKit
import GameKit

class Loading : World {
    var nextSceneName:String?
    var nextScene:World?
    var keepRunning = false
    var shouldLoadNextScene = false
    var loadingCrystal:SKNode!
            
    override func didMove(to view: SKView) {
        self.showDoorParticles()
        self.setupPlayer()
        self.loadingCrystal = self.childNode(withName: "getAntiGrav")
        self.showMineralParticles()
        self.showFireFlies()
        self.showBackgroundParticles()
        self.addChild(self.player)
    }
    
    override func setupPlayer () {
        // If we don't set the player before hand than that means that this is a new game
        if self.player == nil {
            self.createPlayer()
        }
        
        self.player.xScale = 1
        self.player.position.x = (self.scene!.size.width / -2.0) + 20
        self.player.position.y = (self.scene!.size.height / -2.0) + 20
        self.player.anchorPoint = CGPoint(x: 0.5, y: 0)
        self.player.runningState = .RUNNINGRIGHT        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // DO NOTHING
    }
    
    override func touchDown(atPoint pos: CGPoint) {
        // DO NOTHING
    }
    
    override func touchUp(atPoint pos: CGPoint) {
        // DO NOTHING
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if self.lastUpdateTime == 0 {
            self.lastUpdateTime = currentTime
        }
        
        let dt = currentTime - self.lastUpdateTime
        
        // Show the loading crystal rotating in the middle of the screen
        if dt > 0 {
            self.loadingCrystal.zRotation = self.loadingCrystal.zRotation + CGFloat(Double.pi / (-Double(dt * 1000)))
        }
        
        if self.shouldLoadNextScene == true {
            self.loadNextScene()
            self.shouldLoadNextScene = false
        }
        
        if self.player.position.x >= (self.scene!.size.width / 2.0) {
            if let nextScene = self.nextScene {
                let transition = SKTransition.moveIn(with: .right, duration: 0)
                nextScene.scaleMode = SKSceneScaleMode.aspectFit
                self.player.removeFromParent()
                nextScene.player = self.player                
                nextScene.collectedElements = self.collectedElements                
                self.view?.presentScene(nextScene, transition: transition)
            }
        } else if self.player.position.x >= 0 && self.keepRunning == false {
            self.player.runningState = .STANDING
            self.shouldLoadNextScene = true
            self.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            self.keepRunning = true
        }
        
        self.lastUpdateTime = currentTime
    }
    
    func loadNextScene () {
        DispatchQueue.global().async {
            if let sceneName = self.nextSceneName {
                let nextScene = World(fileNamed: sceneName)
                DispatchQueue.main.async {
                    self.nextScene = nextScene
                    self.player.runningState = .RUNNINGRIGHT
                }
            }
        }
        
    }
}
