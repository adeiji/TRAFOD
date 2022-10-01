//
//  DawudsVillageRuins.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/24/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class DawudsVillageRuins: Level {
    
    let gameElementsFilename = "DawudsVillageRuinsElements"

    
    override func didMove(to view: SKView) {
        self.currentLevel = .RuinsOfAnthril
        super.didMove(to: view)
        
        GameElementsInitializer.setupGameElementsFromJson(jsonFileName: self.gameElementsFilename, scene: self.scene)
        
        guard let nextLevelNode = self.children.first(where: { $0 is GotoLevelNode }) as? GotoLevelNode else {
            assertionFailure("There should be a node which takes you to the next level")
            return
        }
        
        nextLevelNode.nextLevel = .DawudVillage
    }
    

    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
    }
}
