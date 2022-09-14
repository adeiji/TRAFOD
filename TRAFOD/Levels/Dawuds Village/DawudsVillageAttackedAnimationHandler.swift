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

class DawudsVillageAttackedAnimationHandler: AnimationHandlerProtocol {

    var scene:World?
    internal var animationHandler:AnimationHandler? = nil
    let destroyerMineralStartingPosition = CGPoint(x: 17229.998, y: 3650)
    let xPositionToPass:CGFloat = 17190
    
    var player:Player? = nil
    
    enum Animations {
        case DestroyerMineralFlyIn
    }
    
    var animations:[Animations:Bool] = [:]
    
    init(scene: World, player: Player) {
        self.scene = scene
        self.player = player
    }
    
    func setAnimationHandler (animationHandler: AnimationHandler?) {
        self.animationHandler = animationHandler
    }
    
    func setup (scene: World, player: Player) {
        self.scene = scene
        self.player = player
    }
    
    func checkForAnimations (playerXPos: CGFloat?, playerYPos: CGFloat?) {
        if let xPos = playerXPos, xPos > self.xPositionToPass {
            if self.animations[Animations.DestroyerMineralFlyIn] == nil {
                self.animations[Animations.DestroyerMineralFlyIn] = true
//                self.showDestroyMineralFlyIn()
            }
        }
    }
    
    private func showDestroyMineralFlyIn () {
        guard let player = self.player else { return }
        self.animationHandler?.pausePlayer()
        self.scene?.backgroundMusic?.run(SKAction.stop())
                        
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
            let fightishFastMusic = SKAudioNode(fileNamed: Music.FastFightish.rawValue)
            self.scene?.playBackgroundMusic(fileName: Music.FastFightish.rawValue)
            self.scene?.ambiance?.run(SKAction.stop())
            self.scene?.addChild(fightishFastMusic)
            
            self.animationHandler?.resumePlayer()
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

