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
            gameObject.position = CGPoint(x: element.x, y: element.y)
            
            if let gameObject = gameObject as? FlipSwitch {
                GameElementsInitializer.setupFlipSwitch(flipSwitch: gameObject, gameObjectTemplate: element, scene: scene)
                return
            }
            
            scene.addChild(gameObject)
            
            if let gameObject = gameObject as? LaunchingProtocol {
                gameObject.timeToFire = element.timeToFire ?? 3.0
            }
        })
    }
    
    static func setupFlipSwitch (flipSwitch: FlipSwitch, gameObjectTemplate: GameElementTemplate, scene: SKNode) {
                    
        // Get the final position that the moving platform is going to reach
        guard let finalPosition = gameObjectTemplate.children?.filter({ $0.name == PhysicsObjectTitles.WeightPlatformFinalPosition }).first else {
            assertionFailure("A FlipSwitch should have a child with name \(PhysicsObjectTitles.WeightPlatformFinalPosition)")
            return
        }
        
        // get the starting position of the moving platform
        guard let startPos = gameObjectTemplate.children?.filter({ $0.name == PhysicsObjectTitles.MoveablePlatform }).first else {
            assertionFailure("A FlipSwitch should have a child with name \(PhysicsObjectTitles.MoveablePlatform)")
            return
        }
        
        guard let size = gameObjectTemplate.size else { return }
        
        // Setup the flip switch with the parameters received from the game object template
        flipSwitch.switchParams = FlipSwitchParams(
            switchPos: CGPoint(x: gameObjectTemplate.x, y: gameObjectTemplate.y),
            startPos: CGPoint(x: startPos.x, y: startPos.y),
            endPos: CGPoint(x: finalPosition.x, y: finalPosition.y),
            platformSize: CGSize(width: size.width, height: size.height))
        
        scene.addChild(flipSwitch)
    }
}
