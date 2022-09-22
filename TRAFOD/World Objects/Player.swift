//
//  Player.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/8/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class Player : SKSpriteNode, AffectedByNegationField {
    
    public var hasAntigrav = false
    public var hasImpulse = false
    public var hasTeleport = false
    
    private enum Dimensions: CGFloat {
        case playerStandingWidth = 70
        case playerActiveWidth = 100
        case playerHeight = 140
    }
    
    /**
     The amount of minerals the user has for each mineral type, ie.
     Impulse: 5
     AntiGrav: 10
     */
    public var mineralCounts = [Minerals:Int]()
    /**
     The physics strength of this player.  Used when calculating whether the user can push or pick up an item
     */
    public var strength:CGFloat = 10.0
    /**
     The object that the user is currently grabbing
     */
    public var grabbedObject:SKSpriteNode?
    
    /**
     The object that a player can currently grab but is not currently grabbing at the moment
     */
    public var objectThatCanBeGrabbed:SKSpriteNode?
    
    /**
     The current state of the player.  Is he DEAD, is he ONGROUND, is he in the AIR, etc.
     */
    public var state:PlayerState = .ONGROUND {
        didSet {
            if self.state != .CLIMBING {
                self.climbingState = nil
                
                if self.state != .ONGROUND {
                    self.updatePlayerDimensions(isActive: true)
                } else {
                    self.updatePlayerDimensions(isActive: false)
                }
            }
        }
    }
    
    /**
     Is the player currently runningleft, runningright, or standing etc.
     */
    public var runningState:PlayerRunningState = .STANDING {
        didSet {
            if self.runningState != .STANDING {
                self.updatePlayerDimensions(isActive: true)
            } else if (self.runningState == .STANDING && self.state == .ONGROUND) {
                self.updatePlayerDimensions(isActive: false)
            }
        }
    }
    /**
     What was the player just doing.  We're they just standing, we're they just running left
     */
    public var previousRunningState:PlayerRunningState = .STANDING
    /**
     The action that the player is currently partaking in
     */
    public var action:PlayerAction = .NONE
    
    public var climbingState:PlayerClimbingState? = .STILL
    
    /** This indicates whether the player is flipped upside down. */
    private var isFlipped = false
    
    /**
     Negated forces are any forces that can not be applied to a character.  Typically this is because the user is in a field that does not allow them to be affected by that force, ie. Negated Flip Grav Field
     */
    public var negatedForces:[Minerals:Bool] = [Minerals:Bool]()
    
    private var slidingPurchased = false
    
    /** If the player is currently in contact with a rope, then this is the point at which the player and the rope have made contact */
    private var ropeContactPoint:CGPoint?
    
    /** All the current states that the player is currently in. For example, RUNNING, CLIMBING, PULLINGROPE*/
    private var playerStates:[PlayerState] = []
    
    /**
     All the anchors that are tying the Player to another physics body.
        Key: Name of the anchor, for example, Ground. Use a value from PhysicsObjectTitles struct
        Value: The joint itself
     */
    private (set) var anchors:[String:SKPhysicsJoint] = [:]
    
    /** Whether or not the player has died*/
    private (set) var dead:Bool = false
    
    /** Call when the player has died */
    public func died () {
        self.dead = true
    }
    
    /** Call this after reviving the player */
    public func revive () {
        self.dead = false
    }
    
    // TODO: - Use player inages that are all the same size
    /**
     Update the dimensions of the player
     
        - Parameters
            - isActive: Whether the player is actively doing something, think running, or jumping, or climbing
             
     */
    private func updatePlayerDimensions (isActive active:Bool) {
        if active {
            self.size.width = Dimensions.playerActiveWidth.rawValue
            self.size.height = Dimensions.playerHeight.rawValue
        } else {
            self.size.width = Dimensions.playerStandingWidth.rawValue
            self.size.height = Dimensions.playerHeight.rawValue
        }
    }
    
    func setRopeContactPoint (_ contactPoint: CGPoint?) {
        self.ropeContactPoint = contactPoint
    }
        
    /** Returns whether or not the player is currently flipped upside down. */
    func getIsFlipped () -> Bool {
        return isFlipped
    }
    
    func grabObject (object: SKSpriteNode) {
        self.grabbedObject = object
    }
    
    func getMineralCount (mineralType: Minerals) -> Int {
        return self.mineralCounts[mineralType] ?? 0
    }
        
    func hasLanded (contact: SKPhysicsContact) -> Bool {
        if self.isFlipped == false {
            if contact.contactPoint.y <= self.frame.minY + 20 {
                return true
            }
        } else { // player is flipped or self.isFlipped == true
            if contact.contactPoint.y >= self.frame.minY - 20 {
                return true
            }
        }
        return false
    }
    
    func slidOnWall () {
        self.state = .SLIDINGONWALL
    }
    
    func isSlidingOnWall (contact: SKPhysicsContact) -> Bool {
        
        if self.slidingPurchased == false { return false }
        
        if self.state == .INAIR {
            if self.xScale > 0 { // If the player is facing right
                if contact.contactNormal.dx <= -0.999 && contact.contactNormal.dx >= -1.0 {
                    return true
                }
            } else {
                if contact.contactNormal.dx >= 0.999 && contact.contactNormal.dx <= 1.0 {
                    return true
                }
            }
        }
        
        return false
    }
    
    func setupPhysicsBody () {
        self.previousRunningState = .RUNNINGRIGHT
        self.position = CGPoint(x: 116, y: 86.7)
        self.size.width = Dimensions.playerStandingWidth.rawValue
        self.size.height = Dimensions.playerHeight.rawValue
        self.name = "dawud"
        self.xScale = 1
        self.yScale = 0.90
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: self.size.height))
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.restitution = 0
        self.physicsBody?.mass = 1
        self.physicsBody?.friction = 0.2
        self.physicsBody?.isDynamic = true
        self.physicsBody?.contactTestBitMask = 1 |
            UInt32(PhysicsCategory.Fence) |
            UInt32(PhysicsCategory.Minerals) |
            UInt32(PhysicsCategory.GetMineralObject) |
            UInt32(PhysicsCategory.Doorway) |
            UInt32(PhysicsCategory.Portals) |
            UInt32(PhysicsCategory.Fire) |
            UInt32(PhysicsCategory.FlipGravity) |
            UInt32(PhysicsCategory.NegateForceField) |
            UInt32(PhysicsCategory.Impulse) |
            UInt32(PhysicsCategory.ForceField) |
            UInt32(PhysicsCategory.Spring) |
            UInt32(PhysicsCategory.FlipSwitch)
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.CannonBall) |
            UInt32(PhysicsCategory.Rock) |
            UInt32(PhysicsCategory.Ground) |
            UInt32(PhysicsCategory.Cannon)
        
        self.physicsBody?.fieldBitMask = UInt32(PhysicsCategory.Magnetic)
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Player)
    }
    
    func stopGrabbingObject () {
        self.letGoOfObject()
    }
    
    /**
     Move a grabbed object
     
     - Parameters:
        - gravity: The constant for gravity of the physics world
     */
    func moveGrabbedObject (gravity: CGVector) {
        self.physicsBody?.velocity.dy = 0
        
        if let object = self.grabbedObject, let physicsBody = object.physicsBody {
            if physicsBody.velocity.dy < -100 {
                self.stopGrabbingObject()
                return
            }
                        
            if let bufferSize = self.getBufferSizeForContactedObjects(first: self, second: object) {
                if let distance = self.distanceToNode(node: object) {
                    if distance - bufferSize > 50 {
                        self.stopGrabbingObject()
                        return
                    }
                }
            }
            
            let gravityDifference = (gravity.dy / -9.8)
            
            if abs(physicsBody.mass * gravity.dy) <= self.strength * 160.81 {
                if self.runningState == .RUNNINGRIGHT {
                    object.physicsBody?.applyImpulse(CGVector(dx: (PhysicsHandler.kGrabbedObjectMoveVelocity * PhysicsHandler.kGrabbedObjectVelocityMultiplier) / ((object.physicsBody!.mass / 3.0) * gravityDifference), dy: 0))
                } else if self.runningState == .RUNNINGLEFT {
                    object.physicsBody?.applyImpulse(CGVector(dx: (-PhysicsHandler.kGrabbedObjectMoveVelocity * PhysicsHandler.kGrabbedObjectVelocityMultiplier) / ((object.physicsBody!.mass / 3.0) * gravityDifference), dy: 0))
                } else if self.runningState == .STANDING {
                    if let physicsBody = object.physicsBody {
                        object.physicsBody?.velocity = CGVector(dx: 0, dy: physicsBody.velocity.dy)
                    }
                }
            } else {
              // TODO: Need to add functionality for when the object is too heavy
            }
        }
    }
    
    /** Returns whether or not the user can grab an object. */
    func canGrabObject () -> Bool {
        if self.isGrabbingObject() {
            return false
        }
        
        return self.objectThatCanBeGrabbed == nil ? false : true
    }
    
    /**
     The player grabs an object if possible
     */
    func grabObject () {
        self.state = .GRABBING
        self.runningState = .STANDING
        self.grabbedObject = self.objectThatCanBeGrabbed
        if let grabbedObject = self.grabbedObject {
            /**
             TODO:
             Need to create a joint instead of a constraint between the grabbed object and Dawud?
             */
            let constraint = SKConstraint.distance(SKRange(upperLimit: self.getBufferSizeForContactedObjects(first: grabbedObject, second: self) ?? 25.0), to: grabbedObject)
            self.constraints = [constraint]
        }
    }
    
    private func getBufferSizeForContactedObjects (first: SKSpriteNode, second: SKSpriteNode) -> CGFloat? {
        return first.size.width / 2.0 + second.size.width / 2.0
    }
    
    func showJumpParticles () {
        guard let emitter = SKEmitterNode(fileNamed: ParticleFiles.PlayerTrailingColor.rawValue) else {
            return
        }
        
        // Place the emitter at the rear of the ship.
        emitter.position = CGPoint(x: 0, y: -40)
        emitter.name = "exhaust"
        
        // Send the particles to the scene.
        emitter.targetNode = self.scene;
        self.addChild(emitter)
    }
    
    //  TODO: - Move the jump function to the player object
    /**
     
     Adds an impulse to the character to cuase him to jump and shows him as jumping
      
     */
    func jump() {
        self.letGoOfRope()
        var dx:CGFloat = 0
        if self.state == .SLIDINGONWALL {
            dx = self.xScale > 0 ? -150 : 150
        }
        
        let dy = self.getIsFlipped() ?  -PhysicsHandler.kJumpImpulse : PhysicsHandler.kJumpImpulse
        
        self.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
        self.texture = SKTexture(imageNamed: "running_step2")
        self.state = .INAIR
    }
    
    /** Launch the spring by  */
    private func letGoOfRope () {
        self.letGoOfObject()
        if let spring = self.anchors[PhysicsObjectTitles.RopeType] {
            self.scene?.physicsWorld.remove(spring)
            self.anchors[PhysicsObjectTitles.RopeType] = nil
        }        
    }
    
    /**
        Handles the grabbing and releasing of a rope
     */
    func handleRopeGrabInteraction () {
        
        // Player is already grabbing a rope
        if (self.anchors[PhysicsObjectTitles.RopeType] != nil ) {
            self.letGoOfRope()
            return
        }
        
        // Should be set whenever the player has made contact with a rope
        guard let contactPoint = self.ropeContactPoint else { return }
        guard let playerPhysicsBody = self.physicsBody else { return }
        let touchedSpringSegmentPhysicsBody = self.physicsBody?.allContactedBodies().filter({ $0.node is RopeTypeSegment  }).first
        
        if let touchedSpringSegmentPhysicsBody = touchedSpringSegmentPhysicsBody {
            // Add a joint between the player and the vine segment the player has made contact with
            let joint = SKPhysicsJointPin.joint(withBodyA: playerPhysicsBody, bodyB: touchedSpringSegmentPhysicsBody, anchor: contactPoint)
            self.scene?.physicsWorld.add(joint)
            self.anchors[PhysicsObjectTitles.RopeType] = joint
            self.grabbedObject = touchedSpringSegmentPhysicsBody.node as? RopeTypeSegment
        }
    }
    
    /// Checks to see if the player is  contacted with FlipGravity and update the player's rotation
    func handleIsContactedWithFlipGravity () {
        guard let physicsBody = self.physicsBody else { return }
        
        for body in physicsBody.allContactedBodies() {
            if body.node is FlipGravity && self.negatedForces[.FLIPGRAVITY] == nil {
                self.flipPlayer(flipUpsideDown: true)
                return
            }
        }
        
        self.flipPlayerUpright()
    }
    
    /**
     
     Changes the direction that the player is facing
     
     - Parameters:
     - differenceInXPos: This is the distance that the user has dragged his finger along the screen.  We use this to determine whether we should worry about actually detecting this drag as intentional and worry about changing the players direction
     
     */
    func updatePlayerRunningState (differenceInXPos: CGFloat) {
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
    
    func move (dx: CGFloat, dy: CGFloat) {
        if abs(dx) > PhysicsHandler.kRunVelocity {
            assertionFailure("The player should not be allowed to move faster then the maximum velocity of \(PhysicsHandler.kRunVelocity)")
        }
        
        self.physicsBody?.velocity = CGVector(dx: dx, dy: dy)
    }
    
    // # MARK: Climbing
    
    func startClimbing () {
        self.state = .CLIMBING
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
    }
    
    func stoppedClimbing () {        
        self.physicsBody?.affectedByGravity = true
    }
    
    func updatePlayerClimbingState (differenceInXPos: CGFloat, differenceInYPos: CGFloat) {
                
        // If the differentiation of the xPos is greater, meaning that the user is trying to move left or right
        if (abs(differenceInXPos) > abs(differenceInYPos)) {
            if differenceInXPos < 0 {
                self.climbingState = .CLIMBINGRIGHT
            } else {
                self.climbingState = .CLIMBINGLEFT
            }
            
            return
        } else if (abs(differenceInXPos) < abs(differenceInYPos)) { // If the differentiation of the yPos is greater, meaning that the user is trying to move up or down
            if differenceInYPos < 0 {
                self.climbingState = .CLIMBINGUP
            } else {
                self.climbingState = .CLIMBINGDOWN
            }
            
            return
        } else {
            self.climbingState = .STILL
        }
    }
    
    /** Returns whether or not the user is currently grabbing a rope */
    private func isGrabbingRope () -> Bool {
        
        // If the player is currently anchored to a rope object then that means that he/she is grabbing a rope
        if (self.anchors[PhysicsObjectTitles.RopeType] != nil) {
            return true
        }
        
        return false
    }
    
    func canJump () -> Bool {
        if self.isGrabbingRope() {
            return true
        }
        if self.state == .ONGROUND || self.state == .SLIDINGONWALL {
            return true
        }
        
        return false
    }
    
    /**
     Responsible for showing the movement of the character when he is climbing
     */
    func handleClimbingMovement () {
        guard let climbingState = self.climbingState else { return }
        
        switch climbingState {
        case .CLIMBINGDOWN:
            self.move(dx: 0, dy: -400)
            break;
        case .CLIMBINGLEFT:
            self.move(dx: -400, dy: 0)
            break;
        case .CLIMBINGRIGHT:
            self.move(dx: 400, dy: 0)
            break;
        case .CLIMBINGUP:
            self.move(dx: 0, dy: 400)
            break;
        case .STILL:
            self.stop()
            break;
        }
    }
    
    /**
     Whether or not the player is currently climbing something like a fence
     */
    func isClimbing () -> Bool {
        return self.state == .CLIMBING
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
     Stops the players velocity and shows the player as standing
     */
    func stop () {
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.runningState = .STANDING
    }
    
    func handleMineralUsed (mineralType: Minerals) {
        if let mineralCount = self.mineralCounts[mineralType] {
            let updatedMineralCount = mineralCount - 1
            self.mineralCounts[mineralType] = updatedMineralCount
            ProgressTracker.updateMineralCount(myMineral: mineralType, count: updatedMineralCount)
        }
    }        
    
    func isInContactWithFence () -> Bool {
        if self.physicsBody?.allContactedBodies().filter({ $0.node is Fence }).count == 0 {
            return false
        }
        
        return true
    }
    
    func madeContactWithFence (contact: SKPhysicsContact) -> Bool {
        if let _ = contact.bodyA.node as? Fence ?? contact.bodyB.node as? Fence {
            return true
        }
        
        return false
    }
    
    /**
     This method is called when the player is running.  If the player is in the air, then we don't want the player to move as freely as when he's on the ground obviously.
     */
    func handlePlayerMovement () {
        guard let dx = self.physicsBody?.velocity.dx else { return }
        let multiplier:CGFloat = self.runningState == .RUNNINGLEFT ? 1 : -1
        
        switch self.state {
        case .ONGROUND:
            self.physicsBody?.velocity = CGVector(dx: -PhysicsHandler.kRunVelocity * multiplier, dy: self.physicsBody?.velocity.dy ?? 0)
        case .INAIR:
            if self.runningState == .RUNNINGLEFT {
                if dx > -PhysicsHandler.kRunVelocity {
                    self.physicsBody?.applyImpulse(CGVector(dx: -PhysicsHandler.kRunInAirImpulse * multiplier, dy: 0))
                }
            } else {
                if dx < PhysicsHandler.kRunVelocity {
                    self.physicsBody?.applyImpulse(CGVector(dx: -PhysicsHandler.kRunInAirImpulse * multiplier, dy: 0))
                }
            }
        case .SLIDINGONWALL:
            if self.runningState != .STANDING {
                self.physicsBody?.applyImpulse(CGVector(dx: -PhysicsHandler.kRunInAirImpulse * 2.0 * multiplier, dy: 0))
            }
        default:
            break;
        }
    }
    
    func update() {
        guard let velocity = self.physicsBody?.velocity else { return }
        
        // if the player is moving upwards
        if (velocity.dy > 0.5) {
            self.showJumpParticles()
        }
    }
}
