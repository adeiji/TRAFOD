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
    var bookChapter:Chapter?
    var keepRunning = false
    var shouldLoadNextScene = true
    var loadingCrystal:SKNode!
            
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.loadingCrystal = self.childNode(withName: "getAntiGrav")
        self.loadNextScene()
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
    
    private func rotateLoadingCrystal (dt: TimeInterval) {
        // Show the loading crystal rotating in the middle of the screen
        if dt > 0 {
            self.loadingCrystal.zRotation = self.loadingCrystal.zRotation + CGFloat(Double.pi / (-Double(dt * 1000)))
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        self.player.runningState = .RUNNINGRIGHT
        
        if self.lastUpdateTime == 0 {
            self.lastUpdateTime = currentTime
        }
        
        let dt = currentTime - self.lastUpdateTime
        self.rotateLoadingCrystal(dt: dt)
        
        if self.player.position.x >= (self.scene!.size.width / 2.0) {
            self.showNextScene()
        } else if self.player.position.x >= 0 && self.keepRunning == false {
            self.playerRunRight()
        }
        
        self.lastUpdateTime = currentTime
    }
    
    private func playerRunRight () {
        self.player.runningState = .STANDING
        self.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.keepRunning = true
    }
    
    private func showNextScene () {
        if let nextScene = self.nextScene {
            let transition = SKTransition.moveIn(with: .right, duration: 0)
            nextScene.scaleMode = SKSceneScaleMode.aspectFit
            self.player.runningState = .STANDING
            self.player.removeFromParent()
            nextScene.player = self.player
            nextScene.collectedElements = self.collectedElements
            
            self.view?.presentScene(nextScene, transition: transition)
        }
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
