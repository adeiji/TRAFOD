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
    public static let Level1 = "GameScene"
    public static let Level2 = "Level2"
    public static let TransferLevel = "TransferLevel"
    public static let Level3 = "Level3"
    public static let Level4 = "Level4"
    public static let Chapters = "Chapters"
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

public class MineralImageNames {
    public static let FlipGravity:String = ImageNames.BlueCrystal.rawValue
    public static let AntiGravity:String = ImageNames.BlueCrystal.rawValue
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

