//
//  Constants.swift
//  TRAFOD
//
//  Created by adeiji on 6/18/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import Foundation
import GameKit

public class GameLevels {
    public static let level1 = "GameScene"
    public static let level2 = "Level2"
    public static let transferLevel = "TransferLevel"
    public static let level3 = "Level3"
}

enum PlayerState {
    case INAIR
    case JUMP
    case ONGROUND
    case HITPORTAL
    case DEAD
    case GRABBING
}

enum PlayerRunningState {
    case RUNNINGLEFT
    case RUNNINGRIGHT
    case STANDING
}

enum PlayerAction {
    case THROW
    case NONE
}

enum ImageNames: String {
    case BlueCrystal = "Blue Crystal"
    case RedCrystal = "Red Crystal"
}

enum CounterNodes: CustomStringConvertible {
    case CounterNode
    case Label
    case ThrowButtonNode
    case AntiGrav
    case Impulse
    case Teleport
    case FlipGravity
    
    var description: String {
        switch self {
        case .CounterNode: return "CounterNode"
        case .Label: return"Label"
        case .ThrowButtonNode: return "ThrowButtonNode"
        case .AntiGrav: return "AntiGrav"
        case .Impulse: return "Impulse"
        case .Teleport: return "Teleport"
        case .FlipGravity: return "FlipGravity"
        }
    }
}

