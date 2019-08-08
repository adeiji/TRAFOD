//
//  AntiGravityMineral.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 8/6/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class AntiGravityMineral : Mineral, UseMinerals {
    init() {
        super.init(mineralType: .ANTIGRAV)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func mineralUsed (contactPosition: CGPoint, world: World) -> PhysicsAlteringObject? {
        
        if !world.forces.contains(.ANTIGRAV) {
            world.playSound(fileName: "antigrav")
            world.physicsWorld.gravity.dy = world.physicsWorld.gravity.dy / 2.2
            world.forces.append(.ANTIGRAV)
            
            let antiGravView = world.camera?.childNode(withName: world.antiGravViewKey)
            antiGravView?.isHidden = false
            
            let timeNode = SKLabelNode()
            timeNode.fontSize = 100
            timeNode.position = CGPoint(x: 0, y: 0)
            world.camera?.addChild(timeNode)
            world.gravityTimeLeft = 10
            let timeLabel = SKLabelNode()
            timeLabel.fontSize = 120
            timeLabel.fontName = "HelveticaNeue-Bold"
            timeLabel.position = CGPoint(x: 0, y: 0)
            timeLabel.zPosition = 5
            world.gravityTimeLeftLabel = timeLabel
            world.camera?.addChild(timeLabel)
            world.changeGravityWithTime(antiGravView: antiGravView, timeLabel: timeLabel)
        } else {
            world.gravityTimeLeft = 10
        }
        
        return nil
    }
}
