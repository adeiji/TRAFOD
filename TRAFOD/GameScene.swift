//
//  GameScene.swift
//  TRAFOD
//
//  Created by adeiji on 6/7/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Minerals {
    case ANTIGRAV
    case IMPULSE
}

class Ground : SKShapeNode {
    
    override init() {
        super.init()
        self.name = "GROUND"
        self.lineWidth = 5
        self.physicsBody = SKPhysicsBody(edgeChainFrom: self.path!)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.restitution  = 0.2
        self.physicsBody?.categoryBitMask = 1
        self.physicsBody?.contactTestBitMask = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Player : SKSpriteNode {
    
    public var hasAntigrav = false
    public var hasImpulse = false
    public var mineralCounts = [Minerals:Int]()
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    let player:Player = Player(imageNamed: "standing")
    private var runSound = SKAction.playSoundFileNamed("footsteps", waitForCompletion: false)
    private var ground:SKShapeNode?
    
    private var originalTouchPosition:CGPoint?
    private var playerRunningState:PlayerRunningState = .STANDING
    private var previousPlayerRunningState:PlayerRunningState = .STANDING
    private var playerState:PlayerState = .ONGROUND
    private var playerAction:PlayerAction = .NONE
    private var throwingMineral:Minerals!
    private var forces:[Minerals] = [Minerals]()
    private var runTime:TimeInterval = TimeInterval()
    private var stepCounter = 0
    
    private var jumpButton:SKNode!
    private var throwButton:SKNode!
    private var throwImpulseButton:SKNode!
    
    private var cameraXOffset:CGFloat = 0
    private var cameraYPosition:CGFloat = 0
    private var lastPointOnGround:CGPoint!
    
    private var skyNode:SKSpriteNode!
    private var foliage1Node:SKSpriteNode!
    private var foliage2Node:SKSpriteNode!
    private var mountains:SKSpriteNode!
    
    private var backgroundMusic:SKAudioNode!
    private var ambiance:SKAudioNode!
    
    private let stepsKey = "FootstepsKey"
    private let abyssKey = "abyss"
    private let antiGravViewKey = "antiGravView"
    
    private let antiGravCounterThrowNode = SKSpriteNode(imageNamed: "Blue Crystal")
    private let antiGravCounterNode = SKSpriteNode(imageNamed: "Blue Crystal")
    private let antiGravCounterLabel = SKLabelNode(text: "0")
    
    private let impulseCounterThrowNode = SKSpriteNode(imageNamed: "Red Crystal")
    private let impulseCounterNode = SKSpriteNode(imageNamed: "Red Crystal")
    private let impulseCounterLabel = SKLabelNode(text: "0")
    
    private let playerNodeType:UInt32 = 2
    private let portalNodeType:UInt32 = 5
    private var gravityTimeLeft:Int = 0
    
    enum PlayerState {
        case INAIR
        case JUMP
        case ONGROUND
        case HITPORTAL
        case DEAD
    }
    
    enum PlayerAction {
        case THROW
        case NONE
    }
    
    enum PlayerRunningState {
        case RUNNINGLEFT
        case RUNNINGRIGHT
        case STANDING
    }
    
    enum Minerals {
        case ANTIGRAV
        case IMPULSE
    }
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    private func showMineralCount () {
        for key in self.player.mineralCounts.keys {
            if let count = self.player.mineralCounts[key] {
                if key == .ANTIGRAV {
                    if self.antiGravCounterThrowNode.parent != self.camera {
                        self.addThrowButton()
                        self.antiGravCounterThrowNode.position = CGPoint(x: 260, y: -227)
                        self.antiGravCounterNode.position = CGPoint(x: -570, y: 400)
                        self.antiGravCounterLabel.position = CGPoint(x: -500,  y: 390)
                        self.antiGravCounterLabel.fontSize = 50
                        self.antiGravCounterLabel.fontName = "HelveticaNeue-Bold"
                        self.camera?.addChild(self.antiGravCounterThrowNode)
                        self.camera?.addChild(self.antiGravCounterNode)
                        self.camera?.addChild(self.antiGravCounterLabel)
                    }
                    
                    self.antiGravCounterLabel.text = "\(count)"
                } else if key == .IMPULSE {
                    if self.impulseCounterThrowNode.parent != self.camera {
                        self.addThrowImpulseButton()
                        self.impulseCounterNode.position = CGPoint(x: -400, y: 400)
                        self.impulseCounterLabel.position = CGPoint(x: -330,  y: 390)
                        self.impulseCounterLabel.fontSize = 50
                        self.impulseCounterLabel.fontName = "HelveticaNeue-Bold"
                        self.camera?.addChild(self.impulseCounterNode)
                        self.camera?.addChild(self.impulseCounterLabel)
                    }
                    
                    self.impulseCounterLabel.text = "\(count)"
                }
            }
        }
    }
    
    private func addJumpButton () {
        self.jumpButton = SKSpriteNode(texture: SKTexture(imageNamed: "jumpbutton"), color: .clear, size: CGSize(width: 200, height: 200))
        self.jumpButton.position = CGPoint(x: 472 , y: -227)
        self.camera?.addChild(self.jumpButton)
    }
    
    private func addThrowButton () {
        self.throwButton = SKSpriteNode(texture: SKTexture(imageNamed: "throwbutton"), color: .clear, size: CGSize(width: 200, height: 200))
        self.throwButton.position = CGPoint(x: 260 , y: -227)
        self.camera?.addChild(self.throwButton)
    }
    
    private func addThrowImpulseButton () {
        self.throwImpulseButton = SKSpriteNode(texture: SKTexture(imageNamed: "throwbutton"), color: .clear, size: CGSize(width: 200, height: 200))
        self.throwImpulseButton.position = CGPoint(x: 472 , y: 0)
        self.impulseCounterThrowNode.position = CGPoint(x: 472, y: 0)
        
        self.camera?.addChild(self.throwImpulseButton)
        self.camera?.addChild(self.impulseCounterThrowNode)
    }
    
    private func createPlayer () {
        self.player.position = CGPoint(x: 116, y: 86.7)
        self.player.name = "dawud"
        self.player.xScale = 1
        self.player.yScale = 0.90
        self.player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.player.size.width, height: self.player.size.height))
        self.player.physicsBody?.usesPreciseCollisionDetection = true
        self.player.physicsBody?.affectedByGravity = true
        self.player.physicsBody?.restitution = 0
        self.player.physicsBody?.mass = 1
        self.player.physicsBody?.isDynamic = true
        self.player.physicsBody?.contactTestBitMask = 1
        self.player.physicsBody?.collisionBitMask = 0b0010
        self.player.physicsBody?.allowsRotation = false
        self.lastPointOnGround = self.player.position
        
        addChild(self.player)
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.addJumpButton()
        self.createPlayer()
        
        self.enumerateChildNodes(withName: "ground") { (node, pointer) in
            node.physicsBody?.friction = 1.0
        }
        
        self.cameraXOffset = (self.camera?.position.x)! - self.player.position.x
        
        if let musicURL = Bundle.main.url(forResource: "Level1_Theme", withExtension: "mp3") {
            self.backgroundMusic = SKAudioNode(url: musicURL)
            addChild(self.backgroundMusic)
        }
        
        if let musicURL = Bundle.main.url(forResource: "birdschirping", withExtension: "mp3") {
            self.ambiance = SKAudioNode(url: musicURL)
            self.ambiance.run(SKAction.changeVolume(by: -0.7, duration: 0))
            addChild(self.ambiance)
        }
        
        let antiGravNode = self.camera?.childNode(withName: self.antiGravViewKey)
        antiGravNode?.isHidden = true
    }
    
