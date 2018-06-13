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
    
    private var cameraPositions = [CGPoint(x: 0, y: 0), CGPoint(x: 660, y: 0),]
    
    override func didMove(to view: SKView) {
        let camera = self.childNode(withName: "camera")
        let action = SKAction.moveBy(x: 7040, y: 0, duration: 30.0)
        
        camera?.run(action, completion: {
            // Take user to the first level
            let level1 = GameScene(fileNamed: "GameScene")
            let transition = SKTransition.moveIn(with: .right, duration: 1)
            level1?.scaleMode = SKSceneScaleMode.aspectFill
            self.view?.presentScene(level1!, transition: transition)
            
        })
        
        if let musicURL = Bundle.main.url(forResource: "Introduction Music_Master", withExtension: "wav") {
            let backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
    }
    
    func playStory (cameraPosition: CGPoint) {
        
    }
}
