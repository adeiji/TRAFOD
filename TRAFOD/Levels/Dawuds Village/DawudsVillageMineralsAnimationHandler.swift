//
//  DawudsVillageMineralsAnimationHandler.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/14/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class DawudsVillageMineralsAnimationHandler: AnimationHandlerProtocol {
    
    /// See AnimationHandlerProtocol
    var player: Player?
    
    /// See AnimationHandlerProtocol
    var scene: World?
    
    /// See AnimationHandlerProtocol
    var xPositionToPass: CGFloat = 0.0
    
    /// See AnimationHandlerProtocol
    var animationHandler: AnimationHandler?
        
    var animationTemplates:[AnimationTemplate]?
    
    struct AnimationPropertyListConstants {
        let playerXPos = "playerXPos"
    }
    
    init(fileName: String, player: Player, scene: World) {
        self.animationTemplates = GameObjectsFactory.loadFile(fileName: fileName, type: AnimationTemplate.self, fileType: "json")
        self.player = player
        self.scene = scene
    }
    
    func checkForAnimations(playerXPos: CGFloat?, playerYPos: CGFloat?) {
        guard let animationTemplates = self.animationTemplates else { return }
        for template in animationTemplates {
            if let playerXPos = playerXPos, playerXPos > template.playerXPos {
                self.animationTemplates = self.animationTemplates?.filter({ $0.name != template.name })
                self.executeAnimation(template)
            }
        }
    }
    
    func executeAnimation (_ animationTemplate: AnimationTemplate) {
        let object = GameObjectsFactory.getObject(type: animationTemplate.item)
                
        if let object = object {
            self.scene?.addChild(object)
        }
        
        if animationTemplate.shouldRotate == true {
            let rotate = SKAction.rotate(byAngle: CGFloat.pi / 2, duration: 0.001)
            object?.run(SKAction.repeatForever(rotate))
        }
        
        object?.position = CGPoint(x: animationTemplate.startingPosition.x, y: animationTemplate.startingPosition.y)
        
        print("Executing animation: \(animationTemplate.name)")

        if let impulse = animationTemplate.impulse {
            object?.physicsBody?.applyImpulse(CGVector(dx: impulse.x, dy: impulse.y))
        }

    }
    
}
