//
//  UseMinerals.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/25/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

/// This is the protocol for minerals that can be thrown and upon collision create physics bodies
protocol UseMinerals {
    func mineralUsed(contactPosition: CGPoint, world:World) throws -> PhysicsAlteringObject?
}
