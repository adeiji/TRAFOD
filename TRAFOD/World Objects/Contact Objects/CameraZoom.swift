//
//  CameraZoom.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/30/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

/**
 Detects if the player is in a certain area where the zoom should be updated and if so updates the zoom
 
 The object needs to have xScale and yScale key value pairs set in the userData object
 
 When a player makes contact with this node, the camera is automatically zoomed in or out
 */
class CameraZoom: SKSpriteNode, ObjectWithManuallyGeneratedPhysicsBody {
    
    func setupPhysicsBody() {
        self.physicsBody = PhysicsHandler.getPhysicsBodyForContactOnlyObject(size: self.size)        
    }
    
    class func handleContact (_ contact: SKPhysicsContact, world: World) {
        guard
            let cameraZoom = contact.getNodeOfType(CameraZoom.self),
            let _ = contact.getNodeOfType(Player.self)
        else {
            return
        }
        
        guard
            let xScale = cameraZoom.userData?["xScale"] as? CGFloat,
            let yScale = cameraZoom.userData?["yScale"] as? CGFloat
        else {
            assertionFailure("There must be a key titled zoom that takes a float in the scene file")
            return
        }
        
        world.camera?.run(SKAction.scaleX(to: xScale, y: yScale, duration: 1.0))
    }
}
