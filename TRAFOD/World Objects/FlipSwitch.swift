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
    var isOn:Bool { get set }
    
    func flipSwitchAndMovePlatform () -> Bool
}

class GameSwitch : SKSpriteNode, GameSwitchProtocol {
    
    var isOn:Bool = false
    
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
                        self.isOn = true
                        return true; // Move the platform from it's original position
                    }
                    
                    return false
                }
            }
            
            // If this switch was just on and now is being turned off
            if self.isOn == true {
                self.isOn = false
                return true // Move the platform back to its original position
            }
            return false
        }
        
        return false;
    }
}

class FlipSwitchComponent : SKSpriteNode { }

class FlipSwitch : GameSwitch {
    
    var movablePlatform:MovablePlatform? {
        didSet {
            let constraint = SKConstraint.zRotation(SKRange(constantValue: self.movablePlatform?.zRotation ?? 0))
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
    
    /**
     Flips the switch from on to off
     */
    class func flipSwitch(contact: SKPhysicsContact) {
        if let node = contact.bodyA.node as? FlipSwitch {
            node.flipSwitch()
        } else if let node = contact.bodyB.node as? FlipSwitch {
            node.flipSwitch()
        }
    }
    
    func setMovablePlatformWithTimeInterval (timeInterval: TimeInterval) {
        self.children.forEach { (node) in
            if let node = node as? MovablePlatform {
                self.movablePlatform = node
                self.setEndPointAndTimeInterval(timeInterval: timeInterval)
            }
        }
    }
    
    private func setEndPointAndTimeInterval (timeInterval: TimeInterval) {
        self.children.forEach { (node) in
            if let node = node as? WeightSwitchPlatformFinalPosition {
                self.movablePlatform?.moveToPoint = node.position
                self.movablePlatform?.moveDuration = timeInterval
                return;
            }
        }
    }
}
