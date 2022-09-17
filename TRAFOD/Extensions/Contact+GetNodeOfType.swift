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
    
    func getNodeOfType<U>(_ type:U.Type) -> SKNode? {
        if self.bodyA.node is U {
            return self.bodyA.node
        } else if self.bodyB.node is U {
            return self.bodyB.node
        }
        
        return nil
    }    
}
