//
//  FlipSwitch.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class FlipSwitch : SKSpriteNode {
    
    var isOn:Bool = false
    var movablePlatform:MovablePlatform? {
        didSet {
            let constraint = SKConstraint.positionY(SKRange(constantValue: self.movablePlatform?.position.y ?? 0))
            self.movablePlatform?.constraints = [constraint]
        }
    }
    
    var movablePlatformOffSetPoint:CGPoint?
    var movablePlatformMovementDuration:TimeInterval?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.categoryBitMask = 0b0001
    }
    
    /**
     Moves a node to a specificied position
     
     - Parameter nodeName: The name of the node to move
     - Parameter xOffset: How far to move in the x direction
     - Parameter yOffset: How far to move in the y direction
     - Parameter duration: How long to take to move the node
     
     */
    func movePlatform () {
        if let node = self.movablePlatform {
            if var offset = self.movablePlatformOffSetPoint {
                if node.finishedMoving {
                    offset.x = offset.x * -1
                    offset.y = offset.y * -1
                    node.finishedMoving = false
                } else {
                    node.finishedMoving = true
                }
                
                let move = SKAction.moveBy(x: offset.x, y: offset.y, duration: self.movablePlatformMovementDuration ?? 0)                
                node.physicsBody?.pinned = false
                node.removeAllActions()
                node.run(move) {
                    node.physicsBody?.pinned = true
                }
            }
        }
    }
    
    /**
     Turns the switch to the opposite of whatever it's current setting is, ex: If on, set to off
     */
    func flipSwitch () {
        // Check to see if there is currently a rock in contact with the switch
        if let contactedBodies = self.physicsBody?.allContactedBodies() {
            for body in contactedBodies {
                if let _ = body.node as? Rock {
                    self.texture = SKTexture(imageNamed: "switch-on")
                    // If this switch was just off and now is being turned on
                    if self.isOn == false {
                        self.movePlatform() // Move the platform from it's original position
                    }
                    
                    self.isOn = true
                    return
                }
            }
            
            // If this switch was just on and now is being turned off
            if self.isOn == true {
                self.movePlatform() // Move the platform back to its original position
            }
            self.isOn = false
            self.texture = SKTexture(imageNamed: "switch-off")
            return
        }
        
        self.isOn = false;
    }
}
