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

protocol AntiGravPlatformProtocol {
    
    var startingYPos:CGFloat! { get set }
    var verticalForce:CGFloat! { get set }
    
    func applyUpwardForce()
    
}

class FlipSwitch : SKSpriteNode {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
//        self.physicsBody?.categoryBitMask = 8
    }
    
}

class AntiGravPlatform : SKSpriteNode, AntiGravPlatformProtocol {
    
    var startingYPos: CGFloat!
    var verticalForce: CGFloat! = 2000
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.startingYPos = self.position.y
        
        let lockXPos = SKConstraint.positionX(SKRange(constantValue: 5))
        self.constraints = [lockXPos]
    }
    
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
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.createPlayer()
        self.player.hasAntigrav = true
        self.player.hasImpulse = true
        
        self.addThrowButton()
        self.addThrowImpulseButton()
        
        self.physicsWorld.contactDelegate = self
        if let start = self.childNode(withName: "start") {
            self.player.position = start.position
        }
    }
    
    func moveCamera () {
        if let minX = self.childNode(withName: "cameraMinX") {
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
            let action = SKAction.wait(forDuration: 0.75)
            node.run(action) {
                node.physicsBody?.pinned = true
                node.physicsBody?.affectedByGravity = false
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
        self.moveCamera()
        let dt = currentTime - self.lastUpdateTime
        self.handlePlayerRotation(dt: dt)
        self.lastUpdateTime = currentTime
    }
}
