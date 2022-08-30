//
//  Vine.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 8/29/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

class SpringSegment:SKSpriteNode { }

class SpringNode: SKNode {
    
    // The amount of chains/nodes that this rope will consist of
    private let length:Int
    private let anchorPoint:CGPoint
    private var springHolder:SKSpriteNode?
    public var springSegments:[SpringSegment] = []
            
    init(length: Int, anchorPoint: CGPoint, name: String) {
        self.length = length
        self.anchorPoint = anchorPoint
        super.init()
        self.name = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.length = aDecoder.decodeInteger(forKey: "length")
        self.anchorPoint = aDecoder.decodeCGPoint(forKey: "anchorPoint")

        super.init(coder: aDecoder)
    }
    
    func addToScene (_ scene: SKScene?) {
        self.zPosition = 100
        scene?.addChild(self)
        let springHolder = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        springHolder.position = self.anchorPoint
        self.addChild(springHolder)
        
        springHolder.physicsBody = SKPhysicsBody(circleOfRadius: springHolder.size.width / 2)
        springHolder.physicsBody?.isDynamic = false
        springHolder.physicsBody?.allowsRotation = true
        springHolder.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.SpringHolder)
        springHolder.physicsBody?.collisionBitMask = 0
        self.springHolder = springHolder
        self.addSpringNodes()
        self.setupJoints()
    }
    
    func addSpringNodes () {
        // add each of the vine parts
        for i in 0..<self.length {
            let springSegment = SpringSegment(color: .blue, size: CGSize(width: 30, height: 300))
            let offset = (( (springSegment.size.height / 2) + 10) * CGFloat(i + 1))
            springSegment.position = CGPoint(x: anchorPoint.x, y: anchorPoint.y - offset)
            springSegment.name = name
          
            self.springSegments.append(springSegment)
            self.addChild(springSegment)
                      
            springSegment.physicsBody = SKPhysicsBody(rectangleOf: springSegment.size)
            springSegment.physicsBody?.allowsRotation = false
            springSegment.physicsBody?.mass = 0.3
            springSegment.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Spring) | UInt32(PhysicsCategory.Player)
            springSegment.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.Player)
            springSegment.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.SpringHolder)
            
        }
    }
    
    /**
     Setup the joints between the vineholder and the vine, and then each vine segment to one another
    */
    func setupJoints () {
        
        guard let springHolder = self.springHolder else { return }
        
        // set up joint for vine holder
        
        let joint = SKPhysicsJointSpring.joint(withBodyA: springHolder.physicsBody!, bodyB: self.springSegments[0].physicsBody!, anchorA: CGPoint(x: springHolder.frame.midX, y: springHolder.frame.midY), anchorB: self.springSegments[0].position)
        joint.frequency = 0.7
        joint.damping = 0.0
        self.scene?.physicsWorld.add(joint)
        
        let axisJoint = SKPhysicsJointSliding.joint(withBodyA: springHolder.physicsBody!, bodyB: self.springSegments[0].physicsBody!, anchor: CGPoint(x: springHolder.frame.midX, y: springHolder.frame.midY), axis: CGVector(dx: 0, dy: 1))
        self.scene?.physicsWorld.add(axisJoint)
        
        // set up joints between vine parts
        for i in 1..<length {
            let nodeA = self.springSegments[i - 1]
            let nodeB = self.springSegments[i]
            let joint = SKPhysicsJointSpring.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchorA: CGPoint(x: nodeA.frame.midX, y: nodeA.frame.minY), anchorB: CGPoint(x: nodeB.frame.midX, y: nodeB.frame.minY))
            joint.frequency = 5
            joint.damping = 5
          
            self.scene?.physicsWorld.add(joint)
        }
    }
    
}
