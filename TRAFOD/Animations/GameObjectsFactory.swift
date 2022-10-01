//
//  AnimationFactory.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/14/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

/**
 Responsible for creating game objects
 
 The best way to use this is to keep your game object information stored within a **json** or **plist** file and then call the static func loadFile of this class to get the object templates.
 
 You can then use these templates to get the actual objects using the static getObject method of this class
 */
class GameObjectsFactory {
    
    static func getObject (type: String) -> SKNode? {
        
        switch type {
        case Minerals.IMPULSE.rawValue:
            return ImpulseMineral()
        case Minerals.FLIPGRAVITY.rawValue:
            return FlipGravityMineral()
        case Minerals.ANTIGRAV.rawValue:
            return AntiGravityMineral()
        case PhysicsObjectTitles.ArrowLauncher:
            return ArrowLauncher()
        case PhysicsObjectTitles.DiaryFragment:
            return DiaryPieceNode()
        case PhysicsObjectTitles.WeightPlatformFinalPosition:
            return WeightSwitchPlatformFinalPosition()
        case PhysicsObjectTitles.FlipSwitch:
            return FlipSwitch()
        default:
            return nil
        }
    }
    
    static func loadFile <U:Codable>(fileName: String, type: U.Type, fileType:String) -> [U]? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else {
            return nil
        }
        
        let fileUrl = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: fileUrl) else { return nil }
        
        do {
            if fileType == "plist" {
                let templates = try PropertyListDecoder().decode([U].self, from: data)
                return templates
            } else {
                let data = try Data(contentsOf: fileUrl)
                let templates = try JSONDecoder().decode([U].self, from: data)
                return templates
            }
            
        } catch {
            print(error)
            return nil
        }
    }
    
}
