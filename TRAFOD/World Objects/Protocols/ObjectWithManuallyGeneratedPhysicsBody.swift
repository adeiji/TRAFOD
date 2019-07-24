//
//  ObjectWithManuallyGeneratedPhysicsBody.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/18/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

protocol ObjectWithManuallyGeneratedPhysicsBody {
    func setupPhysicsBody ()
}

protocol PortalPortocol {
    init(contactPosition: CGPoint, size: CGSize?, color: UIColor?, anchorPoint: CGPoint)
    func applyForceToPhysicsBodies (forceOfGravity: CGFloat, camera: SKCameraNode?)
    func setCategoryBitmask ()
}
