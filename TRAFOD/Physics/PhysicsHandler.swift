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
}
