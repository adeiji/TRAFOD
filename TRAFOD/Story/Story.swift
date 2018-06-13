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

class Story : SKScene {
    
    private var cameraPositions = [CGPoint(x: 0, y: 0),CGPoint(x: 1334, y: 0),
                                   CGPoint(x: 2512, y: 0), CGPoint(x: 3718, y: 0),
                                   CGPoint(x: 5280, y: 0), CGPoint(x: 6769, y: 0),
                                   CGPoint(x: 8123, y: 0)]
    private var fadeColor:SKSpriteNode!
    private var backgroundMusic:SKAudioNode!
    
    override func didMove(to view: SKView) {
        self.fadeColor = self.camera?.childNode(withName: "fadeColor") as! SKSpriteNode
        self.playStory()
        
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
