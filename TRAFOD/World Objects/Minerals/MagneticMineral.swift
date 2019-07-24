//
//  MagneticMineral.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/22/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class MagneticMineral : Mineral, MineralProtocol {
    
    init() {
        let texture = SKTexture(imageNamed: MineralImageNames.Magnetic)
        super.init(texture: texture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func throwIt(player: Player, world: World) {
        super.throwMineral(imageName: MineralImageNames.Magnetic , player: player, world: world, mineralNode: MagneticMineral() )
    }
}

class Magnetic : PhysicsAlteringObject, PortalPortocol {
    
    internal func setCategoryBitmask() {
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Magnetic)
    }
    
    func applyForceToPhysicsBodies(forceOfGravity: CGFloat, camera: SKCameraNode?) {
        self.physicsBody?.allContactedBodies().forEach({ (body) in
            if let camera = camera?.parent {
                if let node = body.node {
                    if camera.contains(node.position) {
                        if node is MovablePlatform {
                            return
                        }
                        
                        let distanceToNode = UtilityFunctions.SDistanceBetweenPoints(first: self, second: node)
                        body.applyImpulse(CGVector(dx: 0, dy: 10 * body.mass / distanceToNode))
                    }
                }
            }
        })
    }
    
    required init(contactPosition: CGPoint, size: CGSize? = nil, color: UIColor? = nil, anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
        super.init(contactPosition: contactPosition, size: size ?? UIScreen.main.bounds.size, color: .orange)
        
        self.setCategoryBitmask()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
