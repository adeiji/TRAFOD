//
//  UseMinerals.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/25/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

/// This is the protocol for minerals that can be thrown and upon collision create physics bodies. However, they don't have to create a physics body upon collision due to the fact that there are other types of minerals used within the game that don't necessarily alter physics but instead lead to a specific animation, such as the destroyer mineral which destroys loose rocks
protocol UseMinerals {
    func mineralUsed(contactPosition: CGPoint, world:World, objectHitByMineral:SKNode) -> PhysicsAlteringObject?
}

