//
//  Constants.swift
//  TRAFOD
//
//  Created by adeiji on 6/18/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import Foundation
import GameKit

public class Scenes {
    public static let PurchaseMineralScreen = "PurchaseMineralScreen"
    public static let PurchaseMineralViewController = "purchaseMineralsViewController"
}

public class StoryFeatures {
    public static let Dawud = "Dawud"
    public static let Rhidahreuset = "Rhidahreueset"
    public static let Drust = "Drust"
    public static let RathTo = "Rath To"
    public static let Stilgar = "Stilgar"
    public static let Borothir = "Borothir"
    public static let Ravenhall = "Ravenhall"
}

public class GameNodes {
    public static let LeftBoundary = "leftBoundary"
    public static let RightBoundary = "rightBoundary"
    public static let SpeechBubble = "speechBubble"
    public static let CameraMinX = "cameraMinX"
}

public class SoundFiles {
    struct FX {
        public static let MineralGrab = "mineralgrab"
        public static let BirdsChirping = "birdschirping"
        public static let MineralCrash = "mineralcrash"
        public static let RunningStep = "running_step"
    }
}

public class Textures {
    struct Dawud {
        public static let Standing = "standing"
    }
    
    struct GameElements {
        public static let JumpButton = "jumpbutton"
    }
}

public class PhysicsObjectTitles {
    public static let Dawud = "dawud"
    public static let Portal = "portal"
    public static let Rock = "rock"
    public static let Ground = "ground"
    public static let CannonBall = "cannonball"
    public static let RopeType = "ropeType"
}

public class StoryFiles {
    public static let DawudVillage = "DawudsVillageStory"
}

enum Minerals: String, CaseIterable {
    case ANTIGRAV = "antigrav"
    case IMPULSE = "impulse"
    case TELEPORT = "teleport"
    case USED_TELEPORT = "teleport-mineral"
    case FLIPGRAVITY = "flipgravity"
    case MAGNETIC = "magnetic"
    case DESTROYER = "destroyer"
}

enum PhysicsAlteringObjectTypes {
    case FLIPGRAVITY
    case MAGNETIC
    case REMOVEROTATION
}

/// The GameLevel names, these should match the name of the sks files for each level
enum GameLevels: String, CaseIterable {
    case DawudVillage = "DawudVillage"
    case Level1 = "GameScene"
    case BookChapter2
    case Level2 = "Level2"
    case TransferLevel = "TransferLevel"
    case Level3 = "Level3"
    case Level4 = "Level4"
    case Level5 = "Level5"
    case Chapters = "Chapters"
}

enum BookChapters: CaseIterable {
    case Chapter1
}

public class ScreenButtonPositions {
    public static let AntiGravCounterNode = CGPoint(x: -870, y: 400)
    public static let AntiGravCounterLabel = CGPoint(x: -800,  y: 390)
    public static let AntiGravThrowButton = CGPoint(x: 453, y: -374)
    
    struct Impulse {
        public static let CounterNode = CGPoint(x: -470, y: 400)
    }
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
    case SLIDINGONWALL
    case CLIMBING
    case PULLINGROPE
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

enum PlayerClimbingState {
    case CLIMBINGLEFT
    case CLIMBINGRIGHT
    case CLIMBINGUP
    case CLIMBINGDOWN
    case STILL
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
    case BuyButton = "BuyButton"
}

/// THe image names for the minerals
public class MineralImageNames {
    public static let FlipGravity:String = ImageNames.BlueCrystal.rawValue
    public static let AntiGravity:String = ImageNames.BlueCrystal.rawValue
    public static let Magnetic:String = ImageNames.BlueCrystal.rawValue
    public static let Impulse:String = ImageNames.RedCrystal.rawValue
    public static let Teleport:String = ImageNames.RedCrystal.rawValue
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
        case .AntiGrav: return Minerals.ANTIGRAV.rawValue
        case .Impulse: return "Impulse"
        case .Teleport: return "Teleport"
        case .FlipGravity: return "FlipGravity"
        case .Magnetic: return "Magnetic"
        }
    }
}

