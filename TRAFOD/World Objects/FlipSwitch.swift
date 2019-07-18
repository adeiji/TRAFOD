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
        // If this switch was just off and now is being turned on
        if self.isOn == false {
            self.isOn = true
            return true; // Move the platform from it's original position
        }
       
        return false
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
    }
    
    func setupPhysicsBody () {
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Nothing)
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.FlipSwitch)
        self.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.CannonBall) | UInt32(PhysicsCategory.Rock)
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
