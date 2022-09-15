//
//  AnimationFactory.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/14/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

class AnimationFactory {
    
    static func getObject (type: String) -> SKSpriteNode? {
        
        switch type {
        case Minerals.IMPULSE.rawValue:
            return ImpulseMineral()
        case Minerals.FLIPGRAVITY.rawValue:
            return FlipGravityMineral()
        case Minerals.ANTIGRAV.rawValue:
            return AntiGravityMineral()
        default:
            return nil
        }
        
    }
    
}
