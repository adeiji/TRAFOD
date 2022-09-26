//
//  AnimationFactory.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/14/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

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
            return nil
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
