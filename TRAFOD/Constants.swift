//
//  Constants.swift
//  TRAFOD
//
//  Created by adeiji on 6/18/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import Foundation


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
