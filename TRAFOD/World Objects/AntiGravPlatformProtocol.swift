//
//  AntiGravPlatformProtocol.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

protocol AntiGravPlatformProtocol {
    
    var startingYPos:CGFloat! { get set }
    var verticalForce:CGFloat! { get set }
    
    func applyUpwardForce()
    
}
