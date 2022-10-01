//
//  AnimationTemplate.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/14/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import UIKit

/**
 The structure for an object that determines how an animation behaves
 
 Animations are stored within plist or json files and then read and executed within AnimationHandler classes
 */
struct AnimationTemplate: Codable {
    
    let playerXPos:Double
    let shouldRotate:Bool?
    let startingPosition:XYValue
    let item:String
    let impulse:XYValue?
    let name:String
    
}

struct XYValue: Codable {
    let x:Double
    let y:Double
}
