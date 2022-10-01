//
//  LaunchingProtocol.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/15/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

/**
 Protocol for any object which launches a projectile object
 */
protocol LaunchingProtocol: SKSpriteNode {
    
    // The time to wait before firing again
    var timeToFire:Double? { get set }
    var lastTimeFired:TimeInterval! { get set }
    var sound:SKAudioNode { get }
    // TODO: Change the projectile parameter to take a Projectile object instead of an SKSpriteNode object
    func launch(projectile: SKSpriteNode)
}

extension LaunchingProtocol {
    /**
     Launches a given projectile
     */
    func launch (projectile: SKSpriteNode) {
        guard let projectilePhysicsBodyMass = projectile.physicsBody?.mass else {
            assertionFailure("The projectile.physicsBody value is nil")
            return
        }
                
        let vectorForce = projectilePhysicsBodyMass * -1400
        let angle = self.zRotation * 180 / .pi
        let differenceFrom90Degrees = abs(90 - abs(angle))
        let yVector = (vectorForce - vectorForce * (1 - (differenceFrom90Degrees / 90)))
        let xVector = (vectorForce * (1 - (differenceFrom90Degrees / 90) ) ) * ( ( (90 - angle) / abs(90 - angle) ) * -1)
        projectile.physicsBody?.applyImpulse(CGVector(dx: xVector, dy: yVector))
   }
}
