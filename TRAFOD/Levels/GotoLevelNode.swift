//
//  GotoLevelNode.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/24/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

/**
 When the user hits this node then the we take the player to the next level
 */

class GotoLevelNode : SKSpriteNode, ObjectWithManuallyGeneratedPhysicsBody {
    
    /// The next level to take the player to.  Defaults to Level1
    var nextLevel:String = GameLevels.Level1
    
    func setupPhysicsBody() {
        self.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.Doorway)
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.pinned = true
    }
}

class GotoLevel5 : GotoLevelNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)        
        self.nextLevel = GameLevels.Level5
    }
}
