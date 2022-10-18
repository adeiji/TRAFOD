//
//  FlipGravSoldier.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 10/6/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

protocol PhysicsElement {
    /** If there was a contact that this node type is interested in, then handle the affects of that physics contact */
    static func handleContact (_ contact: SKPhysicsContact, world: World)
}

protocol Enemy: Player {
    
}

class FlipGravSoldier: Player, Enemy, PhysicsElement {
    
    private var playerDetectionNode:SKSpriteNode?
    
    private var flipGravField:FlipGravity?
    
    static let kPlayerDetectionNode = "Player Detection Node"
    
    public var stopped = false
    
    public var id = UUID().uuidString
      
    override func setup() {
        self.addPlayerDetectionNode()
        super.setup()
    }
        
    class func handleContact (_ contact: SKPhysicsContact, world: World) {
        if
            let _ = contact.getNodeWithName(name: PhysicsObjectTitles.Dawud),
            let soldier = contact.getNodeWithName(name: kPlayerDetectionNode)?.parent as? FlipGravSoldier {
            soldier.stopped = true
            
            // We don't want the soldier to be affected by the mineral that he just threw so we make it so that his physics body is not affected by external forces.
            soldier.physicsBody?.isDynamic = false
            
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
                
                // If the soldier has already thrown a mineral then don't throw another one
                if let _ = world.getPhysicsAlteringFieldFromWorldOfType(FlipGravity.self) {
                    return                    
                }
                
                let flipGravMineral = FlipGravityMineral()
                flipGravMineral.throwerId = soldier.id
                flipGravMineral.direction = .right
                flipGravMineral.throwMineral(player: soldier, world: world)
                
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
                    let field = world.getPhysicsAlteringFieldFromWorldOfType(FlipGravity.self)
                    field?.removeField()
                    soldier.stopped = false
                }
            }
        }
    }
    
    override func handlePlayerMovement() {
        if self.stopped { return }
        switch self.runningState {
        case .RUNNINGRIGHT:
            // Check to see if the character is about to jump off of a cliff or of an object
            if let groundCharacterStandingOn = self.groundNode?.physicsBody?.allContactedBodies().first(where: { $0.node is Ground })?.node as? Ground {
                if self.frame.maxX >= groundCharacterStandingOn.frame.maxX - 10 {
                    
                    // TODO: We need to make it so that this line is run anytime the players running state is set
                    if self.previousRunningState == .RUNNINGRIGHT {
                        self.xScale = self.xScale * -1
                    }
                    
                    self.runningState = .RUNNINGLEFT
                    self.previousRunningState = .RUNNINGLEFT
                }
                
                let velocity = self.runningState == .RUNNINGRIGHT ? PhysicsHandler.kSoldierRunVelocity : -PhysicsHandler.kSoldierRunVelocity
                self.move(dx: velocity, dy: 0)
            }
        case .RUNNINGLEFT:
            // Check to see if the character is about to jump off of a cliff or of an object
            if let groundCharacterStandingOn = self.groundNode?.physicsBody?.allContactedBodies().first(where: { $0.node is Ground })?.node as? Ground {
                if self.frame.minX <= groundCharacterStandingOn.frame.minX + 10 {
                    // TODO: We need to make it so that this line is run anytime the players running state is set
                    if self.previousRunningState == .RUNNINGLEFT {
                        self.xScale = self.xScale * -1
                    }
                    
                    self.runningState = .RUNNINGRIGHT
                    self.previousRunningState = .RUNNINGRIGHT
                    
                }
                
                let velocity = self.runningState == .RUNNINGRIGHT ? PhysicsHandler.kSoldierRunVelocity : -PhysicsHandler.kSoldierRunVelocity
                self.move(dx: velocity, dy: 0)
            }
        case .STANDING:
            self.runningState = .RUNNINGRIGHT
            self.previousRunningState = .RUNNINGRIGHT
        }
    }
    
    override func update() {
        super.update()
        
        self.handlePlayerMovement()
    }
    
    private func addPlayerDetectionNode () {
        let node = SKSpriteNode(color: UIColor(red: 255/255, green: 0, blue: 0, alpha: 0.4), size: CGSize(width: 500, height: self.frame.height))
        node.position = CGPoint(x: 250, y: 0)
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.pinned = true
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.NonCollision)
        node.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Nothing)
        node.physicsBody?.contactTestBitMask = UInt32(PhysicsCategory.Player)
        node.physicsBody?.mass = 0
        node.physicsBody?.density = 0
        node.name = FlipGravSoldier.kPlayerDetectionNode
        self.addChild(node)
        self.playerDetectionNode = node
    }
}
