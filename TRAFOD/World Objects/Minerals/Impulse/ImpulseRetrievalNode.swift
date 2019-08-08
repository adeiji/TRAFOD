//
//  ImpulseRetrievalNode.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 8/6/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class ImpulseRetrieveMineral : RetrieveMineralNode {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup (name: String) {
        self.mineralType = .IMPULSE
        let texture = SKTexture(imageNamed: MineralImageNames.Impulse)
        let action = SKAction.setTexture(texture, resize: true)
        self.run(action)
        self.setupPhysicsBody(size: texture.size())
    }
}

