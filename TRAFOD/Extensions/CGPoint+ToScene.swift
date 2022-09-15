//
//  CGPoint+ToScene.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/15/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

extension CGPoint {
    
    func toScene (_ scene: SKNode?) -> CGPoint {
        return scene != nil ? scene!.convert(self, to: scene!) : self
    }
    
}
