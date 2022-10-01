//
//  PhysicsCategory.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation

/** All the categories for a physics body used within the game*/
struct PhysicsCategory {
    // TODO: Make these names less specific and be used as categories that cover multiple objects. Right now there's basically a category per object which is unecessary.
    static let CannonBall:Int32 = 0x1 << 4
    static let Minerals:Int32 = 0x1 << 6
    static let Reset:Int32 = 0x1 << 7
    static let Ground:Int32 = 0x1 << 8
    static let Cannon:Int32 = 0x1 << 9
    static let Player:Int32 = 0x1 << 10
    static let Rock:Int32 = 0x1 << 11
    static let GetObject:Int32 = 0x1 << 12
    static let FlipSwitch:Int32 = 0x1 << 13
    static let Doorway:Int32 = 0x1 << 14
    static let Portals:Int32 = 0x1 << 15
    static let Nothing:Int32 = 0x1 << 16
    static let Element:Int32 = 0x1 << 17
    static let PhysicsAltering:Int32 = 0x1 << 18
    static let Magnetic:Int32 = 0x1 << 19
    static let NegateForceField:Int32 = 0x1 << 20
    static let Impulse:Int32 = 0x1 << 21
    static let ForceField:Int32 = 0x1 << 22
    static let Fence:Int32 = 0x1 << 23
    static let SpringHolder:Int32 = 0x1 << 24
    static let Spring:Int32 = 0x1 << 25
    static let Rope:Int32 = 0x1 << 26
    static let Bridge:UInt32 = 0x1 << 27
    static let NonCollision:UInt32 = 0x1 << 28
    static let WeightSwitch:Int32 = 0x1 << 32        
}
