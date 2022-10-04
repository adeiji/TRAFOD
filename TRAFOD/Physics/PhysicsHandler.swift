//
//  PhysicsHandler.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/6/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

/**
 Responsible for handling the physics related aspects of the game.
 
 There are many specific interactions that we pay attention to. For example when a mineral hits the ground, or the player hits a retrievable item. In this class we detect whether the collision is one we care about and then handle the action that should ensue as a result of the interaction (collision or contact).
 */
class PhysicsHandler {
    
    static let kRunVelocity:CGFloat = 300
    
    /**
     When the player is grabbing an object we apply a velocity to the object that is being held. The velocity is whatever the player's running velocity is, multiplied by this number
     */
    static let kGrabbedObjectVelocityMultiplier:CGFloat = 50
    static let kRunInAirImpulse:CGFloat = 10
    static let kJumpImpulse:CGFloat = 750
    static let kGrabbedObjectMoveVelocity:CGFloat = 4000
    
    /**
     This contains all the nodes that can alter the physics of other objects that have been used and are currently active
     */
    var physicsAlteringAreas:[Minerals: PhysicsAlteringObject] = [Minerals: PhysicsAlteringObject]()
    
    /**
     Get a physics body for the type of object that the player hits and retrieves something
     */
    class func getPhysicsBodyForRetrievableObject (size: CGSize) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody.affectedByGravity = false
        physicsBody.restitution = 0
        physicsBody.mass = 0
        physicsBody.isDynamic = false
        physicsBody.pinned = true
        physicsBody.categoryBitMask = UInt32(PhysicsCategory.GetObject)
        physicsBody.collisionBitMask = UInt32(PhysicsCategory.Nothing)
        physicsBody.contactTestBitMask = UInt32(PhysicsCategory.Player)
        physicsBody.fieldBitMask = UInt32(PhysicsCategory.Nothing)
        physicsBody.allowsRotation = false
        
