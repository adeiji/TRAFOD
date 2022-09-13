//
//  DawudsVillageAnimationHandler.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/13/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class DawudsVillageAnimationHandler {

    var rockFragment:RockFragment
    var scene:World?
    private (set) var playerPaused:Bool = false
    
    let destroyerMineralStartingPosition = CGPoint(x: 16134.198, y: 2670)
    
    var player:Player? = nil
    
    enum Animations {
        case DestroyerMineralFlyIn
    }
    
    var animations:[Animations:Bool] = [:]
    
    init () {
        let rockFragment = RockFragment(size: CGSize(width: 400, height: 857))
        rockFragment.position = CGPoint(x: 14076.194, y: 2606.241)
        
        self.rockFragment = rockFragment
        self.rockFragment.color = UIColor.blue
    }
    
    func setup (scene: World, player: Player) {
        self.scene = scene
        self.scene?.addChild(rockFragment)
        self.player = player
    }
    
    func checkForAnimations (playerXPos: CGFloat?, playerYPos: CGFloat?) {
        if let xPos = playerXPos, xPos > 15510 {
            if self.animations[Animations.DestroyerMineralFlyIn] == nil {
                self.animations[Animations.DestroyerMineralFlyIn] = true
                self.showDestroyMineralFlyIn()
            }
        }
    }
    
    private func pausePlayer () {
        self.playerPaused = true
    }
    
    private func resumePlayer () {
        self.playerPaused = false
    }
    
    private func showDestroyMineralFlyIn () {
        guard let player = self.player else { return }
        self.pausePlayer()
        self.scene?.backgroundMusic.run(SKAction.stop())
                        
        let warningHorns = SKAction.playSoundFileNamed(Sounds.WARNINGHORNS.rawValue, waitForCompletion: false)
        self.scene?.run(warningHorns)
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
            self.scene?.showSpeech(message: "That's the horn for a \(StoryFeatures.Rhidahreuset) raid!!", relativeToNode: player)
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
                self.scene?.stopShowingSpeech()
                self.showDestroyMineralThrown()
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { timer in
            self.scene?.showSpeech(message: "Oh no! I have to get back to my family!!", relativeToNode: player)
            let fightishFastMusic = SKAudioNode(fileNamed: Music.FAST_FIGHTISH_MUSIC.rawValue)
            self.scene?.backgroundMusic = fightishFastMusic
            self.scene?.ambiance.run(SKAction.stop())
            
//            self.scene?.addChild(fightishFastMusic)
            
            self.resumePlayer()
        }
    }
    
    private func showDestroyMineralThrown () {
        let mineral = DestroyerMineral()
        mineral.position = self.destroyerMineralStartingPosition
        mineral.physicsBody?.affectedByGravity = false
        mineral.zPosition = 300
        self.scene?.addChild(mineral)
        mineral.physicsBody?.applyImpulse(CGVector(dx: -100.0, dy: -2.0))
    }
    
}

