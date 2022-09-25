//
//  AntiGravityMineral.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 8/6/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class AntiGravityMineral : Mineral, UseMinerals {
    init() {
        super.init(mineralType: .ANTIGRAV)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func mineralUsed (contactPosition: CGPoint, world: World, objectHitByMineral:SKNode? = nil) -> PhysicsAlteringObject? {
                        
        if !world.forces.contains(.ANTIGRAV) {            
            world.playSound(fileName: "antigrav")
            world.forces.append(.ANTIGRAV)
            self.removeFromParent()
            return self.createAntiGravField(point: contactPosition, world: world)
        } else {
            world.gravityTimeLeft = 10
        }
        
        return nil
    }
    
    private func createAntiGravField (point: CGPoint, world: World) -> PhysicsAlteringObject {
        let antiGravField = AntiGravityField(contactPosition: point, size: nil, color: .clear, anchorPoint: CGPoint(x: 0.5, y: 0.5))
        antiGravField.showMineralEffectOnView(point: point, world: world)
        return antiGravField
        
    }
}
