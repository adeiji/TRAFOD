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
    static let Minerals:Int32 = 0x1 << 6
    static let Reset:Int32 = 0x1 << 7
    static let Ground:Int32 = 0x1 << 8
    static let Nothing:Int32 = 0x1 << 16
}

protocol AntiGravPlatformProtocol {
    
    var startingYPos:CGFloat! { get set }
    var verticalForce:CGFloat! { get set }
    
    func applyUpwardForce()
    
}

class Reset: SKSpriteNode {
    var startingPos:CGPoint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)                
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Reset)
        let constraints = [ SKConstraint.positionX(SKRange(constantValue: self.position.x), y: SKRange(constantValue: self.position.y)) ]
        self.constraints = constraints        
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
    let cannonBlast = SKAudioNode(fileNamed: "cannonblast.wav")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.InteractableObjects)
        self.addChild(self.cannonBlast)
        self.cannonBlast.autoplayLooped = false
        self.cannonBlast.isPositional = true
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
        self.cannonBlast.run(SKAction.play())        
    }
}

class CannonBall : SKSpriteNode {
    
    init(cannon: Cannon) {
        let texture = SKTexture(imageNamed: "cannonball")
        super.init(texture: texture, color: .clear, size: CGSize(width: texture.size().width / 5.0, height: texture.size().height / 10.0) )
        
        self.name = "cannonball"
        self.physicsBody = SKPhysicsBody(circleOfRadius: 25 )
        self.physicsBody?.mass = 15
        self.physicsBody?.collisionBitMask = 0b0010
        self.physicsBody?.contactTestBitMask = 1 | UInt32(PhysicsCategory.NonInteractableObjects)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.restitution = 1.0
        self.physicsBody?.allowsRotation = false
        self.showResetParticles(node: self)
        
        
        cannon.addChild(self)
    }
    
    func showResetParticles (node: SKSpriteNode) {
        if let fireFliesParticlesPath = Bundle.main.path(forResource: "Doors", ofType: "sks") {
            if let fireFliesParticles = NSKeyedUnarchiver.unarchiveObject(withFile: fireFliesParticlesPath) as? SKEmitterNode {
                fireFliesParticles.zPosition = 0
                fireFliesParticles.particleBirthRate = fireFliesParticles.particleBirthRate / 8.0
                fireFliesParticles.particleLifetime = fireFliesParticles.particleLifetime / 8.0
                fireFliesParticles.particlePositionRange.dx = node.size.width
                fireFliesParticles.particlePositionRange.dy = node.size.height
                fireFliesParticles.particleSize = CGSize(width: fireFliesParticles.particleSize.width / 10.0, height: fireFliesParticles.particleSize.width / 10.0)
                fireFliesParticles.particleColor = .white
                node.addChild(fireFliesParticles)
            }
        }
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
        self.physicsBody?.restitution = 0
        self.physicsBody?.contactTestBitMask = 1 | UInt32(PhysicsCategory.InteractableObjects) | UInt32(PhysicsCategory.NonInteractableObjects) | UInt32(PhysicsCategory.Reset)
        self.physicsBody?.allowsRotation = true
    }
}

class MovablePlatform : SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.InteractableObjects)
        self.physicsBody?.pinned = true
        self.physicsBody?.affectedByGravity = false
        let constraint = SKConstraint.positionX(SKRange(constantValue: self.position.x))
        self.constraints = [constraint]
    }
}

class MultiDirectionalGravObject : SKSpriteNode, AntiGravPlatformProtocol {
    
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
        self.physicsBody?.restitution = 0
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

class AntiGravPlatformHeavy : MultiDirectionalGravObject {

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
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.currentLevel = .LEVEL2
        self.physicsWorld.contactDelegate = self
        self.getCannons()
        self.setupPlayer()
        
        if self.player.hasAntigrav {
            self.addThrowButton()
            self.showMineralCount()
        }
        
        if self.player.hasImpulse {
            self.addThrowImpulseButton()
            self.showMineralCount()
        }
        
