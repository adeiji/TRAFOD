//
//  ProjectileProtocol.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/15/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

/**
 A template for anything that is thrown from another object as a projectile.
 
Examples of objects that would adhere to this protocol are Cannon and Arrow objects
 */
protocol ProjectileProtocol: SKSpriteNode {
    init(cannon: LaunchingProtocol)
}
