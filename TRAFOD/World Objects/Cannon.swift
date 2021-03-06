//
//  Cannon.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class Cannon : SKSpriteNode {
    
    // The time to wait before firing again
    var timeToFire:Double = 3.0
    var lastTimeFired:TimeInterval!
    let cannonBlast = SKAudioNode(fileNamed: "cannonblast.wav")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Cannon)
        self.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.Minerals)
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Player)
        self.addChild(self.cannonBlast)
        self.cannonBlast.autoplayLooped = false
        self.cannonBlast.isPositional = true
    }
    
    /**
     
     Launches a cannon ball based off of the angle of the cannon continously
     
     */
    func launch () {
        let ball = CannonBall(cannon: self)
        
        let angle = self.zRotation * 180 / .pi
        let differenceFrom90Degrees = abs(90 - abs(angle))
        let yVector = (35000 - 35000 * (1 - (differenceFrom90Degrees / 90)))
        let xVector = (35000 * (1 - (differenceFrom90Degrees / 90) ) ) * ( ( (90 - angle) / abs(90 - angle) ) * -1)
        ball.physicsBody?.applyImpulse(CGVector(dx: xVector, dy: yVector))
        self.cannonBlast.run(SKAction.play())
    }
}

class Cannon5 : Cannon {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.timeToFire = 5.0
    }
}

class Cannon10 : Cannon {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.timeToFire = 10.0
    }
}
