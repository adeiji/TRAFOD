//
//  Player.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/8/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class Player : SKSpriteNode {
    
    public var hasAntigrav = false
    public var hasImpulse = false
    public var hasTeleport = false
    public var mineralCounts = [Minerals:Int]()
    public var strength:CGFloat = 10.0
    public var grabbedObject:SKSpriteNode?
    public var objectThatCanBeGrabbed:SKSpriteNode?
    
    public var state:PlayerState = .ONGROUND
    public var runningState:PlayerRunningState = .STANDING
    public var previousRunningState:PlayerRunningState = .STANDING
    public var action:PlayerAction = .NONE
            
    func grabObject (object: SKSpriteNode) {
        self.grabbedObject = object
    }
    
    func letGoOfObject () {
        self.grabbedObject = nil
        self.state = .ONGROUND
        self.constraints = [];        
    }
    
    func isGrabbingObject () -> Bool {
        if self.grabbedObject == nil {
            return false
        }
        
        return true
     }
    
    func stop () {
        self.physicsBody?.velocity = CGVector(dx: 0, dy: self.physicsBody?.velocity.dy ?? 0)
    }
}
