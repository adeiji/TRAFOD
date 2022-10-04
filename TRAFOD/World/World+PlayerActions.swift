//
//  World+PlayerActions.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/18/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

extension World {
    /**
     
     Checks to see if the player has fallen below the last time he was on the ground
     
     - returns: A boolean value indicating whether the player is falling
     
     */
    func playerIsFalling () -> Bool {
        
        if let point = self.startPosition {
            if self.player.position.y < point.y {
                return true
            }
        }
        
        return false
    }
    
    public func throwMineral (type: Minerals) {
        if type == .ANTIGRAV {
            
        }
    }  
    
    func rotateJumpingPlayer (rotation: Double) {
        if self.player.previousRunningState == .RUNNINGRIGHT || self.player.previousRunningState == .STANDING {
            self.player.zRotation = self.player.zRotation + CGFloat(Double.pi / rotation)
        } else if self.player.previousRunningState == .RUNNINGLEFT {
            self.player.zRotation = self.player.zRotation - CGFloat(Double.pi / rotation)
        }
    }
    
    @objc func handleJump () {
        self.sounds?.stopSoundWithKey(key: Sounds.RUN.rawValue)
        self.player.jump()
    }
    
    public func setupPlayer () {        
        self.createPlayer()
        self.player.xScale = 1
        self.player.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let start = self.childNode(withName: "start") {
            self.player.position = start.position
            self.startPosition = start.position            
        }
        
        self.player.previousRunningState = .RUNNINGRIGHT
    }
    
    func stopPlayer () {
        self.player.physicsBody?.velocity = CGVector(dx: 0, dy: self.player.physicsBody?.velocity.dy ?? 0)
    }       
    
    func handlePlayerRotation (dt: TimeInterval) {
        if self.player.state == .INAIR {
            //self.rotateJumpingPlayer(rotation: -Double(dt * 500))
        } else {
            //            self.player.zRotation = 0.0
        }
    }
    
    func handlePlayerDied () {
        if let point = self.startPosition {
            self.player.position = point
        }
        
        self.player.flipUpright()
        self.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.player.runningState = .STANDING
        self.player.state = .ONGROUND
        self.player.revive()
    }
}
