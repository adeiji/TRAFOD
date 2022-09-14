//
//  AnimationHandlerProtocol.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/13/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import UIKit

protocol AnimationHandlerProtocol: AnyObject {
    
    /// The player in the world. We need this object because at times the player needs to be interacted with to execute an animation
    var player:Player? { get }
    
    /// The scene in which to play this animation
    var scene:World? { get }
    
    /// The x position that the player needs to pass to kick start the animation
    var xPositionToPass:CGFloat { get }
    
    /// The object responsible for managing all the different animations
    var animationHandler:AnimationHandler? { get set }
    
    /// Responsible to check to see if there are any animations to be played and if there are then executing them.
    func checkForAnimations (playerXPos: CGFloat?, playerYPos: CGFloat?)
}
