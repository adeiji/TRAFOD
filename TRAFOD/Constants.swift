//
//  Constants.swift
//  TRAFOD
//
//  Created by adeiji on 6/18/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import Foundation
import GameKit

/// The GameLevel names, these should match the name of the sks files for each level
public class GameLevels {
    public static let Level1 = "GameScene"
    public static let Level2 = "Level2"
    public static let TransferLevel = "TransferLevel"
    public static let Level3 = "Level3"
    public static let Level4 = "Level4"
    public static let Level5 = "Level5"
    public static let Chapters = "Chapters"
}

public class ScreenButtonPositions {
    public static let AntiGravCounterNode = CGPoint(x: -870, y: 400)
    public static let AntiGravCounterLabel = CGPoint(x: -800,  y: 390)
    public static let AntiGravThrowButton = CGPoint(x: 453, y: -374)    
}

/** The different states that the player can be in  The player is not capable of being in more than one of these states at one time
 
 The player can only be in one of the following states:
    - INAIR
    - JUMP
    - ONGROUND
    - HITPORTAL
    - DEAD
    - GRABBING
 */
enum PlayerState {
    case INAIR
    case JUMP
    case ONGROUND
    case HITPORTAL
    case DEAD
    case GRABBING
}

/**
 The state of the player if he is running.  It's not possible for the player to be in multiple running states at the same time.
 
 The player can be in one of three states
 
    - RUNNINGLEFT
    - RUNNINGRIGHT
    - STANDING
 */
enum PlayerRunningState {
    case RUNNINGLEFT
    case RUNNINGRIGHT
    case STANDING
}

/// The current action of the player.  For example, is the player currently throwing an mineral
enum PlayerAction {
    case THROW
    case NONE
}

/// The image names for various objects within the game
enum ImageNames: String {
    case BlueCrystal = "Blue Crystal"
    case RedCrystal = "Red Crystal"
}

/// THe image names for the minerals
public class MineralImageNames {
    public static let FlipGravity:String = ImageNames.BlueCrystal.rawValue
    public static let AntiGravity:String = ImageNames.BlueCrystal.rawValue
    public static let Magnetic:String = ImageNames.BlueCrystal.rawValue
}

/// The nodes that are used to display the number of minerals that the player currently has
enum CounterNodes: CaseIterable, CustomStringConvertible {
    case CounterNode
    case Label
    case ThrowButtonNode
    case AntiGrav
    case Impulse
    case Teleport
    case FlipGravity
    case Magnetic
    
    var description: String {
        switch self {
        case .CounterNode: return "CounterNode"
        case .Label: return"Label"
        case .ThrowButtonNode: return "ThrowButtonNode"
        case .AntiGrav: return "AntiGrav"
        case .Impulse: return "Impulse"
        case .Teleport: return "Teleport"
        case .FlipGravity: return "FlipGravity"
        case .Magnetic: return "Magnetic"
        }
    }
}

