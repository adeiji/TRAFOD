//
//  Player.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/8/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class Player : SKSpriteNode {
    
    public var hasAntigrav = false
    public var hasImpulse = false
    public var hasTeleport = false
    public var mineralCounts = [Minerals:Int]()
    public var strength:CGFloat = 10.0
    public var grabbedObject:SKSpriteNode?
    public var objectThatCanBeGrabbed:SKSpriteNode?
    
    public var state:PlayerState = .ONGROUND
    public var runningState:PlayerRunningState = .STANDING
    public var previousRunningState:PlayerRunningState = .STANDING
    public var action:PlayerAction = .NONE
    private var isFlipped = false
    
    func getIsFlipped () -> Bool {
        return isFlipped
    }
    
    func grabObject (object: SKSpriteNode) {
        self.grabbedObject = object
    }
    
    func hasLanded (contact: SKPhysicsContact) -> Bool {
        if (self.isFlipped == false && self.position.y - contact.contactPoint.y >= (self.size.height / 2.0) - 10) || (self.isFlipped && self.position.y - contact.contactPoint.y <= (self.size.height / 2.0) + 10) {
            return true
        }
        
        return false
    }
    
    func setupPhysicsBody () {
        self.previousRunningState = .RUNNINGRIGHT
        self.position = CGPoint(x: 116, y: 86.7)
        self.name = "dawud"
        self.xScale = 1
        self.yScale = 0.90
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: self.size.height))
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.restitution = 0
        self.physicsBody?.mass = 1
        self.physicsBody?.isDynamic = true
        self.physicsBody?.contactTestBitMask = 1 | UInt32(PhysicsCategory.InteractableObjects) | UInt32(PhysicsCategory.NonInteractableObjects) | UInt32(PhysicsCategory.Minerals) | UInt32(PhysicsCategory.GetMineralObject) | UInt32(PhysicsCategory.Doorway) | UInt32(PhysicsCategory.Portals) | UInt32(PhysicsCategory.Fire)
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.InteractableObjects) | UInt32(PhysicsCategory.CannonBall) | UInt32(PhysicsCategory.Rock) | UInt32(PhysicsCategory.Ground)
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Player)
    }
    
    /**
     
     Changes the direction that the player is facing
     
     - Parameters:
     - differenceInXPos: This is the distance that the user has dragged his finger along the screen.  We use this to determine whether we should worry about actually detecting this drag as intentional and worry about changing the players direction
     
     */
    func changeDirection (differenceInXPos: CGFloat) {
        if abs(differenceInXPos) > 10 {
            if differenceInXPos < 0 {
                if self.previousRunningState == .RUNNINGLEFT {
                    self.xScale = self.xScale * -1
                }
                self.runningState = .RUNNINGRIGHT
                self.previousRunningState = .RUNNINGRIGHT
            } else {
                if self.previousRunningState == .RUNNINGRIGHT {
                    self.xScale = self.xScale * -1
                }
                self.runningState = .RUNNINGLEFT
                self.previousRunningState = .RUNNINGLEFT
            }
        } else {
            self.runningState = .STANDING
        }
    }
    
    /**
     Handles the actual flipping of the player by creating an action in which he is flipped
     
     - Parameters:
     - byAngle: The angle in which to rotate the player
     - duration: The time it should take for the action of flipping the player
     
     Note: Keep in mind that if the angle in which to rotate the player is not divisible by Pi he will not be standing erect which can cause major problems with the physics of the player and his interactions with other objects in the game
     
     */
    private func flipPlayer (byAngle: Double, duration: TimeInterval) {
        self.previousRunningState = self.previousRunningState == .RUNNINGLEFT ? .RUNNINGRIGHT : .RUNNINGLEFT
        let flipPlayerAction = SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 0.01)
        self.removeAllActions()
        self.run(flipPlayerAction)
    }
    
    public func flipPlayerUpright () {
        if self.isFlipped {
            self.flipPlayer(byAngle: -Double.pi, duration: 0.5)
            self.isFlipped = false
        }
    }
    
    /**
     
     Flips the player upside down or to his original position.
     
     - Parameters:
     - flipUpsideDown: A boolean value indicating whether the player should be flipped upside down (true), or if he should be flipped back to his original position (false)
     */
    public func flipPlayer (flipUpsideDown: Bool) {
        if flipUpsideDown && !self.isFlipped {
            self.flipPlayer(byAngle: Double.pi, duration: 0.5)
            self.isFlipped = true
        } else if flipUpsideDown == false && self.isFlipped {
            self.flipPlayer(byAngle:-Double.pi , duration: 0.5)
            self.isFlipped = false
        }
    }
    
    /**
     
     The player is able to pick up objects.  If the player has an object that he has picked up, than this is where we let go of that object.  If this method is called and the player is not holding an object, nothing will happen.
     
     */
    func letGoOfObject () {
        self.grabbedObject = nil
        self.state = .ONGROUND
        self.constraints = [];        
    }
    
    /**
     Check to see if the player is currently holding/grabbing an object
     
     - Returns:
     Whether or not the player is currently holding (true) an object or not (false)
     */
    func isGrabbingObject () -> Bool {
        if self.grabbedObject == nil {
            return false
        }
        
        return true
     }
    
    /**
     Stops the players velocity
     */
    func stop () {
        self.physicsBody?.velocity = CGVector(dx: 0, dy: self.physicsBody?.velocity.dy ?? 0)
    }
}
