//
//  SoundManager.swift
//  TRAFOD
//
//  Created by adeiji on 6/18/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

enum Sounds: String {
    case MINERALCRASH
    case ANTIGRAV
    case JUMP
    case RUN = "FootstepsKey"
    case LANDED
}

class SoundManager {
    
    let mineralCrashSound = SKAction.playSoundFileNamed("mineralcrash", waitForCompletion: false)
    let antiGravSound = SKAudioNode(fileNamed: "antigrav")
    let stepsSound = SKAction.playSoundFileNamed("footsteps", waitForCompletion: true)
    let hitGround = SKAction.playSoundFileNamed("hitground", waitForCompletion: true)
    
    let world:World
    
    init(world:World) {
        self.world = world
        
    }
    
    func stopSoundWithKey (key: String) {
        self.world.removeAction(forKey: key)
    }
    
    func playSound (sound: Sounds) {
        if sound == .MINERALCRASH {
            self.world.run(self.mineralCrashSound)
        } else if sound == .ANTIGRAV {
            self.antiGravSound.run(SKAction.changeVolume(to: 0.5, duration: 0))
            self.antiGravSound.run(SKAction.changeVolume(to: 0, duration: 5.0))
            if self.antiGravSound.parent == nil {
                self.world.addChild(self.antiGravSound)
            }
            
        } else if sound == .RUN {
            let repeatAction = SKAction.repeatForever(self.stepsSound)
            self.world.run(repeatAction, withKey: Sounds.RUN.rawValue)
        } else if sound == .LANDED {
            self.world.run(self.hitGround)
        }
    }
}