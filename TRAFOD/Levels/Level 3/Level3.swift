//
//  Level3.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class Level3 : Level {
    
    var temporarySwitches:[FlipSwitch]? = [FlipSwitch]()
    
    override func didMove(to view: SKView) {
        self.currentLevel = .LEVEL3
        super.didMove(to: view)
        self.playBackgroundMusic(fileName: "level3")
    }    
    
    func pinSwitch (contact: SKPhysicsContact) {
        if let node = contact.bodyA.node as? WeightSwitch {
            node.physicsBody?.pinned = true
        } else if let node = contact.bodyB.node as? WeightSwitch {
            node.physicsBody?.pinned = true
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }
}
