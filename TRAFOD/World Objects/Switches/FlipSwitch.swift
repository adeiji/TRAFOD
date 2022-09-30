//
//  FlipSwitch.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/4/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class FlipSwitchComponent : SKSpriteNode { }

/**
 All the parameters necessary for a FlipSwitch
 
 - Parameters:
    - switchPos: The location of the actual switch itself. Every other position is relative to this position
    - startPos: The position that the movable platform starts at
    - endPos: The position that the movable platform travels to
    - platformSize: The size of the movable platform
    -
 */
struct FlipSwitchParams {
    let switchPos: CGPoint
    let startPos: CGPoint
    let endPos: CGPoint
    let platformSize: CGSize
    let direction: MoveablePlatformDirection
    let velocity: Double
    
    static let Horizontal = "horizontal"
    static let Vertical = "vertical"
    
    static func getDirectionFromString (_ direction: String) -> MoveablePlatformDirection {
        if direction == FlipSwitchParams.Horizontal {
            return .horizontal
        } else {
            return .vertical
        }
    }
}

class FlipSwitch : GameSwitch, ObjectWithManuallyGeneratedPhysicsBody {
    
    /// When set automatically sets up the object with the parameters given
    var switchParams:FlipSwitchParams? {
        didSet {
            guard let switchParams = self.switchParams else { return }
            self.setupObject(switchParams: switchParams)
        }
    }
    
    /// The platform that moves from one position to another position
    var movablePlatform:MoveablePlatform?
    
    let switchSize = CGSize(width: 150, height: 150)
    
    /**
     Instantiate the child objects, and provide initial setup for self and children
     
     - Parameters:
        - switchParams: The parameters that are used for setup of self and children
     */
    private func setupObject (switchParams: FlipSwitchParams) {        
        let startNode = MoveablePlatform(switchParams: switchParams)
        let endPositionNode = WeightSwitchPlatformFinalPosition()
        endPositionNode.position = switchParams.endPos
        
        self.addChild(startNode)        
        self.addChild(endPositionNode)
        self.position = switchParams.switchPos
                
        self.texture = Textures.FlipSwitch
        
        self.size = switchSize
        self.setupPhysicsBody()
        self.setMovablePlatformWithTimeInterval(timeInterval: 3.0)
    }
    
    init () {
        super.init(texture: nil, color: .clear, size: CGSize())
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupPhysicsBody () {
        if self.physicsBody == nil {
            self.physicsBody = SKPhysicsBody(rectangleOf: self.switchSize)
        }
        
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.FlipSwitch)
        self.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.CannonBall) | UInt32(PhysicsCategory.Rock) | UInt32(PhysicsCategory.Player)
        self.physicsBody?.pinned = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = true
    }
    
    /**
     Turns the switch to the opposite of whatever it's current setting is, ex: If on, set to off
     */
    func flipSwitch () {
        self.movablePlatform?.move()        
    }
    
    /**
     Flips the switch from on to off
     */
    class func flipSwitch(contact: SKPhysicsContact) {
        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: FlipSwitch.self, nodeBType: Player.self) {
            let node = contact.getNodeOfType(FlipSwitch.self) as? FlipSwitch
            node?.flipSwitch()
        }
    }
    
    func setMovablePlatformWithTimeInterval (timeInterval: TimeInterval) {
        self.children.forEach { (node) in
            if let node = node as? MoveablePlatform {                
                self.movablePlatform = node
                self.setEndPointAndTimeInterval(timeInterval: timeInterval)
            }
        }
    }
    
    private func setEndPointAndTimeInterval (timeInterval: TimeInterval) {
        self.children.forEach { (node) in
            if let node = node as? WeightSwitchPlatformFinalPosition {
                self.movablePlatform?.moveToPoint = node.position
                self.movablePlatform?.moveDuration = timeInterval
                return;
            }
        }
    }
}
