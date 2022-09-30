//
//  Cannon.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class Cannon : SKSpriteNode, LaunchingProtocol {
    
    // The time to wait before firing again
    var timeToFire:Double? = 0.5
    var lastTimeFired:TimeInterval!
    let sound = SKAudioNode(fileNamed: "cannonblast.wav")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Cannon)
        self.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.Minerals)
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Player)
        self.addChild(self.sound)
        self.sound.autoplayLooped = false
        self.sound.isPositional = true
        
        self.launch(projectile: CannonBall(cannon: self))
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
