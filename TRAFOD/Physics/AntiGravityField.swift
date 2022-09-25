//
//  AntiGravityField.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/24/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

/** An object (field) which changes the gravity of objects within the game. Not all objects that come into contact with this field have their physics altered. There are other factors involved such as if the object is one that resist this fields gravitational force */
class AntiGravityField: PhysicsAlteringObject {
    
    let timeFieldActive = 5.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(contactPosition: CGPoint, size: CGSize?, color: UIColor?, anchorPoint: CGPoint) {
        super.init(contactPosition: contactPosition, size: size ?? CGSize(width: 400, height: 2000), color: color ?? .purple, anchorPoint: anchorPoint)
        self.setCategoryBitmask()
    }
    
    internal override func setCategoryBitmask() {
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.PhysicsAltering)
        self.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Nothing)
        
    }
    
    override func applyForceToPhysicsBodies(forceOfGravity: CGFloat, camera: SKCameraNode?) {
        guard let physicsBody = self.physicsBody else { return }
        for body in physicsBody.allContactedBodies() {
            guard let world = self.parent as? World else { return }
            if body.node is Player {
                body.applyImpulse(CGVector(dx: 0, dy: world.physicsWorld.gravity.dy * -2))
            } else if let rock = body.node as? Rock, let rockMass = rock.massConstant {
                rock.physicsBody?.mass = rockMass / 2.0
            }
        }
    }
    
    /**
     Displays to the user visually that there has been a mineral used, and where it's bounds are.
     
     - Parameters:
        - point: The point in which to show an explosion, ideally the point where the mineral made contact with the ground
        - world: The world object to add the views and emitters to
     
     */
    func showMineralEffectOnView (point: CGPoint, world: World) {
        guard let emitter = SKEmitterNode(fileNamed: ParticleFiles.MineralExplosion.rawValue) else {
            return
        }
        
        // Place the emitter at the rear of the ship.
        emitter.position = self.position
        emitter.name = "explosion"
        
        // Send the particles to the scene.
        emitter.targetNode = world
        world.addChild(emitter)
        
        // Add a view over the entire screen that makes the entire screen darker
        guard let camera = world.camera else { return }
        let darkView = SKSpriteNode(color: .black, size: world.size)
        darkView.position = CGPoint(x: 0, y: 0)
        darkView.zPosition = ZPositions.Layer3
        darkView.alpha = 0.7
        camera.addChild(darkView)
        
        // Create the Emitter which displays the gravity field being created
        guard let mineralUsedEmitter = SKEmitterNode(fileNamed: ParticleFiles.MineralUsed.rawValue) else {
            return
        }
        
        mineralUsedEmitter.position = self.position
        mineralUsedEmitter.name = "antigravfield"
        mineralUsedEmitter.targetNode = world
        world.addChild(mineralUsedEmitter)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            mineralUsedEmitter.particleAlpha = mineralUsedEmitter.particleAlpha - 0.2
        }
        
        Timer.scheduledTimer(withTimeInterval: self.timeFieldActive, repeats: false) { timer in
            emitter.removeFromParent()
            darkView.removeFromParent()
            mineralUsedEmitter.removeFromParent()
            if let index = world.forces.firstIndex(of: .ANTIGRAV) {
                world.forces.remove(at: index)
            }
            
            self.removeFromParent()
        }
    }
}
