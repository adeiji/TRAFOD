//
//  FlipGravityMineral.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/10/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class FlipGravityMineral : Mineral, SKPhysicsContactDelegate {
    
    var mineralCrashColor: UIColor = .purple
    
    init() {
        let texture = SKTexture(imageNamed: ImageNames.BlueCrystal.rawValue)
        super.init(texture: texture)
    }
    
    class func throwMineral (player: Player, world: World) {
        let mineralNode = FlipGravityMineral()
        super.throwMineral(imageName: MineralImageNames.FlipGravity, player: player, world: world, mineralNode: mineralNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func mineralUsed (contactPosition: CGPoint) throws -> FlipGravity {        
        let flipGravity = FlipGravity(contactPosition: contactPosition, size: CGSize(width: 200, height: 2000), color: .purple, anchorPoint: CGPoint(x: 0.5, y: 0))
        flipGravity.zPosition = -5
        return flipGravity
    }
}
