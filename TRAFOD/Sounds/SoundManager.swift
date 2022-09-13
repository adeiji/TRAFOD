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

enum Music: String, CustomStringConvertible {
    case FAST_FIGHTISH_MUSIC = "Dawud's_Village_Under_Attack"
    
    var description: String {
        return self.rawValue
    }
}

enum Sounds: String {
    case MINERALCRASH
    case ANTIGRAV
    case JUMP
    case RUN = "FootstepsKey"
    case LANDED
    case CANNONBLAST
    case GRABMINERAL = "mineralgrab"
    case WARNINGHORNS = "Warning_Horn_Sound"
}

class SoundManager {
    
    let mineralCrashSound = SKAction.playSoundFileNamed("mineralcrash", waitForCompletion: false)
    let antiGravSound = SKAudioNode(fileNamed: "antigrav")
    let stepsSound = SKAudioNode(fileNamed: "footsteps")
    let hitGround = SKAction.playSoundFileNamed("hitground", waitForCompletion: true)    
    var isMuted = false;
    let world:World
    
    init(world:World) {
        self.world = world        
    }
    
    func stopSoundWithKey (key: String) {
        if self.isMuted {
            return
        }
        if key == Sounds.RUN.rawValue {
            self.stepsSound.run(SKAction.changeVolume(to: 0, duration: 0))
        } else {
            self.world.removeAction(forKey: key)
        }
    }
    
    func playSound (sound: Sounds, parent: SKNode? = nil) {
        if self.isMuted {
            return
        }
        
         
        if sound == .MINERALCRASH {
            self.world.run(self.mineralCrashSound)        
        } else if sound == .ANTIGRAV {
            self.antiGravSound.run(SKAction.changeVolume(to: 0.5, duration: 0))
            self.antiGravSound.run(SKAction.changeVolume(to: 0, duration: 5.0))            
            if self.antiGravSound.parent == nil {
                self.world.addChild(self.antiGravSound)
            }
        } else if sound == .RUN {
            self.stepsSound.run(SKAction.changeVolume(to: 0.4, duration: 0))
            if self.stepsSound.parent == nil {
                self.world.addChild(self.stepsSound)
            }
        } else if sound == .LANDED {
            self.world.run(self.hitGround)
        } else {
            let audioNode = SKAudioNode(fileNamed: sound.rawValue)
            audioNode.autoplayLooped = false
            self.world.addChild(audioNode)
            
        }
    }
}