        return physicsBody
    }
    
    class func getPhysicsBodyForContactOnlyObject (size: CGSize) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody.isDynamic = false
        physicsBody.collisionBitMask = UInt32(PhysicsCategory.Nothing)
        physicsBody.categoryBitMask = UInt32(PhysicsCategory.NonCollision)
        physicsBody.contactTestBitMask = UInt32(PhysicsCategory.Player)
        return physicsBody
    }
    
    class func contactContains (strings: [String], contactA: String = "", contactB: String = "", contact: SKPhysicsContact? = nil) -> Bool {
        var result = true
        
        if let contact = contact {
            for string in strings {
                var myResult = false
                if let name = contact.bodyA.node?.name {
                    if name.contains(string) {
                        myResult = true
                    }
                }
                
                if let name = contact.bodyB.node?.name {
                    if name.contains(string) {
                        myResult = true
                    }
                }
                
                if myResult == false {
                    result = false
                    break
                }
                
            }
            
            return result
        }
        
        for string in strings {
            var myResult = false
            if contactA.contains(string) {
                myResult = true
            }
            if contactB.contains(string) {
                myResult = true
            }
            
            if myResult == false {
                result = false
                break
            }
            
        }
        
        return result
    }
    
    class func shouldSwitch (contact: SKPhysicsContact) -> Bool {        
        if contact.bodyA.node is FlipSwitch || contact.bodyB.node is FlipSwitch {
            if contact.bodyA.node is Rock || contact.bodyB.node is Rock {
                return true
            }
        }
        
        return false
    }
    
    /**
     Taking two types of node objects, check to see if the physics contact contains both of those nodes
     
     if nodesAreOfType(contact: contact, nodeAType: FlipGravityMineral.self, nodeBType: Player.type) {
        // Do Something
     }
     
     - returns:
     Whether or not the physics contacts contains both types of objects
     */
    class func nodesAreOfType<T, U>(contact: SKPhysicsContact, nodeAType: T.Type, nodeBType: U.Type) -> Bool {
        if let _ = contact.bodyA.node as? T != nil ? contact.bodyA.node as? T : contact.bodyB.node as? T,
            let _ = contact.bodyB.node as? U != nil ? contact.bodyB.node as? U : contact.bodyA.node as? U {
            return true
        }
        
        return false
    }
    
    /**
     If a player makes contact with a mineral that can be grabbed than we return the mineral that the user just made contact with/grabbed
     
     - Parameter contact: The SKPhysicsContact object that containes the nodes for this specific contact
     - Returns: RetrieveMineralNode? - The Mineral that the user just grabbed/made contact with
     */
    class func playerIsGrabbingMineral (contact: SKPhysicsContact) -> RetrieveMineralNode? {
        
        if let _  = contact.bodyA.node as? Player != nil ? contact.bodyA.node : contact.bodyB.node
        {
            if let mineral = contact.bodyA.node as? RetrieveMineralNode != nil ? contact.bodyA.node as? RetrieveMineralNode : contact.bodyB.node as? RetrieveMineralNode {
                mineral.removeFromParent()
                return mineral
            }
        }
        
        return nil
    }
    
    /**
     Check to see if the player has used the flip grav mineral right now.  This method is only called from within the contact didBegin methods
     
     - Parameters:
     - contact: SKPhysicsContact - The contact made that called the execution of the didBegin that called this method
     */
    class func playerUsedFlipGrav (contact: SKPhysicsContact) -> FlipGravityMineral? {
        if nodesAreOfType(contact: contact, nodeAType: Ground.self, nodeBType: FlipGravityMineral.self) {
            if let mineral = contact.bodyA.node as? FlipGravityMineral != nil ? contact.bodyA.node as? FlipGravityMineral : contact.bodyB.node as? FlipGravityMineral {
                if !PhysicsHandler.contactContains(strings: ["noflipgrav"], contact: contact) {
                    mineral.showMineralCrash(withColor: mineral.mineralCrashColor, contact: contact, duration: 2)                    
                    return mineral
                } else {
                    mineral.removeFromParent()
                }
            }
        }
        
        return nil
    }
    
    /**
     Checks to see if a thrown mineral has made contact with Ground.  If it has, then we show the mineral crash on the ground
     
     - Parameters:
     - contact: SKPhysicsContact - The contact made that called the execution of the didBegin that called this method
     */
    class func playerUsedMineral (contact: SKPhysicsContact) -> Mineral? {
        if nodesAreOfType(contact: contact, nodeAType: Ground.self, nodeBType: Mineral.self) || nodesAreOfType(contact: contact, nodeAType: Cannon.self, nodeBType: Mineral.self)  {
            if let mineral = contact.bodyA.node as? Mineral != nil ? contact.bodyA.node as? Mineral : contact.bodyB.node as? Mineral {
                mineral.showMineralCrash(withColor: mineral.mineralCrashColor, contact: contact, duration: 2)
                mineral.removeFromParent()                
                
                switch mineral {
                case is FlipGravityMineral:
                    if contactContains(strings: ["noflipgrav"], contact: contact) {
                        return nil
                    }
                case is ImpulseMineral:
                    if contactContains(strings: ["nowarp"], contact: contact) {
                        return nil
                    }
                case is AntiGravityMineral:
                    if contact.getNodeOfType(NegateGravityGround.self) != nil {
                        return nil
                    }
                default:
                    break;
                }
                return mineral
            }
        }
        
        return nil
    }
    
    /**
     Check to see if the user has switched a weight switch, and if so, move it's designated platform
     
     - Parameters:
     - contact: SKPhysicsContact - The contact made that called the execution of the didBegin that called this method
     */
    class func handlePlayerSwitchedWeightSwitch (contact: SKPhysicsContact) {
        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: MultiDirectionalGravObject.self, nodeBType: WeightSwitchBottom.self) {
            if let node = contact.bodyA.node?.parent as? WeightSwitch {
                node.platform?.move()
                node.topOfSwitch?.verticalForce = 0
                node.topOfSwitch?.physicsBody?.pinned = true
            }
        }
    }
}
