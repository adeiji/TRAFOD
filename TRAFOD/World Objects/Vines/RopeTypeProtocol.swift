//
//  RopeTypeExtension.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 8/30/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

protocol RopeType: SKNode {
    
    /** The node that holds the actual rope to a fixed point */
    var ropeTypeHolder:SKSpriteNode? { get set }
    
    /** The point at which the rope is anchored (the position of the ropeTypeHolder)*/
    var anchorPoint:CGPoint { get }
    
    /// The amount of segments that this rope is going to have.
    /// > Important: If you add more then one segment to a spring than things can get very strange so be careful when doing that. It's because of the nature of a spring. Think about the unpredictability of attaching two springs together. 
    var length:Int { get }
    
    /// The individual segments that the rope consist of
    var segments:[RopeTypeSegment] { get set }
    
    var segmentLength:Int { get }
    
    func addToScene (_ scene: SKNode?, anchor: SKNode?)
    func setupJoints (anchor: SKNode?, positionOffset: CGPoint?)
    init(length: Int, anchorPoint: CGPoint, name: String, segmentLength: Int)
    
}

extension RopeType {
    
    func addToScene (_ scene: SKNode?, anchor: SKNode? = nil) {
        self.zPosition = 100
        scene?.addChild(self)
        
        if (anchor == nil) {
            self.setupHolder()
        }
        
        self.addNodes()
        self.setupJoints(anchor: anchor ?? self.ropeTypeHolder, positionOffset: nil)
    }
    
    func setupHolder () {
        let ropeTypeHolder = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        ropeTypeHolder.position = self.anchorPoint
        self.addChild(ropeTypeHolder)
        
        ropeTypeHolder.physicsBody = SKPhysicsBody(circleOfRadius: ropeTypeHolder.size.width / 2)
        ropeTypeHolder.physicsBody?.isDynamic = false
        ropeTypeHolder.physicsBody?.allowsRotation = true
        ropeTypeHolder.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.SpringHolder)
        ropeTypeHolder.physicsBody?.collisionBitMask = 0
        self.ropeTypeHolder = ropeTypeHolder
    }
    
    func addNodes () {
        // add each of the vine parts
        for i in 0..<self.length {
            let segment = RopeTypeSegment(color: .blue, size: CGSize(width: 70, height: self.segmentLength))
            let offset = segment.size.height * CGFloat(i + 1)
            segment.position = CGPoint(x: self.anchorPoint.x, y: self.anchorPoint.y - offset - (CGFloat(i) * 10) )
            segment.name = name
          
            self.segments.append(segment)
            self.addChild(segment)
                      
            segment.physicsBody = SKPhysicsBody(rectangleOf: segment.size)
            segment.physicsBody?.allowsRotation = self is SpringNode ? false : true
            segment.physicsBody?.mass = 0.3
            segment.physicsBody?.restitution = 0
            segment.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Rope)
            segment.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.Player)
            segment.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.SpringHolder)
            
        }
    }
}
