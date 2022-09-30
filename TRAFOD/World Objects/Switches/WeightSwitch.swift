//
//  WeightSwitch.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/5/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class WeightSwitch : GameSwitch {
    var collisionImpulseRequired = 10
    var bottomSwitch:WeightSwitchBottom?
    /** - TODO: In the future this will be deprecated and we'll inherit this from GameSwitch */
    var platformMoveToPos:WeightSwitchPlatformFinalPosition?
    /** - TODO: In the future this will be deprecated and we'll inherit this from GameSwitch */
    var platform:MoveablePlatform?
    var topOfSwitch:MultiDirectionalGravObject?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.contactTestBitMask = 1 | UInt32(PhysicsCategory.Minerals)
    }
    
    func setup() {
        self.children.forEach { (node) in
            if let node = node as? WeightSwitchBottom {
                self.bottomSwitch = node
            } else if let node = node as? WeightSwitchPlatformFinalPosition {
                self.platformMoveToPos = node
            } else if let node = node as? MoveablePlatform {
                self.platform = node
                self.platform?.moveToPoint = self.childNode(withName: "end")?.position
            } else if let node = node as? MultiDirectionalGravObject {
                self.topOfSwitch = node
            }
        }
    }
}

class WeightSwitchBottom : SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.contactTestBitMask = 1 | UInt32(PhysicsCategory.Minerals)
    }
}
class WeightSwitchPlatformFinalPosition : SKNode { }


class WeightSwitch5 : WeightSwitch {
    override func setup() {
        super.setup()
        self.topOfSwitch?.verticalForce = 5
    }
}

class WeightSwitch500 : WeightSwitch {
    override func setup() {
        super.setup()
        self.topOfSwitch?.verticalForce = 500
    }
}

class WeightSwitch50 : WeightSwitch {
    override func setup() {
        super.setup()
        self.topOfSwitch?.verticalForce = 500
    }
}

class WeightSwitch3000 : WeightSwitch {
    override func setup() {
        super.setup()
        self.topOfSwitch?.verticalForce = 3000
    }
}

class WeightSwitch5000 : WeightSwitch {
    override func setup() {
        super.setup()
        self.topOfSwitch?.verticalForce = 5000
    }
}


class WeightSwitch10000 : WeightSwitch {
    override func setup() {
        super.setup()
        self.topOfSwitch?.verticalForce = 10000
    }
}
