//
//  Level2.swift
//  TRAFOD
//
//  Created by adeiji on 6/25/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import Foundation
import GameKit
import SpriteKit

class Level2 : Level {
    
    override func didMove(to view: SKView) {        
        self.currentLevel = .LEVEL2
        super.didMove(to: view)
        self.playBackgroundMusic(fileName: "level3")
    }
}
