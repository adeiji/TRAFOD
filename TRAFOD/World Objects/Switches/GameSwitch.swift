//
//  GameSwitch.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/22/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

// TODO: As of right now we are not including movable platform in this object, we need to make sure that we update that so that any new switches automatically inherit that

/**
 This is the basic switch for the Game.  Make sure that all switches inherit from the game switch object
 
 The GameSwitch object contains a MovablePlatform object and that object is the platform that will be moved when the user activates the switch
 
 */
class GameSwitch : SKSpriteNode, GameSwitchProtocol {
    
    var isOn:Bool = false
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: nil, color: .clear, size: CGSize())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func flipSwitchAndMovePlatform() -> Bool {
        // If this switch was just off and now is being turned on
        if self.isOn == false {
            self.isOn = true
            return true; // Move the platform from it's original position
        }
        
        return false
    }
}
