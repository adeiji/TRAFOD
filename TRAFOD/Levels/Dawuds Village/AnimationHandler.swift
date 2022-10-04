//
//  DawudsVillageAnimationHandler.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/13/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import UIKit

class AnimationHandler {
    
    private (set) var playerPaused = false
    let animations:[AnimationHandlerProtocol]
    
    init(animations: [AnimationHandlerProtocol]) {
        self.animations = animations
        for animation in animations {
            animation.animationHandler = self
        }
    }
    
    func checkForAnimations (playerXPos: CGFloat?, playerYPos: CGFloat?) {        
        for animation in self.animations {
            animation.checkForAnimations(playerXPos: playerXPos, playerYPos: playerYPos)
        }
    }
    
    func pausePlayer () {
        self.playerPaused = true
    }
    
    func resumePlayer () {
        self.playerPaused = false
    }
}
