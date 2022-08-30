//
//  Vine.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 8/30/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

/**
 A VineNode class adheres to the RopeType protocol

 A vine can not be climbed, but it can be grabbed and used to swing from one place to another
 For more information, look at the RopeType protocol
 */
class VineNode: SKNode, RopeType {
    
    internal let segmentLength: Int
    
    /** See RopeTypeProtocol */
    internal var ropeTypeHolder: SKSpriteNode?
    /** See RopeTypeProtocol */
    internal let anchorPoint: CGPoint
    /** See RopeTypeProtocol */
    internal let length: Int
    /** See RopeTypeProtocol */
    public var segments: [RopeTypeSegment] = []
    
    required init(length: Int, anchorPoint: CGPoint, name: String, segmentLength: Int) {
        self.length = length
        self.anchorPoint = anchorPoint
        self.segmentLength = segmentLength
        super.init()
        self.name = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.length = aDecoder.decodeInteger(forKey: "length")
        self.anchorPoint = aDecoder.decodeCGPoint(forKey: "anchorPoint")
        self.segmentLength = aDecoder.decodeInteger(forKey: "segmentLength")

        super.init(coder: aDecoder)
    }
    
    func setupJoints() {
        guard let ropeTypeHolder = self.ropeTypeHolder else {
            return
        }
        // set up joint for vine holder
        let joint = SKPhysicsJointPin.joint(withBodyA: ropeTypeHolder.physicsBody!, bodyB: self.segments[0].physicsBody!, anchor: CGPoint(x: ropeTypeHolder.frame.midX, y: ropeTypeHolder.frame.midY))
                
        self.scene?.physicsWorld.add(joint)
        
        // set up joints between vine parts
        for i in 1..<length {
            let nodeA = self.segments[i - 1]
            let nodeB = self.segments[i]            
            let joint = SKPhysicsJointPin.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchor: CGPoint(x: nodeA.frame.midX, y: nodeA.frame.minY))
            self.scene?.physicsWorld.add(joint)
        }
    }
    
    
}
