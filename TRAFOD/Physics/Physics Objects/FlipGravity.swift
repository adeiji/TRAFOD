//
//  FlipGravity.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/10/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

/// This is the base object for all objects within the game that affect the physics of other objects, for example FlipGravity inherits from PhysicsAlteringObject, as does MagneticForce
class PhysicsAlteringObject : SKSpriteNode, PortalPortocol {
    
    /**
     The force to apply to any contacted bodies to this object.  This method will be called at every update cycle of the game.  Make sure that you don't have too expensive of taaks within this method to ensure not bogging down resources
     
     - Parameter forceOfGravity: Whatever the force of gravity is that you want applied.  If you don't care about this, than just send the value of the current force of gravity which can be found in the world object
     
     - Parameter camera: The camera that this object is a child of
     
     
     */
    func applyForceToPhysicsBodies(forceOfGravity: CGFloat, camera: SKCameraNode?) {}
    
    func setCategoryBitmask() {}
    
    /**
     
     - Parameter contactPosition: The position that you want to add this object.  It's called contact position because generally one of these objects is generated due to a mineral making contact with the ground or another object.  The contactPosition would be the position in which the mineral makes contact.
     
     - Parameter size: The size that you want this object to be, defaults to width: 500, height: 500
     - Parameter color: The color you want this object to be.  When graphics are in this parameter will most likely be obsolete
     - Parameter anchorPoint: The anchor point for this object, defaults to (x: 0.5, y: 0).  For more information on SKSpriteNode anchor points, do a Google search for SKSpriteNode anchor points.
     
     */
    required init(contactPosition: CGPoint, size: CGSize?, color: UIColor?, anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
        super.init(texture: nil, color: color ?? .purple, size: size ?? CGSize(width: 500, height: 500))
        self.anchorPoint = anchorPoint
        self.position = contactPosition
        self.physicsBody = SKPhysicsBody(rectangleOf: size ?? self.size)
        self.physicsBody?.contactTestBitMask = 1
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Nothing)
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.pinned = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

/**
 FlipGravity is a SpriteNode which applies a force equal to the oppositive of gravity * 2 to whatever object affected by gravity that is in contact with it
 FlipGravity does not affect the gravity of the entire world, but only to objects in contact with it, and the FlipGravity node does not have a width of the full screen
 but instead it's a fixed width of x
 */
class FlipGravity : PhysicsAlteringObject {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(contactPosition: CGPoint, size: CGSize?, color: UIColor?, anchorPoint: CGPoint) {
        super.init(contactPosition: contactPosition, size: size ?? CGSize(width: 200, height: 2000), color: color ?? .purple, anchorPoint: anchorPoint)
        self.setCategoryBitmask()
    }
    
    internal override func setCategoryBitmask() {
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.FlipGravity)
    }
    
    /**
     Whatever the gravity is for the world currently, than we apply a force to all physics bodies in contact with it equal to the oppositive of the current force of gravity
     
     - Parameters:
        - forceOfGravity: CGFloat The current force applied to all objects within the physics world
        - camera: The camera node that is currently showing on the screen.  We need this to check if the physics body that is in contact with this node is actually on the screen
     
     - Note: See PhysicsAlteringObject.applyForceToPhysicsBodies for more information
     */
    override func applyForceToPhysicsBodies (forceOfGravity: CGFloat, camera: SKCameraNode?) {
        guard let physicsBody = self.physicsBody else {
            return
        }
        for body in physicsBody.allContactedBodies() {
            if let camera = camera?.parent {
                if let node = body.node {
                    if camera.contains(node.position) {
                        
                        switch node {
                        case is MovablePlatform:
                            continue
                        case is BaseWorldObject:
                            if let node = node as? BaseWorldObject {
                                if node.allowExternalForces == false {
                                    continue
                                }
                            }
                            
                            fallthrough
                        case is AffectedByNegationField:
                            if let node = node as? AffectedByNegationField {
                                if node.negatedForces[.FLIPGRAVITY] == true {
                                    continue
                                }
                            }
                            
                            fallthrough
                        default:
                            body.applyImpulse(CGVector(dx: 0, dy: (forceOfGravity * -1) * 5 * body.mass))
                            if let player = node as? Player {
                                if let world = World.getMainWorldFromNode(node: player) {
                                    world.player.flipPlayer(flipUpsideDown: true)
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
}
