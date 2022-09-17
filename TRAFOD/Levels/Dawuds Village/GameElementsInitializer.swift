//
//  DawudVillageGameElements.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/16/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class GameElementsInitializer {
    
    /**
     Adds game objects to a scene based off of the information given from a plist file
     */
    static func setupGameElements (plistFileName: String, scene: SKNode?) {
        guard let scene = scene else { return }
        let gameElements = GameObjectsFactory.loadPlist(fileName: plistFileName, type: GameElementTemplate.self)
        
        gameElements?.forEach({ element in
            guard let gameObject = GameObjectsFactory.getObject(type: element.name) else { return }
            gameObject.position = CGPoint(x: element.xPos, y: element.yPos)
            scene.addChild(gameObject)
            
            if let gameObject = gameObject as? LaunchingProtocol {
                gameObject.timeToFire = element.timeToFire ?? 3.0
            }
        })
    }
}
