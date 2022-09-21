//
//  SKNode+DistanceBetweenNodes.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/20/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

extension SKNode {
    func distanceToNode(node: SKNode) -> CGFloat? {
        if let firstParent = self.parent, let secondParent = node.parent {
            if let firstPos = self.scene?.convert(self.position, from: firstParent), let secondPos = self.scene?.convert(node.position, from: secondParent) {
                return CGFloat(hypotf(Float(secondPos.x - firstPos.x), Float(secondPos.y - firstPos.y)));
            }
        }
        
        return nil
    }
}
