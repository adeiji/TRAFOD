//
//  GotoLevelNode.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/24/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

protocol Scene {
    var nextLevel:GameLevels? { get set }
    var nextBookChapter:BookChapters? { get set }
}

/**
 When the user hits this node then the we take the player to the next level
 */

class GotoLevelNode : SKSpriteNode, ObjectWithManuallyGeneratedPhysicsBody, Scene {
    
    /// The next level to take the player to.  Defaults to Level2
    var nextLevel:GameLevels? = .Level2
    var nextBookChapter: BookChapters?
    
    func setupPhysicsBody() {
        self.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.Doorway)
        self.physicsBody?.collisionBitMask = 1
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.pinned = true
    }
}

class GotoLevel2 : GotoLevelNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nextLevel = .Level2
    }
}

class GotoLevel3 : GotoLevelNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nextLevel = .Level3
    }
}

class GotoLevel4 : GotoLevelNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nextLevel = .Level4
    }
}


class GotoLevel5 : GotoLevelNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)        
        self.nextLevel = .Level5
    }
}

class GotoTransferLevel : GotoLevelNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nextBookChapter = .Chapter1
    }
}


