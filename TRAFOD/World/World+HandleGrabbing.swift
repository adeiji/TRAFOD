//
//  World+HandleGrabbing.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/8/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

extension World {
    /**
     
     Checks to see if the specified object is in front of the player
     
     - parameters: object The object to check if it's in front of the player
     - returns: A boolean value indicating whether the object is in front or not
     
     */
    func objectIsInFront (object: SKNode?) -> Bool {
        if let object = object {
            if let parent = object.parent {
                // Gets the objects position relative to the scene
                if let position = object.scene?.convert(object.position, from: parent) {
                    
                    let playerIsFlipped = self.player.getIsFlipped()
                    
                    if playerIsFlipped == false {
                        if self.player.xScale > 0 { // player facing right
                            if position.x > self.player.position.x {
                                return true
                            } else {
                                return false
                            }
                        } else {
                            if position.x < self.player.position.x {
                                return true
                            } else {
                                return false
                            }
                        }
                    } else {
                        if self.player.xScale > 0 { // player facing right
                            if position.x < self.player.position.x {
                                return true
                            } else {
                                return false
                            }
                        } else {
                            if position.x > self.player.position.x {
                                return true
                            } else {
                                return false
                            }
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    /**
     
     Checks to see if the user is facing an object nearby that he is able to grab and move around
     
     */
    func handleContactWithGrabbableObject (contact: SKPhysicsContact) -> Bool {
        let objectToGrab = contact.bodyA.node as? Rock != nil ? contact.bodyA.node : contact.bodyB.node
        
        if self.player.state == .ONGROUND {
            if self.objectIsInFront(object: objectToGrab) {
                self.player.objectThatCanBeGrabbed = objectToGrab as? SKSpriteNode
                return true
            }
        }
        
        return false
    }
    
    
    func stopGrabbing () {
        self.hideGrabButton()
        self.player.letGoOfObject()
    }
    
    func handleGrabButtonActions (atPoint pos:CGPoint) {
        if let grabButton = self.grabButton {
            if grabButton.isHidden == false && self.nodes(at: pos).contains(grabButton) {
                if self.player.state == .GRABBING {
                    self.stopGrabbing()
                } else {
                    self.player.state = .GRABBING
                    self.player.runningState = .STANDING
                    self.player.grabbedObject = self.player.objectThatCanBeGrabbed
                    if let grabbedObject = self.player.grabbedObject, let player = self.player {
                        let constraint = SKConstraint.distance(SKRange(upperLimit: self.getBufferSizeForContactedObjects(first: grabbedObject, second: player) ?? 25.0), to: grabbedObject)
                        self.player.constraints = [constraint]
                    }
                }
                return
            }
        }
    }
    
    func distanceBetweenNodes(first: SKNode, second: SKNode) -> CGFloat? {
        if let firstParent = first.parent, let secondParent = second.parent {
            if let firstPos = self.scene?.convert(first.position, from: firstParent), let secondPos = self.scene?.convert(second.position, from: secondParent) {
                return CGFloat(hypotf(Float(secondPos.x - firstPos.x), Float(secondPos.y - firstPos.y)));
            }
        }
        
        return nil
    }
    
    func getBufferSizeForContactedObjects (first: SKSpriteNode, second: SKSpriteNode) -> CGFloat? {
        return first.size.width / 2.0 + second.size.width / 2.0
    }
    
    func moveGrabbedObject () {
        self.player.physicsBody?.velocity.dy = 0
        
        if let object = self.player.grabbedObject, let physicsBody = object.physicsBody {
            if physicsBody.velocity.dy < -100 {
                self.stopGrabbing()
                return
            }
            
            if let bufferSize = self.getBufferSizeForContactedObjects(first: self.player, second: object) {
                if let distance = distanceBetweenNodes(first: self.player, second: object) {
                    if distance - bufferSize > 20 {
                        self.stopGrabbing()
                        return
                    }
                }
            }
            
            let gravityDifference = (self.physicsWorld.gravity.dy / -9.8)
            
            if abs(physicsBody.mass * self.physicsWorld.gravity.dy) <= self.player.strength * 160.81 {
                if self.player.runningState == .RUNNINGRIGHT {
                    object.physicsBody?.applyImpulse(CGVector(dx: (PhysicsHandler.kGrabbedObjectMoveVelocity * 20) / ((object.physicsBody!.mass / 3.0) * gravityDifference), dy: 0))
                } else if self.player.runningState == .RUNNINGLEFT {
                    object.physicsBody?.applyImpulse(CGVector(dx: (-PhysicsHandler.kGrabbedObjectMoveVelocity * 20) / ((object.physicsBody!.mass / 3.0) * gravityDifference), dy: 0))
                } else if self.player.runningState == .STANDING {
                    if let physicsBody = object.physicsBody {
                        object.physicsBody?.velocity = CGVector(dx: 0, dy: physicsBody.velocity.dy)
                    }
                }
            } else {
                showSpeech(message: "It's too heavy...", relativeToNode: self.player)
            }
        }
    }
    
    func hideGrabButton() {
        self.grabButton?.isHidden = true
        self.grabButton?.alpha = 0.0
    }
    
    func showGrabButton () {
        self.grabButton?.isHidden = false
        self.grabButton?.alpha = 1.0
    }
    
    func handleGrabbedObjectContactEnded (contact: SKPhysicsContact) {
        if PhysicsHandler.contactContains(strings: ["dawud", "rock"], contact: contact) {
            if self.player.state != .GRABBING {
                self.player.objectThatCanBeGrabbed = nil
                self.stopGrabbing()
            }

            return
        }
    }
}
