//
//  PhysicsCategory.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation

struct PhysicsCategory {
    static let InteractableObjects:Int32 = 0x1 << 3
    static let CannonBall:Int32 = 0x1 << 4
    static let NonInteractableObjects:Int32 = 0x1 << 5
    static let Minerals:Int32 = 0x1 << 6
    static let Reset:Int32 = 0x1 << 7
    static let Ground:Int32 = 0x1 << 8
    static let Cannon:Int32 = 0x1 << 9
    static let Player:Int32 = 0x1 << 10
    static let Rock:Int32 = 0x1 << 11
    static let GetMineralObject:Int32 = 0x1 << 12
    static let FlipSwitch:Int32 = 0x1 << 13
    static let Nothing:Int32 = 0x1 << 16
    static let WeightSwitch:Int32 = 0x1 << 32
    
    
}
