//
//  GameElementTemplate.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/16/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation

/**
 The template for a game element. Game elements are created by storing the information within a plist file. 
 */
struct GameElementTemplate: Codable {
    
    let name:String
    let xPos:Double
    let yPos:Double
    let timeToFire:Double?
    
}
