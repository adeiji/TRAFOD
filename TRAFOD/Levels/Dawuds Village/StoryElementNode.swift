//
//  DawudsVillageStory.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 8/31/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit
import CoreGraphics

public struct StoryElement: Codable {
    
    public var x:Int;
    
    public var y:Int;
    
    public var text:String;
    
}

class StoryElementNode: SKSpriteNode {
    
    func displayNode (_ storyElement: StoryElement) {
        let node = SKSpriteNode(color: UIColor(red: 0.67, green: 0.58, blue: 0.37, alpha: 1.00), size: CGSize(width: 300, height: 100))
        let text = SKLabelNode(text: storyElement.text)
            
        text.fontColor = .white
        text.fontSize = 36.0
        text.fontName = "HelveticaNeue-Medium"
        text.position.y = text.position.y - 15
        if #available(iOS 11.0, *) {
            text.numberOfLines = 0
        } else {
            // Fallback on earlier versions
        }
        node.addChild(text)
        node.zPosition = 500
        text.zPosition = 400
        node.position.y = 0
        node.position.x = 0
        self.scene?.addChild(node)
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    
    func updateElement (_ player:Player) {
        
        let distanceFromPlayer = abs(self.CGPointDistanceSquared(from: player.position, to: self.position))
        
        if (distanceFromPlayer < 300) {
            if (self.alpha < 1) {
                SKAction.fadeIn(withDuration: 500)
                return
            }
        } else {
            if (self.alpha != 0) {
                SKAction.fadeOut(withDuration: 500)
            }
        }
    }
    
}
