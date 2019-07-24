//
//  Chapters.swift
//  TRAFOD
//
//  Created by adeiji on 7/5/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

/*
 
 The Chapters screen is where a user can select which level they want to go to.
 
 */

import SpriteKit
import GameKit

class Chapters : World {
    
    var doorway:Doorway?
    var enterInstructions:SKNode?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.physicsWorld.contactDelegate = self
        self.enterInstructions = self.childNode(withName: "enter-instructions")
        self.enterInstructions?.alpha = 0
        self.showDoorParticles()
        self.showFireFlies()
        self.showBackgroundParticles()
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if canEnterDoorway() {
            self.enterInstructions?.alpha = 1.0
            self.enterInstructions?.position.x = self.player.position.x
        } else {
            self.enterInstructions?.alpha = 0.0
        }
        
        self.moveCamera()
    }
    
    func canEnterDoorway () -> Bool {
        if let bodies = self.player.physicsBody?.allContactedBodies() {
            for body in bodies {
                if let node = body.node as? Doorway {
                    self.doorway = node
                    return true
                }
            }
        }
        
        self.doorway = nil
        return false
    }
    
    override func touchDown(atPoint pos: CGPoint) {
        if let doorway = self.doorway {
            if let jumpButton = self.jumpButton {
                if self.nodes(at: pos).contains(jumpButton) {
                    // Goto level
                    switch doorway.name
                    {
                    case "door-chapter1":
                        // show level 1
                        self.loadAndGotoNextLevel(sceneName: GameLevels.Level1, level: GameLevels.Level1)
                        return
                    case "door-chapter2":
                        self.loadAndGotoNextLevel(sceneName: GameLevels.Level2, level: GameLevels.Level1)
                        return
                    case "door-chapter3":
                        self.loadAndGotoNextLevel(sceneName: GameLevels.Level3, level: GameLevels.Level1)
                        return
                    case "door-chapter4":
                        self.loadAndGotoNextLevel(sceneName: GameLevels.Level4, level: GameLevels.Level4)
                        return
                    default: break
                    }
                }
            } else {
                super.touchDown(atPoint: pos)
            }
        } else {
            super.touchDown(atPoint: pos)
        }
    }
    

    
    override func getMineralCounts () {
        if let mineralCounts = ProgressTracker.getMineralCounts() {
            for mineralCount in mineralCounts {
                if mineralCount.mineral == Minerals.ANTIGRAV.rawValue {
                    self.player.mineralCounts[.ANTIGRAV] = mineralCount.count
                } else if mineralCount.mineral == Minerals.IMPULSE.rawValue {
                    self.player.mineralCounts[.IMPULSE] = mineralCount.count
                } else if mineralCount.mineral == Minerals.TELEPORT.rawValue {
                    self.player.mineralCounts[.TELEPORT] = mineralCount.count
                }
            }
        }
    }
}
