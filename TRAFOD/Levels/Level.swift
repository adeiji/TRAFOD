//
//  Level.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

/**
 
 This class is a subclass of World and should contain only objects and properties that are level specific but not world specific.  For example, the number of minerals that the player currently has will only be viewed within levels, so we would put any objects and properties pertaining to mineral counts, mineral numbers, within this class
 
 */
class Level : World {
    
    var launchTime:TimeInterval?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.physicsWorld.contactDelegate = self        
        self.getProgress()
        self.showMineralCount()
    }
    
    override func didEnd(_ contact: SKPhysicsContact) {
        super.didEnd(contact)
        
        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: NegateFlipGravField.self, nodeBType: AffectedByNegationField.self) {
            NegateFlipGravField.removeNegatedForcesFromObjectInContact(contact: contact)
        } else if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: NegateAllForcesField.self, nodeBType: BaseWorldObject.self) {
            NegateAllForcesField.removeNegatedForcesFromObjectInContact(contact: contact)
        }
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        super.didBegin(contact);
        let contactAName = contact.bodyA.node?.name ?? ""
        let contactBName = contact.bodyB.node?.name ?? ""
        
        FlipSwitch.flipSwitch(contact: contact)
        
        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: NegateFlipGravField.self, nodeBType: AffectedByNegationField.self) {
            NegateFlipGravField.negateForceForObjectInContact(contact: contact)
        } else if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: NegateAllForcesField.self, nodeBType: BaseWorldObject.self) {
            NegateAllForcesField.negateForceForObjectInContact(contact: contact)
        }
        
        
        if PhysicsHandler.contactContains(strings: ["dawud", "getImpulse"], contactA: contactAName, contactB: contactBName) {
            self.getImpulse()
            
            if let node = getContactNode(name: "getImpulse", contact: contact) {
                self.addToCollectedElements(node: node)
                node.removeFromParent()
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["dawud", "getAntiGrav"], contactA: contactAName , contactB: contactBName) {
            self.getAntiGrav()
            
            if let node = getContactNode(name: "getAntiGrav", contact: contact) {
                self.addToCollectedElements(node: node)
                node.removeFromParent()
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["dawud", "getTeleport"], contactA: contactAName , contactB: contactBName) {
            self.getMineral(type: .TELEPORT)
            
            if let node = getContactNode(name: "getTeleport", contact: contact) {
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
            
            if PhysicsHandler.contactContains(strings: ["dawud"], contact: contact) == false {
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
        
        self.checkForAndHandleWeightSwitchCollision(contact: contact)
    }
    
    /**
     We check to see if there's been a collision with a weight switch and the player and if so, than check to see if player has hit switch with enough force
     to activate it
     
     - Parameter contact: The physics contact between the weightSwitch and the player
     */
    func checkForAndHandleWeightSwitchCollision (contact: SKPhysicsContact) {
        if PhysicsHandler.contactContains(strings: ["dawud", "weightSwitch"], contact: contact ) {
            if (contact.collisionImpulse > 1000) {
                if let weightSwitch = contact.bodyA.node as? WeightSwitch {
                    weightSwitch.topOfSwitch?.verticalForce = 0
                } else if let weightSwitch = contact.bodyB.node as? WeightSwitch {
                    weightSwitch.topOfSwitch?.verticalForce = 0
                }
            }
        }
    }
    
    func flipSwitchOn (node: FlipSwitch?) {
        if let node = node {
            if let node = node.childNode(withName: "switch") as? SKSpriteNode {
                node.texture = SKTexture(imageNamed: "switch-on")
            }
        }
    }
    
    /**
     Launch the cannons according to each cannons time interval
     
     - Parameter currentTime: - The current time of the application run loop
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
        
        // Applys double the gravitational force to all bodies that are within this node's field
        func applyDoubleGravFieldsForce () {
            self.enumerateChildNodes(withName: "doubleGravField") { (node, pointer) in
                if let gravFieldPhysicsBody = node.physicsBody {
                    let objectsInField = gravFieldPhysicsBody.allContactedBodies()
                    for object in objectsInField {
                        if let node = node as? DoubleGravField {
                            if let _ = object.node as? MovablePlatform, let _ = object.node as? PortalPortocol {
                                continue;
                            }
                            
                            if object.node?.name?.contains("portal") == false {
                                object.applyImpulse(node.gravitation(mass: object.mass))
                            }
                        }
                    }
                }
            }
        }
        
        applyDoubleGravFieldsForce()
        self.launchCannons(currentTime: currentTime)
        let dt = currentTime - self.lastUpdateTime
        self.handlePlayerRotation(dt: dt)
        self.lastUpdateTime = currentTime
        self.moveCamera()
        
        self.weightSwitches?.forEach({ (weightSwitch) in
            weightSwitch.topOfSwitch?.applyUpwardForce()
        })
    }
     
    // TODO: Needs to be deprecated
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
    
    /**
     Shows instructions to the player of how to use whichever mineral they've just received
     
     - TODO: Should probably change this name to simply show MessageBox
     - Parameter nodeName: - the name of the node to show
     - Precondition: Make sure that the node with the given nodeName has an alpha set to 0.0
     */
    func showMineralReceivedBox (nodeName: String) {
        self.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.messageBox = self.childNode(withName: nodeName) as? SKSpriteNode
        self.childNode(withName: nodeName)?.alpha = 1.0
        let fade = SKAction.fadeAlpha(to: 1.0, duration: 1.0)
        self.childNode(withName: nodeName)?.run(fade)
    }
}
