//
//  RopeBridge.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/14/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

/**
    A rope bridge is a SKSpriteNode that is a bridge with two vines (ropes) that connect it to a certain point. The unique thing about this type of bridge is that it can swing back and forth, therefore physics affects it
 */
class RopeBridge: SKNode {
    
    var ropes = (
        leftRope: VineNode(length: 6, anchorPoint: CGPoint(x: -200, y: 0), name: "ropeBridge", segmentLength: 45),
        rightRope: VineNode(length: 6, anchorPoint: CGPoint(x: 0, y: 0), name: "ropeBridge", segmentLength: 45)
    )
    
    init(position: CGPoint) {
        super.init()
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     Setup the rope bridge objects and add them to the given scene
     
     - Parameters:
        - scene: The scene in which to add the rope bridge, most likely this is the scene of the Level object the rope bridge is to be added to
     
     - NOTE: When we set the **collisionBitMask** of the bridge, everything goes haywire.
        
     Not really sure why, not sure if it's a bug in the system or what, but as soon as it's set, even if we set it to collide with nothing, the bridge begins to cause chaos within the ropes
     */
    func setup (scene: SKScene) {
        
        let bridge = SKSpriteNode(color: .blue, size: CGSize(width: 300, height: 75))
        bridge.physicsBody = SKPhysicsBody(rectangleOf: bridge.size)
        
        ropes.leftRope.addToScene(self)
        ropes.rightRope.addToScene(self)
        
        guard
            let bridgePhysicsBody = bridge.physicsBody,
            let leftSegment = ropes.leftRope.segments.last?.physicsBody,
            let rightSegment = ropes.rightRope.segments.last?.physicsBody
        else { return }
                
        bridge.physicsBody?.mass = 5
        bridge.position = leftSegment.node!.position
        
        
                        
        ropes.leftRope.addChild(bridge)
                
        ropes.leftRope.ropeTypeHolder?.color = .orange
        
        let leftRopeLastSegmentPosition = ropes.leftRope.convert( leftSegment.node!.position , to: scene )
        let rightRopeLastSegmentPosition = ropes.rightRope.convert( rightSegment.node!.position, to: scene )
        
        let leftRopeJoint = SKPhysicsJointPin.joint(withBodyA: bridgePhysicsBody, bodyB: leftSegment, anchor: leftRopeLastSegmentPosition)
        let rightRopeJoint = SKPhysicsJointPin.joint(withBodyA: bridgePhysicsBody, bodyB: rightSegment, anchor: rightRopeLastSegmentPosition)

        scene.physicsWorld.add(leftRopeJoint)
        scene.physicsWorld.add(rightRopeJoint)
        
    }
    
}
