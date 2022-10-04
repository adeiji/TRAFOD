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
    let x:Double
    let y:Double
    let id:String?
    let direction:String?
    let duration:Double?
    let message:String?
    let timeToFire:Double?
    let children:[GameElementTemplate]?
    let size:Size?
    let velocity:Double?
}

struct Size: Codable {
    let width:Double
    let height:Double
}
