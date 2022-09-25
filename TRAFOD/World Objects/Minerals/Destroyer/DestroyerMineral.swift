//
//  Destroyer.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/13/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class DestroyerMineral: Mineral, SKPhysicsContactDelegate, UseMinerals {
    
    init() {
        super.init(mineralType: .DESTROYER)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func mineralUsed(contactPosition: CGPoint, world: World, objectHitByMineral: SKNode) -> PhysicsAlteringObject? {
        
        guard let rockFragment = objectHitByMineral as? RockFragment else { return nil }
        rockFragment.breakApart()
        
        return nil
    }
}
