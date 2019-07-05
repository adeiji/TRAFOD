//
//  Level.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class Level : World {
    
    var launchTime:TimeInterval?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.physicsWorld.contactDelegate = self
        
        if self.player == nil {
            self.createPlayer()
            self.getMineralCounts()
        }
        
        if self.player.hasAntigrav {
            self.addThrowButton()
            self.showMineralCount()
        }
        
        if self.player.hasImpulse {
            self.addThrowImpulseButton()
            self.showMineralCount()
        }
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        super.didBegin(contact);
        let contactAName = contact.bodyA.node?.name ?? ""
        let contactBName = contact.bodyB.node?.name ?? ""
        
        if contactContains(strings: ["dawud", "getImpulse"], contactA: contactAName, contactB: contactBName) {
            self.getImpulse()
            
            if let node = getContactNode(string: "getImpulse", contact: contact) {
                self.addToCollectedElements(node: node)
                node.removeFromParent()
            }
            
            return
        }
        
        if contactContains(strings: ["dawud", "getAntiGrav"], contactA: contactAName , contactB: contactBName) {
            self.getAntiGrav()
            
            if let node = getContactNode(string: "getAntiGrav", contact: contact) {
                self.addToCollectedElements(node: node)
                node.removeFromParent()
            }
            
            return
        }
        
        if contactContains(strings: ["dawud", "getTeleport"], contactA: contactAName , contactB: contactBName) {
            self.getMineral(type: .TELEPORT)
            
            if let node = getContactNode(string: "getTeleport", contact: contact) {
                self.addToCollectedElements(node: node)
                node.removeFromParent()
            }
            
            return
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
            
            if self.contactContains(strings: ["level2-switch1", "rock"], contact: contact) {
                self.movePlatform(nodeName: "ground-nowarp-switch1")
                self.flipSwitchOn(node: flipSwitch)
            } else if self.contactContains(strings: ["level2-switch2", "cannonball"], contact: contact) {
                let wait = SKAction.wait(forDuration: 1.0)
                self.run(wait) {
                    self.movePlatform(nodeName: "ground-nowarp-switch2", duration: 1.5)
                    self.flipSwitchOn(node: flipSwitch)
                }
            } else if self.contactContains(strings: ["level2-switch3", "rock"], contact: contact) {
                self.movePlatform(nodeName: "ground-switch3", xOffset: 0, yOffset: 250, duration: 3.0)
                self.flipSwitchOn(node: flipSwitch)
            } else if self.contactContains(strings: ["level2-switch4", "rock"], contact: contact) {
                self.movePlatform(nodeName: "ground-nowarp-switch4", duration: 6.0)
                self.flipSwitchOn(node: flipSwitch)
            } else if self.contactContains(strings: ["level2-switch5", "rock"], contact: contact) {
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
            node.physicsBody?.pinned = false
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
        let dt = currentTime - self.lastUpdateTime
        self.handlePlayerRotation(dt: dt)
        self.lastUpdateTime = currentTime
        self.moveCamera()
    }
    
    func getMineral (type: Minerals) {
        
        if var mineralCount = self.player.mineralCounts[type] {
            mineralCount = mineralCount + 10
            self.player.mineralCounts[type] = mineralCount
            ProgressTracker.updateMineralCount(myMineral: type.rawValue, count: mineralCount)
        } else {
            self.player.mineralCounts[type] = 10;
            ProgressTracker.updateMineralCount(myMineral: type.rawValue, count: 10)
            self.showMineralReceivedBox(nodeName: "\(type.rawValue)RecievedBox");
        }
        
        self.playMineralSound()
        self.showMineralCount()
    }
    
    func getImpulse () {
        if self.player.hasImpulse == false {
            self.player.hasImpulse = true
            ProgressTracker.updateProgress(currentLevel: nil, player: self.player)
            self.showMineralReceivedBox(nodeName: "impulseRecievedBox")
        }
        
        if var count = self.player.mineralCounts[.IMPULSE] {
            count = count + 10
            self.player.mineralCounts[.IMPULSE] = count
        } else {
            self.player.mineralCounts[.IMPULSE] = 10
        }
        
        ProgressTracker.updateMineralCount(myMineral: Minerals.IMPULSE.rawValue, count: self.player.mineralCounts[.IMPULSE]!)
        
        self.playMineralSound()
        self.showMineralCount()
    }
    
    func getAntiGrav () {
        
        if var count = self.player.mineralCounts[.ANTIGRAV] {
            count = count + 10
            self.player.mineralCounts[.ANTIGRAV] = count
        } else {
            self.player.mineralCounts[.ANTIGRAV] = 10
        }
        
        ProgressTracker.updateMineralCount(myMineral: Minerals.ANTIGRAV.rawValue, count: self.player.mineralCounts[.ANTIGRAV]!)
        
        self.playMineralSound()
        self.showMineralCount()
        
        if self.player.hasAntigrav == false {
            self.player.hasAntigrav = true
            ProgressTracker.updateProgress(currentLevel: nil, player: self.player)
            self.showMineralReceivedBox(nodeName: "antigravRecievedBox")
        }
    }
    
    func showMineralReceivedBox (nodeName: String) {
        self.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.messageBox = self.childNode(withName: nodeName) as? SKSpriteNode
        self.childNode(withName: nodeName)?.alpha = 1.0
        let fade = SKAction.fadeAlpha(to: 1.0, duration: 1.0)
        self.childNode(withName: nodeName)?.run(fade)
    }
    
}
