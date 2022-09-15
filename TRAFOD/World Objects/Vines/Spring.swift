//
//  Vine.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 8/29/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

class RopeTypeSegment:SKSpriteNode { }

class SpringNode: SKNode, RopeType {    
    
    /** See RopeTypeProtocol */
    internal let segmentLength: Int
    
    internal let anchorPoint: CGPoint
    
    /** The node that the actual rope (spring) is anchored to */
    internal var ropeTypeHolder: SKSpriteNode?
    
    // The amount of chains/nodes that this rope will consist of
    internal let length:Int
            
    public var segments:[RopeTypeSegment] = []
            
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
    
    /**
     Setup the joints between the vineholder and the vine, and then each vine segment to one another
    */
    func setupJoints (anchor: SKNode?, positionOffset: CGPoint? = nil) {
        
        guard let anchor = anchor else { return }
        
        // set up joint for vine holder
        
        let joint = SKPhysicsJointSpring.joint(withBodyA: anchor.physicsBody!, bodyB: self.segments[0].physicsBody!, anchorA: CGPoint(x: anchor.frame.midX, y: anchor.frame.midY), anchorB: self.segments[0].position)
        joint.frequency = 0.7
        joint.damping = 0.0
        self.scene?.physicsWorld.add(joint)
        
        let axisJoint = SKPhysicsJointSliding.joint(withBodyA: anchor.physicsBody!, bodyB: self.segments[0].physicsBody!, anchor: CGPoint(x: anchor.frame.midX, y: anchor.frame.midY), axis: CGVector(dx: 0, dy: 1))
        self.scene?.physicsWorld.add(axisJoint)
        
        // set up joints between vine parts
        for i in 1..<length {
            let nodeA = self.segments[i - 1]
            let nodeB = self.segments[i]
            let joint = SKPhysicsJointSpring.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchorA: CGPoint(x: nodeA.frame.midX, y: nodeA.frame.minY), anchorB: CGPoint(x: nodeB.frame.midX, y: nodeB.frame.minY))
            joint.frequency = 5
            joint.damping = 5
          
            self.scene?.physicsWorld.add(joint)
        }
    }
    
}
