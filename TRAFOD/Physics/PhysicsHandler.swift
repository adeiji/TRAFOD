//
//  PhysicsHandler.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/6/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class PhysicsHandler {
    
    static let kRunVelocity:CGFloat = 400
    static let kRunInAirImpulse:CGFloat = 10
    static let kJumpImpulse:CGFloat = 600
    static let kGrabbedObjectMoveVelocity:CGFloat = 3200
    
    /**
     This is the Flip Gravity node, when an object makes contact with this node than flip grav is activated
     */
    var physicsAlteringAreas:[Minerals: PhysicsAlteringObject] = [Minerals: PhysicsAlteringObject]()
    
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
                    if contactContains(strings: ["noantigrav"], contact: contact) {
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
                if let name = node.name {
                    if name.contains("pin") {
                        node.topOfSwitch?.verticalForce = 0
                        node.topOfSwitch?.physicsBody?.pinned = true
                    }
                }
            }
        }
    }
}
