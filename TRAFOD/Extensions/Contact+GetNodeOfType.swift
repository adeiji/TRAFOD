//
//  Contact+GetNodeOfType.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/16/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

extension SKPhysicsContact {
    
    /**
     Gets a node of a certain type
     
     - Parameter type: The type of object to get from the contact
     */
    func getNodeOfType<U>(_ type:U.Type) -> SKNode? {
        if self.bodyA.node is U {
            return self.bodyA.node
        } else if self.bodyB.node is U {
            return self.bodyB.node
        }
        
        return nil
    }
    
    /**
     Gets a node of a certain name
     
     - Parameter type: The name of the object to get from the contact
     */
    func getNodeWithName (name: String) -> SKNode? {
        if self.bodyA.node?.name == name {
            return self.bodyA.node
        } else if self.bodyB.node?.name == name {
            return self.bodyB.node
        }
        
        return nil
    }
}
