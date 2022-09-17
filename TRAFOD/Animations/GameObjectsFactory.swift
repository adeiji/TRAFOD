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
    
    static func getObject (type: String) -> SKSpriteNode? {
        
        switch type {
        case Minerals.IMPULSE.rawValue:
            return ImpulseMineral()
        case Minerals.FLIPGRAVITY.rawValue:
            return FlipGravityMineral()
        case Minerals.ANTIGRAV.rawValue:
            return AntiGravityMineral()
        case PhysicsObjectTitles.ArrowLauncher:
            return ArrowLauncher()            
        default:
            return nil
        }
        
    }
    
    static func loadPlist <U:Codable>(fileName: String, type: U.Type) -> [U]? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "plist") else {
            return nil
        }
        
        let plistURL = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: plistURL) else { return nil }
        
        do {
            let templates = try PropertyListDecoder().decode([U].self, from: data)
            return templates
        } catch {
            print(error)
            return nil
        }
    }
    
}
