//
//  MagneticMineral.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/22/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class MagneticMineral : Mineral, MineralProtocol, UseMinerals {
    
    init() {
        super.init(mineralType: .MAGNETIC)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func mineralUsed(contactPosition: CGPoint, world:World) throws -> PhysicsAlteringObject? {
        let magnetic = MagneticForce(contactPosition: contactPosition)
        return magnetic
    }
}

class MagneticForce : PhysicsAlteringObject {
    
    internal override func setCategoryBitmask() {
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Magnetic)
    }
    
    override func applyForceToPhysicsBodies(forceOfGravity: CGFloat, camera: SKCameraNode?) {}
    
    required init(contactPosition: CGPoint, size: CGSize? = nil, color: UIColor? = nil, anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
        super.init(contactPosition: contactPosition, size: size ?? UIScreen.main.bounds.size, color: .clear)
        self.addRadialGravField()
        self.setCategoryBitmask()
    }
    
    /**
     Adds a radial gravitational field to this object that will attract objects within the game towards it
     */
    func addRadialGravField () {
        let radialGravField = SKFieldNode.radialGravityField()
        radialGravField.strength = 25
        let size = UIScreen.main.bounds.size
        radialGravField.region = SKRegion(size: CGSize(width: size.width, height: size.height))
        radialGravField.categoryBitMask = UInt32(PhysicsCategory.Magnetic)
        radialGravField.falloff = 0.5
        radialGravField.minimumRadius = 50
        self.addChild(radialGravField)
        
        radialGravField.addChild(SKSpriteNode(color:SKColor.red, size:CGSize(width: 50.0, height: 50.0)))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