    func contactContains (strings: [String], contactA: String, contactB: String) -> Bool {
        var result = true
        for string in strings {
            var myResult = false
            if contactA.contains(string) {
                myResult = true
            }
            if contactB.contains(string) {
                myResult = true
            }
            
            if myResult == false {
                result = false
                break
            }
            
        }
        
        return result
    }
    
    func getContactNode (string: String, contact: SKPhysicsContact) -> SKNode? {
        if (contact.bodyA.node?.name?.contains(string))! {
            return contact.bodyA.node
        } else if (contact.bodyB.node?.name?.contains(string))! {
            return contact.bodyB.node
        }
        
        return nil
    }
    
    func portalHit (portalNode: SKSpriteNode) {
        self.forces.append(.IMPULSE)
    }
    
    func showImpulseTimeLeft (timeNode: SKLabelNode, timeLeft: Int = 10) {
        let secondTimer = SKAction.wait(forDuration: 1.0)
        timeNode.text = "\(timeLeft)"
        timeNode.fontSize = 80
        
        let timeBlock = SKAction.run {
            if timeLeft > 1 {
                self.showImpulseTimeLeft(timeNode: timeNode, timeLeft: timeLeft - 1)
            } else {
                timeNode.removeFromParent()
            }
        }
        
        let sequence = SKAction.sequence([secondTimer, timeBlock])
        run(sequence)
    }
    
