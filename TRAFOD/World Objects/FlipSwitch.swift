//
//  FlipSwitch.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

protocol GameSwitchProtocol {
    var isOn:Bool? { get set }
    
    func flipSwitchAndMovePlatform () -> Bool
}

class GameSwitch : SKSpriteNode, GameSwitchProtocol {
    
    var isOn: Bool?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func flipSwitchAndMovePlatform() -> Bool {        
        // Check to see if there is currently a rock in contact with the switch
        if let contactedBodies = self.physicsBody?.allContactedBodies() {
            for body in contactedBodies {
                if let _ = body.node as? Rock {
                    // If this switch was just off and now is being turned on
                    if self.isOn == false {
                        return true; // Move the platform from it's original position
                    }
                    
                    self.isOn = true
                    return false
                }
            }
            
            // If this switch was just on and now is being turned off
            if self.isOn == true {
                return true // Move the platform back to its original position
            }
            self.isOn = false
            return false
        }
        
        self.isOn = false;
        return false
    }
}

class FlipSwitch : GameSwitch {
    
    var movablePlatform:MovablePlatform? {
        didSet {
            let constraint = SKConstraint.positionY(SKRange(constantValue: self.movablePlatform?.position.y ?? 0))
            self.movablePlatform?.constraints = [constraint]
        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.physicsBody?.categoryBitMask = 0b0001
    }
    
    /**
     Turns the switch to the opposite of whatever it's current setting is, ex: If on, set to off
     */
    func flipSwitch () {
        if super.flipSwitchAndMovePlatform() {
          self.movablePlatform?.move()
        }
    }
}