        self.removeCollectedElements()
        self.showDoorParticles()
        self.changeMineralPhysicsBodies()        
        self.showResetParticles()
        self.showResetParticles(nodeName: "rocks")
        self.showNoWarpParticles()
        self.playBackgroundMusic()
        self.showBackgroundParticles()
        self.showFireFlies()
    }
    
    func playBackgroundMusic () {
        if let musicURL = Bundle.main.url(forResource: "level2_theme", withExtension: "mp3") {
            self.backgroundMusic = SKAudioNode(url: musicURL)
            addChild(self.backgroundMusic)
        }
        
        if let musicURL = Bundle.main.url(forResource: "birdschirping", withExtension: "wav") {
            self.ambiance = SKAudioNode(url: musicURL)
            self.ambiance.run(SKAction.changeVolume(by: -0.7, duration: 0))
            addChild(self.ambiance)
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
        
        if contactContains(strings: ["dawud", "level3"]) {
            gotoNextLevel(sceneName: "level3")
        }
        
        if contact.bodyA.node as? Reset != nil || contact.bodyB.node as? Reset != nil {
            var resetNode:Reset!
            var nodeHasParent = false
            
            if let _ = contact.bodyA.node as? Reset {
                resetNode = contact.bodyA.node as? Reset
            } else {
                resetNode = contact.bodyB.node as? Reset
            }
            
            if contactContains(strings: ["dawud"], contact: contact) == false {
                if resetNode.parent == nil {
                    nodeHasParent = true
                }
                
                if let node = contact.bodyA.node as? Rock {
                    if !nodeHasParent {
                        self.objectsToReset.append(node)
                    } else {
                        if node == resetNode.parent! {
                            self.objectsToReset.append(node)
                        }
                    }
                } else if let node = contact.bodyB.node as? Rock {
                    if !nodeHasParent {
                        self.objectsToReset.append(node)
                    } else {
                        if node == resetNode.parent! {
                            self.objectsToReset.append(node)
                        }
                    }
                }
            }
            
            return
        }
        
        if contact.bodyA.node as? FlipSwitch != nil || contact.bodyB.node as? FlipSwitch != nil {
            var flipSwitch:FlipSwitch?
            if let mySwitch = contact.bodyA.node as? FlipSwitch {
                flipSwitch = mySwitch
            }
            
            if let mySwitch = contact.bodyB.node as? FlipSwitch {
                flipSwitch = mySwitch
            }
            
            if self.contactContains(strings: ["switch1", "rock"], contact: contact) {
                self.movePlatform(nodeName: "ground-nowarp-switch1")
                self.flipSwitchOn(node: flipSwitch)
            } else if self.contactContains(strings: ["switch2", "cannonball"], contact: contact) {
                let wait = SKAction.wait(forDuration: 1.0)
                self.run(wait) {
                    self.movePlatform(nodeName: "ground-nowarp-switch2", duration: 1.5)
                    self.flipSwitchOn(node: flipSwitch)
                }
            } else if self.contactContains(strings: ["switch3", "rock"], contact: contact) {
                self.movePlatform(nodeName: "ground-switch3", xOffset: 0, yOffset: 250, duration: 3.0)
                self.flipSwitchOn(node: flipSwitch)
            } else if self.contactContains(strings: ["switch4", "rock"], contact: contact) {
                self.movePlatform(nodeName: "ground-nowarp-switch4", duration: 6.0)
                self.flipSwitchOn(node: flipSwitch)
            } else if self.contactContains(strings: ["switch5", "rock"], contact: contact) {
                self.movePlatform(nodeName: "ground-switch5", xOffset: 750, yOffset: 0, duration: 3.0)
                self.flipSwitchOn(node: flipSwitch)
            }
            
            return
        }
    }
    
    func flipSwitchOn (node: FlipSwitch?) {
        if let node = node {
            if let node = node.childNode(withName: "switch") as? SKSpriteNode {
                node.texture = SKTexture(imageNamed: "switch-on")
            }
        }
    }
    
    func movePlatform (nodeName: String, xOffset: CGFloat, yOffset: CGFloat, duration: TimeInterval = 0.65) {
        if let node = self.childNode(withName: nodeName) {            
            let move = SKAction.moveBy(x: xOffset, y: yOffset, duration: duration)
            node.run(move)
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
