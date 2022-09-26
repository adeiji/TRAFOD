//
//  RetrieveMineralNode.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/22/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class RetrieveMineralNode : SKSpriteNode, SKPhysicsContactDelegate {
    
    var world:World?
    var mineralType:Minerals!    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     Adds the current element to the elements that the user has collected
     
     - parameters:
     - node The node that has been collected. ie: antigrav-mineral1
     
     */
    func addToCollectedElements (node:SKNode) {
        node.removeFromParent()
        if let level = self.world?.currentLevel {
            if self.world?.collectedElements[level] == nil {
                self.world?.collectedElements[level] = [String]()
            }
            
            if let name = node.name {
                self.world?.collectedElements[level]?.append(name)
                if let currentLevel = self.world?.currentLevel {
                    ProgressTracker.updateElementsCollected(level: currentLevel.rawValue, node: name)
                }
            }
        }
    }
    
    /**
     
     When the player collides with a mineral and retrieves it if it's the first time then we display a box that shows player how to use the mineral or it simply adds ten more minerals to the player's mineral count
     
     - Parameter type: The type of Mineral that the player is getting
     
     */
    func getMineral (type: Minerals) {
        if var mineralCount = self.world?.player.mineralCounts[type] {
            mineralCount = mineralCount + 1
            self.world?.player.mineralCounts[type] = mineralCount
            ProgressTracker.updateMineralCount(myMineral: type, count: mineralCount)
        } else {
            self.world?.player.mineralCounts[type] = 10;
            ProgressTracker.updateMineralCount(myMineral: type, count: 10)
        }
        
        self.world?.playMineralSound()
    }
    
    func setupPhysicsBody (size: CGSize) {
        self.physicsBody = PhysicsHandler.getPhysicsBodyForRetrievableObject(size: size)
    }
    
    func setup(name: String) {
        self.setupPhysicsBody(size: self.size)
        self.name = name
    }
}