    func impulseUsed (crashPosition: CGPoint) {
        // Add an impulse node to the screen
        self.playMineralCrashSound()
        
        let impulseNode = SKSpriteNode(imageNamed: "Portal")
        impulseNode.position = crashPosition
        if self.previousPlayerRunningState == .RUNNINGRIGHT {
            impulseNode.position.x = impulseNode.position.x + 150
        } else {
            impulseNode.position.x = impulseNode.position.x - 150
        }
        
        impulseNode.zPosition = -5
        impulseNode.position.y = impulseNode.position.y + impulseNode.texture!.size().height / 2.0
        impulseNode.name = "portal"
        impulseNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: impulseNode.texture!.size().height))
        impulseNode.physicsBody?.allowsRotation = false
        impulseNode.physicsBody?.pinned = false
        impulseNode.physicsBody?.affectedByGravity = false
        impulseNode.physicsBody?.isDynamic = true
        impulseNode.physicsBody?.collisionBitMask = 0
        impulseNode.physicsBody?.categoryBitMask = 0b0001
        
        let oneRevolution:SKAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1)
        let repeatRotation:SKAction = SKAction.repeatForever(oneRevolution)
        impulseNode.run(repeatRotation)
        
        let warpTime = SKAction.wait(forDuration: 10.0)
        let timeNode = SKLabelNode()
        timeNode.fontSize = 40
        timeNode.position = impulseNode.position
        timeNode.position.y = timeNode.position.y - 30
        
        self.addChild(timeNode)
        self.showImpulseTimeLeft(timeNode: timeNode)
        let impulseBlock = SKAction.run {
            impulseNode.removeFromParent()
        }
        
        let sequence = SKAction.sequence([warpTime, impulseBlock])
        run(sequence)
        
        self.addChild(impulseNode)
    }
    
    private func playMineralCrashSound () {
        
        let mineralCrashSound = SKAction.playSoundFileNamed("mineralcrash", waitForCompletion: false)
        run(mineralCrashSound)
    }
    
    func antiGravUsed () {
        self.playMineralCrashSound()
        let antiGravSound = SKAction.playSoundFileNamed("antigrav", waitForCompletion: false)
        run(antiGravSound)
        
        if !self.forces.contains(.ANTIGRAV) {
            self.physicsWorld.gravity.dy = self.physicsWorld.gravity.dy / 2.0
            self.forces.append(.ANTIGRAV)
            
            let antiGravView = self.camera?.childNode(withName: self.antiGravViewKey)
            antiGravView?.isHidden = false
            
            let timeNode = SKLabelNode()
            timeNode.fontSize = 100
            timeNode.position = CGPoint(x: 0, y: 0)
            self.camera?.addChild(timeNode)
            self.gravityTimeLeft = 5
            let timeLabel = SKLabelNode()
            timeLabel.fontSize = 120
            timeLabel.fontName = "HelveticaNeue-Bold"
            timeLabel.position = CGPoint(x: 0, y: 0)
            self.camera?.addChild(timeLabel)
            self.changeGravityWithTime(antiGravView: antiGravView, timeLabel: timeLabel)
        } else {
            self.gravityTimeLeft = 5
        }
    }
    
    func changeGravityWithTime (antiGravView:SKNode?, timeLabel:SKLabelNode) {
        let seconds = SKAction.wait(forDuration: 1.0)
        timeLabel.text = "\(self.gravityTimeLeft)"
        let changeGravityBlock = SKAction.run {
            [unowned self] in
            if self.gravityTimeLeft > 1 {
                self.gravityTimeLeft = self.gravityTimeLeft - 1
                self.changeGravityWithTime(antiGravView: antiGravView, timeLabel: timeLabel)
            }
            else {
                self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
                self.forces.remove(at: self.forces.index(of: .ANTIGRAV)!)
                antiGravView?.isHidden = true
                timeLabel.removeFromParent()
            }
        }
        
        let sequence = SKAction.sequence([seconds, changeGravityBlock])
        run(sequence)
    }
    
    func getImpulse () {
        if self.player.hasImpulse == false {
            self.player.hasImpulse = true
        }
        
        if var count = self.player.mineralCounts[.IMPULSE] {
            count = count + 10
            self.player.mineralCounts[.IMPULSE] = count
        } else {
            self.player.mineralCounts[.IMPULSE] = 10
        }
        
        self.playMineralSound()
        self.showMineralCount()
    }
    
    func getAntiGrav () {
        if self.player.hasAntigrav == false {
            self.player.hasAntigrav = true
        }
        
        if var count = self.player.mineralCounts[.ANTIGRAV] {
            count = count + 10
            self.player.mineralCounts[.ANTIGRAV] = count
        } else {
            self.player.mineralCounts[.ANTIGRAV] = 10
        }
        
        self.playMineralSound()
        self.showMineralCount()
    }
    
    private func playMineralSound () {
        let getMineralSound = SKAction.playSoundFileNamed("mineralgrab", waitForCompletion: false)
        run(getMineralSound)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactAName = contact.bodyA.node?.name
        let contactBName = contact.bodyB.node?.name
        if (contactAName == "dawud") || (contactBName == "dawud") {
            if (contactAName == "ground") || (contactBName == "ground") {
                if contact.contactNormal.dy == 1 {
                    self.player.zRotation = 0.0
                    self.lastPointOnGround = self.player.position
                    self.playerState = .ONGROUND
                }
            }
        }
        
        if contactContains(strings: ["ground", "mineral", "gravity"], contactA: contactAName ?? "", contactB: contactBName ?? "") {
            self.antiGravUsed()
            
            if let node = getContactNode(string: "mineral", contact: contact) {
                node.removeFromParent()
            }
        }
        
        
        if contactContains(strings: ["ground", "mineral", "impulse"], contactA: contactAName ?? "", contactB: contactBName ?? "") {
            self.impulseUsed(crashPosition: contact.contactPoint)
            
            if let node = getContactNode(string: "mineral", contact: contact) {
                node.removeFromParent()
            }
        }
        
        if contactContains(strings: ["dawud", "portal"], contactA: contactAName ?? "", contactB: contactBName ?? "") {
            if let node = getContactNode(string: "portal", contact: contact) {
                self.portalHit(portalNode: node as! SKSpriteNode)
            }
        }
        
        if contactContains(strings: ["dawud", self.abyssKey], contactA: contactAName ?? "", contactB: contactBName ?? "") {
            self.playerState = .DEAD
        }
        
        if contactContains(strings: ["dawud", "getImpulse"], contactA: contactAName ?? "", contactB: contactBName ?? "") {
            self.getImpulse()
            
            if let node = getContactNode(string: "getImpulse", contact: contact) {
                node.removeFromParent()
            }
        }
        
        if contactContains(strings: ["dawud", "getAntiGrav"], contactA: contactAName ?? "", contactB: contactBName ?? "") {
            self.getAntiGrav()
            
            if let node = getContactNode(string: "getAntiGrav", contact: contact) {
                node.removeFromParent()
            }
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
        if self.nodes(at: pos).contains(self.jumpButton) {
            if self.playerState == .ONGROUND {
                self.playerState = .JUMP
            }
        } else if self.throwButton != nil && self.nodes(at: pos).contains(self.throwButton) {
            self.playerAction = .THROW
            self.throwingMineral = .ANTIGRAV
        } else if self.throwImpulseButton != nil && self.nodes(at: pos).contains(self.throwImpulseButton) {
            self.playerAction = .THROW
            self.throwingMineral = .IMPULSE
        } else {
            self.originalTouchPosition = pos
        }
    }
    
    private func throwMineral (type: Minerals) {
        if type == .ANTIGRAV {
            
        }
    }
    
    private func isGrounded () -> Bool {
        if let bodies = self.player.physicsBody?.allContactedBodies(), let groundPhysicsBody = self.ground?.physicsBody {
            if bodies.contains(groundPhysicsBody) {
                return true
            }
        }
        
        return false
    }
    
    private func jump() {
        self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 600))
        let jumpSound = SKAction.playSoundFileNamed("one", waitForCompletion: false)
        run(jumpSound)
        self.player.texture = SKTexture(imageNamed: "spinning")
        self.playerState = .INAIR
    }
    
    private func rotateJumpingPlayer (rotation: Double) {
        if self.previousPlayerRunningState == .RUNNINGRIGHT || self.previousPlayerRunningState == .STANDING {
            self.player.zRotation = self.player.zRotation + CGFloat(Double.pi / rotation)
        } else if self.previousPlayerRunningState == .RUNNINGLEFT {
            self.player.zRotation = self.player.zRotation - CGFloat(Double.pi / rotation)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
        
        if let originalPos = self.originalTouchPosition {
            let differenceInXPos = originalPos.x - pos.x
            if abs(differenceInXPos) > 10 {
                if differenceInXPos < 0 {
                    if self.playerRunningState == .STANDING {
                        let stepsSound = SKAction.playSoundFileNamed("footsteps", waitForCompletion: true)
                        let repeatAction = SKAction.repeatForever(stepsSound)
                        
                        run(repeatAction, withKey: self.stepsKey)
                    }
                    if self.previousPlayerRunningState == .RUNNINGLEFT {
                        self.player.xScale = self.player.xScale * -1
                    }
                    self.playerRunningState = .RUNNINGRIGHT
                    self.previousPlayerRunningState = .RUNNINGRIGHT
                } else {
                    if self.previousPlayerRunningState == .RUNNINGRIGHT {
                        self.player.xScale = self.player.xScale * -1
                    }
                    self.playerRunningState = .RUNNINGLEFT
                    self.previousPlayerRunningState = .RUNNINGLEFT
                }
            } else {
                self.playerRunningState = .STANDING
            }
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
        
        self.playerRunningState = .STANDING
        removeAction(forKey: self.stepsKey)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    func run () {
        if self.playerRunningState == .RUNNINGLEFT {
            if let dx = self.player.physicsBody?.velocity.dx {
                if dx > CGFloat(-700.0) {
                    self.player.physicsBody?.applyImpulse(CGVector(dx: -20, dy: 0))
                }
            } else {
                self.player.physicsBody?.applyImpulse(CGVector(dx: -20, dy: 0))
            }
            
        } else if self.playerRunningState == .RUNNINGRIGHT {
            if let dx = self.player.physicsBody?.velocity.dx {
                if dx < CGFloat(700.0) {
                    self.player.physicsBody?.applyImpulse(CGVector(dx: 20, dy: 0))
                }
            } else {
                self.player.physicsBody?.applyImpulse(CGVector(dx: 20, dy: 0))
            }
        }
    }
    
    private func showRunning (currentTime: TimeInterval) {
        // Show the first running image
        if currentTime - self.runTime == 0 {
            if self.playerState != .INAIR {
                self.player.texture = SKTexture(imageNamed: "standing")
            }
        } else if currentTime - self.runTime > 0.1 {
            if self.playerState != .INAIR {
                // Alternate images
                self.runTime = currentTime
                self.stepCounter = self.stepCounter + 1
                self.player.texture = SKTexture(imageNamed: "running_step\(self.stepCounter)")
                if self.stepCounter == 7 {
                    self.stepCounter = 0
                }
            }
        }
    }
    
    private func handlePlayerDied () {
        self.player.position = self.lastPointOnGround
        self.player.zRotation = 0.0
        self.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.playerRunningState = .STANDING
        self.playerState = .ONGROUND
    }
    
    private func handleImpulse () {
        if let index = self.forces.index(of: .IMPULSE) {
            self.forces.remove(at: index)
            if self.player.physicsBody!.velocity.dx > 0.0 {
                self.player.physicsBody?.applyImpulse(CGVector(dx: 600, dy: 250))
            } else {
                self.player.physicsBody?.applyImpulse(CGVector(dx: -600, dy: 250))
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.handleImpulse()
        
        if self.playerState == .DEAD {
            self.handlePlayerDied()
        }
        else {
            if self.playerRunningState != .STANDING {
                self.showRunning(currentTime: currentTime)
                self.run()
            } else {
                if self.playerState != .INAIR {
                    self.player.texture = SKTexture(imageNamed: "standing")
                }
            }
            
            self.handleJump()
            self.handlePlayerRotation(dt: dt)
            self.handleThrow()
        }
        
        self.moveCamera()
        self.lastUpdateTime = currentTime
    }

    private func showThrowMineral (mineralNode: SKSpriteNode) {
        mineralNode.position = self.player.position
        
        mineralNode.xScale = 0.3
        mineralNode.yScale = 0.3
        
        let width = (mineralNode.texture?.size().width)! * 0.3
        let height = (mineralNode.texture?.size().height)! * 0.3
        
        mineralNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: height))
        mineralNode.physicsBody?.affectedByGravity = true
        mineralNode.physicsBody?.categoryBitMask = 2
        mineralNode.physicsBody?.isDynamic = true
        mineralNode.physicsBody?.contactTestBitMask = 1
        mineralNode.physicsBody?.categoryBitMask = 0b0001
        mineralNode.physicsBody?.allowsRotation = false
        addChild(mineralNode)
        if self.previousPlayerRunningState == .RUNNINGRIGHT {
            mineralNode.position.x = self.player.position.x + mineralNode.size.width
            mineralNode.physicsBody?.applyImpulse(CGVector(dx: 10, dy: -30))
        } else {
            mineralNode.position.x = self.player.position.x - mineralNode.size.width
            mineralNode.physicsBody?.applyImpulse(CGVector(dx: -10, dy: -30))
        }
        
    }
    
    private func handleThrow () {
        if self.playerAction == .THROW {
            if self.throwingMineral == .ANTIGRAV && self.player.hasAntigrav {
                let mineralNode = SKSpriteNode(imageNamed: "Blue Crystal")
                mineralNode.name = "mineral-gravity"
                self.showThrowMineral(mineralNode: mineralNode)
            } else if self.throwingMineral == .IMPULSE {
                let mineralNode = SKSpriteNode(imageNamed: "Red Crystal")
                mineralNode.name = "mineral-impulse"
                self.showThrowMineral(mineralNode: mineralNode)
            }
        }
        
        self.playerAction = .NONE
    }
    
    private func handlePlayerRotation (dt: TimeInterval) {
        if self.playerState == .INAIR {
            self.rotateJumpingPlayer(rotation: -Double(dt * 500))
        } else {
            self.player.zRotation = 0.0
        }
    }
    
    private func handleJump () {
        if self.playerState == .JUMP {
            self.jump()
        }
    }
    
    private func moveCamera() {
        if self.player.position.x > 750 && self.player.position.x < 31360 {
            self.camera?.position.x = self.player.position.x
        }
        
        if self.player.position.y > 400 {
            self.camera?.position.y = self.player.position.y
        } else {
            self.camera?.position.y = -159
        }
        
        
    }
    
    private func moveBackground (distance: CGFloat) {
        
    }
    
    private func updatePlayerImage () {
        
    }
}
