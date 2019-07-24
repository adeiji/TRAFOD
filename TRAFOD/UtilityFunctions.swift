//
//  UtilityFunctions.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/24/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class UtilityFunctions {
    
    /**
     Given two nodes it returns the distance between them
     
     - Parameter first: The first node
     - Parameter second: The second node
     */
    class func  SDistanceBetweenPoints(first: SKNode, second: SKNode) -> CGFloat {
        return CGFloat(hypotf(Float(second.position.x - first.position.x), Float(second.position.y - first.position.y)));
    }
}
