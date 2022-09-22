//
//  AntiGravRetrievalMineral.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/22/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class AntiGravityRetrieveMineral : RetrieveMineralNode {
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup (name: String) {
        super.setup(name: name)
        self.mineralType = .ANTIGRAV
        let texture = SKTexture(imageNamed: MineralImageNames.AntiGravity)
        let action = SKAction.setTexture(texture, resize: true)
        self.run(action)
    }
}
