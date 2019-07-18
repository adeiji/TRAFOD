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
        
        if let point = self.lastPointOnGround {
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
    /**
     
     Checks to see if the player is on the ground
     
     - todo: Only return true if the player is standing on the ground
     - returns: Bool If the player is on the ground or not
     
     */
    private func isGrounded () -> Bool {
        if let bodies = self.player.physicsBody?.allContactedBodies(), let groundPhysicsBody = self.ground?.physicsBody {
            if bodies.contains(groundPhysicsBody) {
                return true
            }
        }
        
        return false
    }
    
    /**
     
     Adds an impulse to the character to cuase him to jump and shows him as jumping
     
     */
    private func jump() {
        self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: self.player.getIsFlipped() ?  -PhysicsHandler.kJumpImpulse : PhysicsHandler.kJumpImpulse))
        self.player.texture = SKTexture(imageNamed: "running_step2")
        self.player.state = .INAIR
    }
    
    func rotateJumpingPlayer (rotation: Double) {
        if self.player.previousRunningState == .RUNNINGRIGHT || self.player.previousRunningState == .STANDING {
            self.player.zRotation = self.player.zRotation + CGFloat(Double.pi / rotation)
        } else if self.player.previousRunningState == .RUNNINGLEFT {
            self.player.zRotation = self.player.zRotation - CGFloat(Double.pi / rotation)
        }
    }
    
    func handleJump () {
        if self.player.state == .JUMP {
            self.sounds?.stopSoundWithKey(key: Sounds.RUN.rawValue)
            self.jump()
        }
    }
    
    public func setupPlayer () {
        if self.player == nil {
            self.createPlayer()
        }
        
        self.player.xScale = 1
        self.player.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let start = self.childNode(withName: "start") {
            self.player.position = start.position
        }
        
        self.player.previousRunningState = .RUNNINGRIGHT
    }
    
    func stopPlayer () {
        self.player.physicsBody?.velocity = CGVector(dx: 0, dy: self.player.physicsBody?.velocity.dy ?? 0)
    }
    
    func handleThrow () {
        if self.player.action == .THROW {
            if self.throwingMineral == .ANTIGRAV && self.player.hasAntigrav {
                let mineralNode = SKSpriteNode(imageNamed: "Blue Crystal")
                mineralNode.name = "mineral-gravity"
                self.showThrowMineral(mineralNode: mineralNode)
            } else if self.throwingMineral == .IMPULSE {
                let mineralNode = SKSpriteNode(imageNamed: "Red Crystal")
                mineralNode.name = "mineral-impulse"
                self.showThrowMineral(mineralNode: mineralNode)
            } else if self.throwingMineral == .TELEPORT {
                let mineralNode = SKSpriteNode(imageNamed: "Blue Crystal")
                mineralNode.name = "mineral-teleport"
                self.showThrowMineral(mineralNode: mineralNode)
            }
        }
        
        self.player.action = .NONE
    }
    
    func handlePlayerRotation (dt: TimeInterval) {
        if self.player.state == .INAIR {
            //self.rotateJumpingPlayer(rotation: -Double(dt * 500))
        } else {
            //            self.player.zRotation = 0.0
        }
    }
    
    func handlePlayerDied () {
        if let point = self.lastPointOnGround {
            self.player.position = point
        }
        
        self.player.zRotation = 0.0
        self.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.player.runningState = .STANDING
        self.player.state = .ONGROUND
    }
}
