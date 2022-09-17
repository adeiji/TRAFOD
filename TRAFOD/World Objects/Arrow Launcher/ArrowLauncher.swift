//
//  ArrowLauncher.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/15/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

/**
 An arrow launcher, is a SKSpriteNode that is responsible for launching arrows
 */
class ArrowLauncher: SKSpriteNode, LaunchingProtocol {
    var sound: SKAudioNode = SKAudioNode(fileNamed: "cannonball")
    var timeToFire: Double? {
        didSet {
            guard let timeToFire = self.timeToFire else { return }
            Timer.scheduledTimer(withTimeInterval: timeToFire, repeats: true) { timer in
                self.launch(projectile: Arrow(cannon: self))
            }
        }
    }
    var lastTimeFired: TimeInterval!
                    
    init() {
        super.init(texture: Textures.Cannon, color: .clear, size: Textures.Cannon.size())
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
                
        self.setup()
        self.timeToFire = 3.0
    }
    
    /**
     Setup the object
     
     - Parameters:
        - timeToFire: The time between firing. Example, should it fire every 3 seconds, every 5 seconds, etc.?
     */
    private func setup () {
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Cannon)
        self.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.Minerals)
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Player)
        self.addChild(self.sound)
        self.sound.autoplayLooped = false
        self.sound.isPositional = true
                        
        self.launch(projectile: Arrow(cannon: self))
        

    }
    
}
