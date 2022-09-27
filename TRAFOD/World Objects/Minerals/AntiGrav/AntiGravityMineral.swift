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
    
    func mineralUsed (contactPosition: CGPoint, world: World, objectHitByMineral:SKNode) -> PhysicsAlteringObject? {
        
        if let antiGravField = world.getPhysicsAlteringFieldFromWorldOfType(AntiGravityField.self) {
            antiGravField.removeFromParent()
        }
        
        world.playSound(fileName: "antigrav")
        world.forces.append(.ANTIGRAV)        
        self.removeFromParent()
        let antiGravField = self.createAntiGravField(point: contactPosition, world: world, objectHitByMineral: objectHitByMineral)
        world.addPhysicsAlteringFieldToWorld(antiGravField)
        return antiGravField
    }
    
    private func createAntiGravField (point: CGPoint, world: World, objectHitByMineral:SKNode) -> PhysicsAlteringObject {
        let antiGravField = AntiGravityField(contactPosition: point, size: nil, color: .clear, anchorPoint: CGPoint(x: 0.5, y: 0.5))
        antiGravField.showMineralEffectOnView(point: point, world: world)
        antiGravField.anchorToObject(world: world, objectHitByMineral: objectHitByMineral, contactPosition: point)
        
        return antiGravField
        
    }
}
