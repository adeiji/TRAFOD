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
    static let NonInteractableObjects:Int32 = 0x1 << 5
}

protocol AntiGravPlatformProtocol {
    
    var startingYPos:CGFloat! { get set }
    var verticalForce:CGFloat! { get set }
    
    func applyUpwardForce()
    
}

class Reset: SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.categoryBitMask = 0b0001
    }
}

class FlipSwitch : SKSpriteNode {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.categoryBitMask = 0b0001
    }
}

class DoubleGravField : SKSpriteNode {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.NonInteractableObjects)
    }
    
    func gravitation (mass: CGFloat) -> CGVector {
        return CGVector(dx: 0, dy: (-9.8 * 4) * mass)
    }
}

class Cannon : SKSpriteNode {
    
    // The time to wait before firing again
    var timeToFire:Double = 3.0
    var lastTimeFired:TimeInterval!
    
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
        let differenceFrom90Degrees = abs(90 - abs(angle))
        let yVector = (20000 - 20000 * (1 - (differenceFrom90Degrees / 90)))
        let xVector = (20000 * (1 - (differenceFrom90Degrees / 90) ) ) * ( ( (90 - angle) / abs(90 - angle) ) * -1)
        
        ball.physicsBody?.applyImpulse(CGVector(dx: xVector, dy: yVector))
    }
}

class CannonBall : SKSpriteNode {
    
    init(cannon: Cannon) {
        super.init(texture: nil, color: .orange, size: CGSize(width: 50, height: 50))
        self.name = "cannonball"
        self.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        self.physicsBody?.mass = 15
        self.physicsBody?.collisionBitMask = 0b0010
        self.physicsBody?.contactTestBitMask = 1 | UInt32(PhysicsCategory.NonInteractableObjects)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.restitution = 1.0
        
        cannon.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class Rock : SKSpriteNode {
    
    var startingPos:CGPoint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.startingPos = self.position
        self.physicsBody?.collisionBitMask = 0b0010
    }
}

class MovablePlatform : SKSpriteNode {
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
    var cannonTimes:[TimeInterval] = [ 3.0, 5.0, 3.0, 5.0, 7.0 ]
    
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
        if let cannonsGroup = self.childNode(withName: "cannons") {
            if let cannons  = cannonsGroup.children as? [Cannon] {
                self.cannons = cannons
                for i in 0...(cannons.count - 1) {
                    self.cannons![i].timeToFire = self.cannonTimes[i]
                }
            }
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
    
    override func touchDown(atPoint pos: CGPoint) {
        super.touchDown(atPoint: pos)
        
        if let camera = self.camera, let zoomOut = camera.childNode(withName: "zoomOut") {
            if self.nodes(at: pos).contains(zoomOut) {
                if camera.xScale == 1 {
                    self.camera?.xScale = 2
                    self.camera?.yScale = 2
                } else if camera.xScale == 2 {
                    camera.xScale = 1
                    camera.yScale = 1
                }
            }
        }
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        super.didBegin(contact)
        
        if contact.bodyA.node as? Reset != nil || contact.bodyB.node as? Reset != nil {
            if contactContains(strings: ["dawud"], contact: contact) == false {
                if let node = contact.bodyA.node as? Rock {
                    self.objectsToReset.append(node)
                } else if let node = contact.bodyA.node as? Rock {
                    self.objectsToReset.append(node)
                }
            }
            
            return
        }
        
        if contact.bodyA.node as? FlipSwitch != nil || contact.bodyB.node as? FlipSwitch != nil {
            if self.contactContains(strings: ["switch1", "rock"], contact: contact) {
                self.movePlatform(nodeName: "ground-nowarp-switch1")
            } else if self.contactContains(strings: ["switch2", "cannonball"], contact: contact) {
                let wait = SKAction.wait(forDuration: 1.0)
                self.run(wait) {
                    self.movePlatform(nodeName: "ground-nowarp-switch2", duration: 1.5)
                }
            } else if self.contactContains(strings: ["switch3", "rock"], contact: contact) {
                self.movePlatform(nodeName: "ground-switch3", duration: 6.0)
            } else if self.contactContains(strings: ["switch4", "rock"], contact: contact) {
                self.movePlatform(nodeName: "ground-nowarp-switch4", duration: 6.0)
            } else if self.contactContains(strings: ["switch5", "rock"], contact: contact) {
                self.movePlatform(nodeName: "ground-switch5", duration: 6.0)
            }
            
            return
        }
    }
    
    func movePlatform(nodeName: String, duration: TimeInterval = 0.65) {
        if let node = self.childNode(withName: nodeName) {
            node.physicsBody?.pinned = false
            node.physicsBody?.affectedByGravity = true
            let action = SKAction.wait(forDuration: duration)
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
        if let cannons = self.cannons {
            for cannon in cannons {
                if cannon.lastTimeFired == nil {
                    cannon.lastTimeFired = currentTime
                    cannon.launch()
                } else {
                    if currentTime - cannon.lastTimeFired >= cannon.timeToFire {
                        cannon.launch()
                        cannon.lastTimeFired = currentTime
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        enumerateChildNodes(withName: "ground-antigravity") { (node, pointer) in
            if let node = node as? AntiGravPlatformProtocol {
                node.applyUpwardForce()
            }
        }
        
        self.enumerateChildNodes(withName: "doubleGravField") { (node, pointer) in
            if let gravFieldPhysicsBody = node.physicsBody {
                let objectsInField = gravFieldPhysicsBody.allContactedBodies()
                for object in objectsInField {
                    if let node = node as? DoubleGravField {
                        if object.node?.name?.contains("portal") == false {
                            object.applyImpulse(node.gravitation(mass: object.mass))
                        }
                    }
                }
            }
        }
        
        self.launchCannons(currentTime: currentTime)
        self.moveCamera()
        let dt = currentTime - self.lastUpdateTime
        self.handlePlayerRotation(dt: dt)
        self.lastUpdateTime = currentTime
    }
}
