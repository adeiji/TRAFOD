//
//  MagneticRetrieveMineral.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 8/6/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class MagneticRetrieveMineral : RetrieveMineralNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup (name: String) {
        self.mineralType = .MAGNETIC
        let texture = SKTexture(imageNamed: MineralImageNames.Magnetic)
        let action = SKAction.setTexture(texture, resize: true)
        self.run(action)
        self.setupPhysicsBody(size: texture.size())
    }
}
