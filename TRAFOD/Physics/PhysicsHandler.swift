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
    
    class func contactContains (strings: [String], contactA: String = "", contactB: String = "", contact: SKPhysicsContact? = nil) -> Bool {
        var result = true
        
        if let contact = contact {
            for string in strings {
                var myResult = false
                if let name = contact.bodyA.node?.name {
                    if name.contains(string) {
                        myResult = true
                    }
                } else {
                    return false
                }
                
                if let name = contact.bodyB.node?.name {
                    if name.contains(string) {
                        myResult = true
                    }
                } else {
                    return false
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
     If a player hits a mineral that can be grabbed
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
}
