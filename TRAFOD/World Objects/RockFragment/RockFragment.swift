//
//  RockFragment.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/13/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class RockFragment: Ground {
    
    let fragmentDimensions = (width: 150.00, height: 150.0)
    
    override init(size: CGSize, anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
        super.init(size: size)
        self.name = "rockFragment"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     Show the rock fragment crumble and basically fall apart into multiple ground objects
     **/
    public func breakApart () {
        var groundFragmentPosition = CGPoint(x: self.position.x - (self.size.width / 2.0), y: self.position.y - (self.size.height / 2.0))
        let startingXPos = groundFragmentPosition.x
        
        for y in 0...Int(self.size.height / fragmentDimensions.height) {
            groundFragmentPosition.x = startingXPos
            
            for x in 0...Int(self.size.width / fragmentDimensions.width) {
                let groundFragment = Ground(size: CGSize(width: fragmentDimensions.width, height: fragmentDimensions.height))
                
                groundFragment.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Ground)
                groundFragment.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.Ground)
                groundFragment.physicsBody?.affectedByGravity = true
                
                
                groundFragment.position = groundFragmentPosition
                groundFragment.color = .white
                groundFragment.physicsBody?.allowsRotation = true
                
                self.scene?.addChild(groundFragment)
                
                groundFragment.physicsBody?.applyImpulse( CGVector(dx: CGFloat.random(in: -100...100), dy: CGFloat.random(in: -100...100)) )
                                
                let newXPosition = CGFloat((x + 1 * Int(fragmentDimensions.width) + 20))
                
                groundFragmentPosition = CGPoint(x: groundFragmentPosition.x + newXPosition, y: groundFragmentPosition.y)
            }
            
            groundFragmentPosition.y = (groundFragmentPosition.y) + (fragmentDimensions.height + 20)
        }
        
        self.removeFromParent()
    }
}
