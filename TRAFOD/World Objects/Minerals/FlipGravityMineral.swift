//
//  FlipGravityMineral.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/10/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class FlipGravityMineral : Mineral, SKPhysicsContactDelegate {
    
    var mineralCrashColor: UIColor = .purple
    
    init() {
        super.init(mineralType: .FLIPGRAVITY)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func mineralUsed (contactPosition: CGPoint) throws -> FlipGravity {        
        let flipGravity = FlipGravity(contactPosition: contactPosition, size: CGSize(width: 200, height: 2000), color: .purple, anchorPoint: CGPoint(x: 0.5, y: 0))
        flipGravity.zPosition = -5
        return flipGravity
    }
}
