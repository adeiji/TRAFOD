//
//  ProjectileProtocol.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/15/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

protocol ProjectileProtocol: SKSpriteNode {
    init(cannon: LaunchingProtocol)
}
