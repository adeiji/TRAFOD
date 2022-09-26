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
    
    var cameraUpdates = [
        (point: CGPoint(x: 2435, y: 400), scale: 1.5, id: "second-puzzle"),
        (point: CGPoint(x: -1000, y: -500), scale: 1, id: "beginning")
    ]
    var currentCameraState:String = ""
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        GameElementsInitializer.setupGameElementsFromJson(jsonFileName: self.gameElementsFilename, scene: self.scene)
    }
    
    private func updateCamera () {
        for i in 0..<self.cameraUpdates.count {
            let update = self.cameraUpdates[i]
            
            if self.player.position.x > update.point.x && self.player.position.y > update.point.y {
                if self.currentCameraState == update.id { return }
                self.camera?.run(SKAction.scaleX(to: update.scale, y: update.scale, duration: 1.0))
                self.currentCameraState = update.id
                return
            }
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        self.updateCamera()
    }
}
