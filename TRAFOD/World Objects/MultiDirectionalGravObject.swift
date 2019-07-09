//
//  MultiDirectionalGravObject.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class MultiDirectionalGravObject : SKSpriteNode, AntiGravPlatformProtocol {
    
    // This is the yPos of where the cannon starts off at.  The cannon
    //will never go higher than this point, or lower than this point
    // depending on how gravity is handled
    var startingYPos: CGFloat!
    
    // The constant vector y force applied to the platform
    var verticalForce: CGFloat! = 2000
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.startingYPos = self.position.y
        
        let lockXPos = SKConstraint.positionX(SKRange(constantValue: 5))
        self.constraints = [lockXPos]
        self.physicsBody?.restitution = 0
    }

    func setConstraint () {

    }
    
    /**
     Applies an upward force to the platform.  Method is called at every game loop update
     */
    func applyUpwardForce () {
        if self.position.y < self.startingYPos - 3 {
            self.physicsBody?.applyForce(CGVector(dx: 0, dy: self.verticalForce))
        } else {
            self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        }
        
        self.physicsBody?.velocity.dx = 0
    }
}
