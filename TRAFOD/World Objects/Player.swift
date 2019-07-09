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
    public var grabbedObject:SKNode?
    public var objectThatCanBeGrabbed:SKNode?
    public var playerState:PlayerState?
    
    func grabObject (object: SKNode) {
        self.grabbedObject = object
    }
    
    func letGoOfObject () {
        self.grabbedObject = nil
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
