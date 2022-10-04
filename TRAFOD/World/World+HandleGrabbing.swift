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
    
    func showClimbButton () {
        if self.player.isInContactWithFence() {
            if self.player.state != .CLIMBING {
                self.actionButtons.climbButton?.alpha = 1.0
            } else {
                self.actionButtons.climbButton?.alpha = 0.0
            }
        } else {
            self.actionButtons.climbButton?.alpha = 0.0
        }
    }
    
}

extension World {
    /**
     
     Checks to see if the specified object is in front of the player
     
     - parameters: object The object to check if it's in front of the player
     - returns: A boolean value indicating whether the object is in front or not
     
     */
    func objectIsInFront (object: SKNode?) -> Bool {
        if let object = object {
            if let parent = object.parent {
                
                // If the object is in contact with the PlayerGroundNode then the player is standing ont he object so we don't want to allow movement of the object
                if object.physicsBody?.allContactedBodies().first(where: { $0.node?.name == PhysicsObjectTitles.PlayerGroundNode }) != nil{
                    return false
                }
                
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
    @discardableResult func handleContactWithGrabbableObject (contact: SKPhysicsContact) -> Bool {
        let objectToGrab = contact.bodyA.node as? GrabbableObject != nil ? contact.bodyA.node : contact.bodyB.node
        
        if self.player.state == .ONGROUND {
            if self.objectIsInFront(object: objectToGrab) {
                self.player.objectThatCanBeGrabbed = objectToGrab as? SKSpriteNode
                return true
            }
        }
        
        return false
    }
                
    
    func handleGrabbedObjectContactEnded (contact: SKPhysicsContact) {
        if PhysicsHandler.contactContains(strings: ["dawud", "rock"], contact: contact) {
            if self.player.state != .GRABBING {
                self.player.objectThatCanBeGrabbed = nil
                self.player.stopGrabbingObject()
            }

            return
        }
    }
}
