//
//  Level2.swift
//  TRAFOD
//
//  Created by adeiji on 6/25/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import Foundation
import GameKit
import SpriteKit

struct PhysicsCategory {
    static let InteractableObjects:Int32 = 0x1 << 3
    static let CannonBall:Int32 = 0x1 << 4
}

protocol AntiGravPlatformProtocol {
    
    var startingYPos:CGFloat! { get set }
    var verticalForce:CGFloat! { get set }
    
    func applyUpwardForce()
    
}

class FlipSwitch : SKSpriteNode {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.categoryBitMask = 0b0001
    }
}

class CannonBall : SKSpriteNode {
    
    init(cannon: Cannon) {
        super.init(texture: nil, color: .orange, size: CGSize(width: 50, height: 50))
        self.name = "cannonball"
        self.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        self.physicsBody?.mass = 15
        self.physicsBody?.collisionBitMask = 0b0010
        self.physicsBody?.contactTestBitMask = 1
        self.physicsBody?.isDynamic = true
        cannon.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class Cannon : SKSpriteNode {
    
    // The time to wait before firing again
    var timeToFire:Double = 3.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.InteractableObjects)        
    }
    
    /**
     
     Launches a cannon ball based off of the angle of the cannon continously
     
     */
    func launch () {
        let ball = CannonBall(cannon: self)
        
        let angle = self.zRotation * 180 / .pi
        let yVector = (20000 - 20000 * (1 - (abs(90 - abs(angle)) / 90)))
        let xVector = (20000 * (1 - (abs(90 - abs(angle)) / 90))) * (((90 - angle) / abs(90 - angle)) * -1)
        
        ball.physicsBody?.applyImpulse(CGVector(dx: xVector, dy: yVector))
    }
}

class Rock : SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.collisionBitMask = 0b0010
    }
}

class AntiGravPlatform : SKSpriteNode, AntiGravPlatformProtocol {
    
    // This is the yPos of where the cannon starts off at.  The cannon
    //will never go higher than this point, or lower than this point
    // depending on how gravity is handled
    var startingYPos: CGFloat!
    
    // The constant vector y force applied to the platform
    var verticalForce: CGFloat! = 2000
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.startingYPos = self.position.y
        
        let lockXPos = SKConstraint.positionX(SKRange(constantValue: 5))
        self.constraints = [lockXPos]
    }
    
    /**
    Applies an upward force to the platform.  Method is called at every game loop update
    */
    func applyUpwardForce () {
        if self.position.y < self.startingYPos - 3 {
            self.physicsBody?.applyForce(CGVector(dx: 0, dy: self.verticalForce))
        } else {
            self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        }
        
        self.physicsBody?.velocity.dx = 0
        
    }
}

class AntiGravPlatformHeavy : AntiGravPlatform {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.verticalForce = 8000
    }
    
    override func applyUpwardForce() {
        super.applyUpwardForce()
    }
}

class Level2 : World {
    
    var launchTime:TimeInterval?
    var cannons:[Cannon]?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.createPlayer()
        self.player.hasAntigrav = true
        self.player.hasImpulse = true
        
        self.addThrowButton()
        self.addThrowImpulseButton()
        
        self.physicsWorld.contactDelegate = self
        self.getCannons()
        if let start = self.childNode(withName: "start") {
            self.player.position = start.position
        }
    }
    
    func getCannons () {
        if let cannons = self.childNode(withName: "cannons") {
            self.cannons = cannons.children as? [Cannon]
        }
    }
    
    func moveCamera () {
        if let _ = self.childNode(withName: "cameraMinX") {
            self.camera?.position.x = self.player.position.x
            self.camera?.position.y = self.player.position.y
        }
        
        if let leftBoundary = self.camera?.childNode(withName: "leftBoundary"), let rightBoundary = self.camera?.childNode(withName: "rightBoundary"), let camera = self.camera {
            leftBoundary.position.y = camera.position.y
            rightBoundary.position.y = camera.position.y
        }
        
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        super.didBegin(contact)
        
        if contact.bodyA.node as? FlipSwitch != nil || contact.bodyB.node as? FlipSwitch != nil {
            if self.contactContains(strings: ["switch1", "rock"], contact: contact) {
                self.movePlatform(nodeName: "ground-nowarp-switch1")
            }
        }
    }
    
    func movePlatform(nodeName: String) {
        if let node = self.childNode(withName: nodeName) {
            node.physicsBody?.pinned = false
            node.physicsBody?.affectedByGravity = true
            let action = SKAction.wait(forDuration: 0.65)
            node.run(action) {
                node.physicsBody?.pinned = true
                node.physicsBody?.affectedByGravity = false
            }
        }
    }
    
    /**
     Launch the cannons every 3 seconds
     
     - Todo: Need to implement a way where cannons fire at different time periods and at different intervals between launch
     - Parameters:
        - currentTime - The current time of the application run loop
     */
    func launchCannons (currentTime: TimeInterval) {
        if let launchTime = self.launchTime {
            let timeSinceLaunch = currentTime - launchTime
            if timeSinceLaunch >= 3.0 {
                if let cannons = self.cannons {
                    for cannon in cannons {
                        cannon.launch()
                        self.launchTime = currentTime
                    }
                }
            }
        } else {
            self.launchTime = currentTime
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        enumerateChildNodes(withName: "ground-antigravity") { (node, pointer) in
            if let node = node as? AntiGravPlatformProtocol {
                node.applyUpwardForce()
            }
        }
        
//        self.launchCannons(currentTime: currentTime)
        self.moveCamera()
        let dt = currentTime - self.lastUpdateTime
        self.handlePlayerRotation(dt: dt)
        self.lastUpdateTime = currentTime
    }
}
