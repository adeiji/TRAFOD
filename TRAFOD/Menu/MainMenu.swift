//
//  MainMenu.swift
//  TRAFOD
//
//  Created by adeiji on 6/11/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import SpriteKit
import GameplayKit

class MainMenu: SKScene {

    private var newGameButton:SKNode!
    
    override func didMove(to view: SKView) {
        
        self.newGameButton = self.childNode(withName: "newGameButton")
        if let musicURL = Bundle.main.url(forResource: "dawudsong", withExtension: "wav") {
            let backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
    }
    
    func touchDown (atPoint pos: CGPoint) {
        if self.nodes(at: pos).contains(self.newGameButton) {
            // Take user to the first level
            let story = Story(fileNamed: "Story")
            let transition = SKTransition.moveIn(with: .right, duration: 1)
            story?.scaleMode = SKSceneScaleMode.aspectFill
            self.view?.presentScene(story!, transition: transition)
        }
    }
    
    func touchMoved (toPoint pos: CGPoint) {
    }
    
    func touchUp (atPoint pos: CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
}
