//
//  FlipGravityRetrieveMineral.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/22/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class FlipGravityRetrieveMineral : RetrieveMineralNode {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup () {
        self.mineralType = .FLIPGRAVITY
        let texture = SKTexture(imageNamed: MineralImageNames.FlipGravity)
        let action = SKAction.setTexture(texture, resize: true)
        self.run(action)
        self.setupPhysicsBody(size: texture.size())
    }
}

class MagneticRetrieveMineral : RetrieveMineralNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup () {
        self.mineralType = .MAGNETIC
        let texture = SKTexture(imageNamed: MineralImageNames.Magnetic)
        let action = SKAction.setTexture(texture, resize: true)
        self.run(action)
        self.setupPhysicsBody(size: texture.size())
    }
}
