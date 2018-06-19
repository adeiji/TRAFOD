//
//  World.swift
//  TRAFOD
//
//  Created by adeiji on 6/15/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import GameKit
import SpriteKit

class World: SKScene, SKPhysicsContactDelegate {
    
    var player:Player!
    var lastPointOnGround:CGPoint?
    var entities = [GKEntity]()
    
    private let antiGravCounterThrowNode = SKSpriteNode(imageNamed: "Blue Crystal")
    private let antiGravCounterNode = SKSpriteNode(imageNamed: "Blue Crystal")
    private let antiGravCounterLabel = SKLabelNode(text: "0")
    private var explanation:SKSpriteNode!
    private let impulseCounterThrowNode = SKSpriteNode(imageNamed: "Red Crystal")
    private let impulseCounterNode = SKSpriteNode(imageNamed: "Red Crystal")
    private let impulseCounterLabel = SKLabelNode(text: "0")
    
    var jumpButton:SKNode!
    var throwButton:SKNode!
    var throwImpulseButton:SKNode!
    
    var playerRunningState:PlayerRunningState = .STANDING
    var playerState:PlayerState = .ONGROUND
    var previousPlayerRunningState:PlayerRunningState = .STANDING
    private var playerAction:PlayerAction = .NONE
    
    var forces:[Minerals] = [Minerals]()
    private var gravityTimeLeft:Int = 0
    let antiGravViewKey = "antiGravView"
    
    private var originalTouchPosition:CGPoint?
    private var throwingMineral:Minerals!
    
    private var ground:SKShapeNode?
    
    private var runTime:TimeInterval = TimeInterval()
    private var stepCounter = 0
        
    var cameraYPosition:CGFloat = 0
    
    var backgroundMusic:SKAudioNode!
    var ambiance:SKAudioNode!
    
    private let abyssKey = "abyss"
    
    private let playerNodeType:UInt32 = 2
    private let portalNodeType:UInt32 = 5
    var rain:SKEmitterNode!
    
    var lastUpdateTime : TimeInterval = 0
    var gravityTimeLeftLabel:SKLabelNode!
    
    var isFalling = false
    var rewindPoints = [CGPoint]()
    var rewindPointCounter = 0
    
    var collectedElements:[Levels:[String]] = [Levels:[String]]()
    var sounds:SoundManager?
    var currentLevel:Levels?    
    
    enum Levels {
        case LEVEL1
        case LEVEL2
    }
    
    enum PlayerAction {
        case THROW
        case NONE
    }
    
    enum PlayerState {
        case INAIR
        case JUMP
        case ONGROUND
        case HITPORTAL
        case DEAD
    }
    
    enum PlayerRunningState {
        case RUNNINGLEFT
        case RUNNINGRIGHT
        case STANDING
    }
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
    }
    
    override func didMove(to view: SKView) {
        self.jumpButton = self.camera?.childNode(withName: "jumpButton")
        self.throwButton = self.camera?.childNode(withName: "throwButton")
        self.throwImpulseButton = self.camera?.childNode(withName: "throwImpulseButton")
        self.sounds = SoundManager(world: self)
        self.previousPlayerRunningState = .RUNNINGRIGHT
        if self.throwButton != nil {
            self.throwButton.isHidden = true
        }
        
        self.jumpButton.isHidden = true
        
        if self.throwImpulseButton != nil {
            self.throwImpulseButton.isHidden = true
        }
        
        self.addJumpButton()
        self.removeCollectedElements()
        self.enumerateChildNodes(withName: "ground") { (node, pointer) in
            node.physicsBody?.friction = 1.0
        }                
    }
    
    func createPlayer () {
        
        self.player = Player(imageNamed: "standing")
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
        
        addChild(self.player)
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
    
    func showMineralCount () {
        for key in self.player.mineralCounts.keys {
            if let count = self.player.mineralCounts[key] {
                if key == .ANTIGRAV {
                    if self.throwButton.isHidden == true {
                        self.addThrowButton()
                    }
                    
                    self.antiGravCounterNode.position = CGPoint(x: -570, y: 400)
                    self.antiGravCounterLabel.position = CGPoint(x: -500,  y: 390)
                    self.antiGravCounterLabel.fontSize = 50
                    self.antiGravCounterLabel.fontName = "HelveticaNeue-Bold"
                    
                    if self.antiGravCounterNode.parent == nil {
                        self.camera?.addChild(self.antiGravCounterNode)
                        self.camera?.addChild(self.antiGravCounterLabel)
                    }
                    
                    self.antiGravCounterLabel.text = "\(count)"
                } else if key == .IMPULSE {
                    if self.throwImpulseButton.isHidden == true {
                        self.addThrowImpulseButton()
                    }
                    
                    self.impulseCounterNode.position = CGPoint(x: -400, y: 400)
                    self.impulseCounterLabel.position = CGPoint(x: -330,  y: 390)
                    self.impulseCounterLabel.fontSize = 50
                    self.impulseCounterLabel.fontName = "HelveticaNeue-Bold"
                    
                    if self.impulseCounterNode.parent == nil {
                        self.camera?.addChild(self.impulseCounterNode)
                        self.camera?.addChild(self.impulseCounterLabel)
                    }
                    
                    
                    self.impulseCounterLabel.text = "\(count)"
                }
            }
        }
    }
    
    func addJumpButton () {
        self.jumpButton.isHidden = false
    }
    
    func addThrowButton () {
        self.throwButton.isHidden = false
    }
    
    func addThrowImpulseButton () {
        self.throwImpulseButton.isHidden = false
    }
    
    func impulseUsed (crashPosition: CGPoint) {
        // Add an impulse node to the screen
        self.playSound(sound: .MINERALCRASH)
        
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
        
        var oneRevolution:SKAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1)
        var repeatRotation:SKAction = SKAction.repeatForever(oneRevolution)
        impulseNode.run(repeatRotation)
        
        let warpTime = SKAction.wait(forDuration: 10.0)
        let timeNode = SKLabelNode()
        timeNode.fontSize = 40
        timeNode.zPosition = 5
        impulseNode.addChild(timeNode)
        
        oneRevolution = SKAction.rotate(byAngle: CGFloat.pi * -2, duration: 1)
        repeatRotation = SKAction.repeatForever(oneRevolution)
        timeNode.run(repeatRotation)
        
        
        self.showImpulseTimeLeft(timeNode: timeNode)
        let impulseBlock = SKAction.run {
            impulseNode.removeFromParent()
        }
        
        let sequence = SKAction.sequence([warpTime, impulseBlock])
        run(sequence)
        
        self.addChild(impulseNode)
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
    
    func playSound (sound: Sounds) {
        if let sounds = self.sounds {
            sounds.playSound(sound: sound)
        }
    }
    
    func antiGravUsed () {
        self.playSound(sound: .MINERALCRASH)
        self.playSound(sound: .ANTIGRAV)
        
        
        if !self.forces.contains(.ANTIGRAV) {
            self.physicsWorld.gravity.dy = self.physicsWorld.gravity.dy / 2.2
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
            timeLabel.zPosition = 5
            self.gravityTimeLeftLabel = timeLabel
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
                if let _ = self.forces.index(of: .ANTIGRAV) {
                    self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
                    self.forces.remove(at: self.forces.index(of: .ANTIGRAV)!)
                    antiGravView?.isHidden = true
                    timeLabel.removeFromParent()
                }
            }
        }
        
        let sequence = SKAction.sequence([seconds, changeGravityBlock])
        run(sequence)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
        if self.explanation != nil && self.nodes(at: pos).contains(self.jumpButton) {
            self.explanation.removeFromParent()
            self.explanation = nil
        } else if self.explanation != nil {
            return
        }
        
        if self.jumpButton != nil && self.nodes(at: pos).contains(self.jumpButton) {
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactAName = contact.bodyA.node?.name ?? ""
        let contactBName = contact.bodyB.node?.name ?? ""
        print("Contact initiated...")
        if (contactAName == "dawud") || (contactBName == "dawud") {
            if contactAName.contains("ground") || contactBName.contains("ground") {
                if contact.contactNormal.dy == 1 {
                    self.player.zRotation = 0.0
                    self.lastPointOnGround = self.player.position
                    self.playerState = .ONGROUND
                    self.playSound(sound: .LANDED)
                    var point = self.player.position
                    if let node = getContactNode(string: "ground", contact: contact) {
                        point.x = node.position.x
                    }
                    
                    self.rewindPoints = [point]
                }
            }
        }
        
        if contactContains(strings: ["ground", "mineral", "gravity"], contactA: contactAName , contactB: contactBName) {
            self.antiGravUsed()
            self.showMineralCrash(withColor: UIColor.Style.ANTIGRAVMINERAL, contact: contact, duration: 2)
            if let node = getContactNode(string: "mineral", contact: contact) {
                node.removeFromParent()
            }
        }
        
        if contactContains(strings: ["ground", "mineral", "impulse"], contactA: contactAName , contactB: contactBName) {
            self.impulseUsed(crashPosition: contact.contactPoint)
            self.showMineralCrash(withColor: UIColor.Style.IMPULSEMINERAL, contact: contact, duration: 2)
            if let node = getContactNode(string: "mineral", contact: contact) {
                node.removeFromParent()
            }
        }
        
        if contactContains(strings: ["dawud", "portal"], contactA: contactAName , contactB: contactBName) {
            if let node = getContactNode(string: "portal", contact: contact) {
                self.portalHit(portalNode: node as! SKSpriteNode)
                node.removeFromParent()
            }
        }
        
        if contactContains(strings: ["dawud", self.abyssKey], contactA: contactAName, contactB: contactBName) {
            self.playerState = .DEAD
        }
        
        if contactContains(strings: ["dawud", "getImpulse"], contactA: contactAName, contactB: contactBName) {
            self.getImpulse()
            
            if let node = getContactNode(string: "getImpulse", contact: contact) {
                self.addToCollectedElements(node: node)
                node.removeFromParent()
            }
        }
        
        if contactContains(strings: ["dawud", "getAntiGrav"], contactA: contactAName , contactB: contactBName) {
            self.getAntiGrav()
            
            if let node = getContactNode(string: "getAntiGrav", contact: contact) {
                self.addToCollectedElements(node: node)
                node.removeFromParent()
            }
        }
    }
    
    func getCollectedElements (level: String) {
        if let elements = ProgressTracker.getElementsCollected() {
            for element in elements {
                if element.level == level {
                    for node in element.nodes {
                        if element.level == GameLevels.level1 {
                            if self.collectedElements[.LEVEL1] == nil {
                               self.collectedElements[.LEVEL1] = [String]()
                            }
                            self.collectedElements[.LEVEL1]?.append(node)
                        }
                    }
                }
            }
        }
    }
    
    func addToCollectedElements (node:SKNode) {
        if let level = self.currentLevel {
            if self.collectedElements[level] == nil {
                self.collectedElements[level] = [String]()
            }
            
            if let name = node.name {
                self.collectedElements[level]?.append(name)
                ProgressTracker.updateElementsCollected(level: GameLevels.level1, node: name)
            }
        }
    }
    
    func playerIsFalling () -> Bool {
        
        if let point = self.lastPointOnGround {
            if self.player.position.y < point.y {
                return true
            }
        }
        
        return false
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
        self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 500))
        self.player.texture = SKTexture(imageNamed: "spinning")
        self.playerState = .INAIR
    }
    
    func rotateJumpingPlayer (rotation: Double) {
        if self.previousPlayerRunningState == .RUNNINGRIGHT || self.previousPlayerRunningState == .STANDING {
            self.player.zRotation = self.player.zRotation + CGFloat(Double.pi / rotation)
        } else if self.previousPlayerRunningState == .RUNNINGLEFT {
            self.player.zRotation = self.player.zRotation - CGFloat(Double.pi / rotation)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
        if self.explanation != nil {
            return
        }
        
        if let originalPos = self.originalTouchPosition {
            let differenceInXPos = originalPos.x - pos.x
            if abs(differenceInXPos) > 10 {
                if differenceInXPos < 0 {
                    if self.playerRunningState == .STANDING {
                        self.playSound(sound: .RUN)
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
        self.playerRunningState = .STANDING
        self.sounds?.stopSoundWithKey(key: Sounds.RUN.rawValue)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
    
    func showRunning (currentTime: TimeInterval) {
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
                
                if let stepParticlePath = Bundle.main.path(forResource: "GroundParticle", ofType: "sks") {
                    if let stepParticle = NSKeyedUnarchiver.unarchiveObject(withFile: stepParticlePath) as? SKEmitterNode {                        
                        stepParticle.position = self.player.position
                        stepParticle.position.y = stepParticle.position.y - 50
                        let fade = SKAction.fadeAlpha(to: 0.0, duration: 2)
                        self.addChild(stepParticle)
                        stepParticle.run(fade)
                        let timer = SKAction.wait(forDuration: 2.0)
                        let block = SKAction.run {
                            stepParticle.removeFromParent()
                        }
                        
                        if self.forces.contains(.ANTIGRAV) {
                            stepParticle.particleColor = UIColor.Style.ANTIGRAVMINERAL
                        }
                        
                        let sequence = SKAction.sequence([timer, block])
                        self.run(sequence)
                    }
                }
            }
            
            
        }
    }
    
    func handlePlayerDied () {
        if let point = self.lastPointOnGround {
            self.player.position = point
        }
        
        self.player.zRotation = 0.0
        self.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.playerRunningState = .STANDING
        self.playerState = .ONGROUND
    }
    
    func handleImpulse () {
        if let index = self.forces.index(of: .IMPULSE) {
            self.forces.remove(at: index)
            if self.player.physicsBody!.velocity.dx > 0.0 {
                self.player.physicsBody?.applyImpulse(CGVector(dx: 600, dy: 250))
            } else {
                self.player.physicsBody?.applyImpulse(CGVector(dx: -600, dy: 250))
            }
        }
    }
    
    func portalHit (portalNode: SKSpriteNode) {
        self.forces.append(.IMPULSE)
    }
    
    func showMineralCrash (withColor color: UIColor, contact: SKPhysicsContact, duration: TimeInterval = 5) {
        if let crashPath = Bundle.main.path(forResource: "GroundParticle", ofType: "sks") {
            if let crash = NSKeyedUnarchiver.unarchiveObject(withFile: crashPath) as? SKEmitterNode {
                crash.position = contact.contactPoint
                crash.position.y = crash.position.y + 10
                crash.particleColor = color
                crash.particleColorSequence = nil
                self.addChild(crash)
                
                let timeToShowSpark = SKAction.wait(forDuration: duration)
                let removeSparkBlock = SKAction.run {
                    crash.removeFromParent()
                }
                
                let sequence = SKAction.sequence([timeToShowSpark, removeSparkBlock])
                self.run(sequence)
            }
        }
    }
    
    func showThrowMineral (mineralNode: SKSpriteNode) {
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
        mineralNode.physicsBody?.collisionBitMask = 0
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
    
    func handleThrow () {
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
    
    func handlePlayerRotation (dt: TimeInterval) {
        if self.playerState == .INAIR {
            self.rotateJumpingPlayer(rotation: -Double(dt * 500))
        } else {
            self.player.zRotation = 0.0
        }
    }
    
    func handleJump () {
        if self.playerState == .JUMP {
            self.jump()
        }
    }
    
    func playMineralSound () {
        let getMineralSound = SKAction.playSoundFileNamed("mineralgrab", waitForCompletion: false)
        run(getMineralSound)
    }
    
    func playSound (fileName: String) {
        let sound = SKAction.playSoundFileNamed(fileName, waitForCompletion: false)
        run(sound)
    }
    
    func getImpulse () {
        if self.player.hasImpulse == false {
            self.player.hasImpulse = true
            ProgressTracker.updateProgress(currentLevel: nil, player: self.player)
            self.showMineralReceivedBox(nodeName: "impulseRecievedBox")
        }
        
        if var count = self.player.mineralCounts[.IMPULSE] {
            count = count + 10
            self.player.mineralCounts[.IMPULSE] = count
        } else {
            self.player.mineralCounts[.IMPULSE] = 10
        }
        
        ProgressTracker.updateMineralCount(myMineral: Minerals.IMPULSE.rawValue, count: self.player.mineralCounts[.IMPULSE]!)
        
        self.playMineralSound()
        self.showMineralCount()
    }
    
    func getAntiGrav () {
        
        if var count = self.player.mineralCounts[.ANTIGRAV] {
            count = count + 10
            self.player.mineralCounts[.ANTIGRAV] = count
        } else {
            self.player.mineralCounts[.ANTIGRAV] = 10
        }
        
        ProgressTracker.updateMineralCount(myMineral: Minerals.ANTIGRAV.rawValue, count: self.player.mineralCounts[.ANTIGRAV]!)
        
        self.playMineralSound()
        self.showMineralCount()
        
        if self.player.hasAntigrav == false {            
            self.player.hasAntigrav = true
            ProgressTracker.updateProgress(currentLevel: nil, player: self.player)
            self.showMineralReceivedBox(nodeName: "antigravRecievedBox")
        }
    }
    
    func showMineralReceivedBox (nodeName: String) {
        self.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.explanation = self.childNode(withName: nodeName) as! SKSpriteNode
        self.childNode(withName: nodeName)?.alpha = 1.0
        let fade = SKAction.fadeAlpha(to: 1.0, duration: 1.0)
        self.childNode(withName: nodeName)?.run(fade)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Called before each frame is rendered
        self.rewindPoints.append(self.player.position)
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
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
            self.handleThrow()
        }
    }
    
    func showBackgroundParticles () {
        if let backgroundParticlesPath = Bundle.main.path(forResource: "Background", ofType: "sks") {
            if let backgroundParticles = NSKeyedUnarchiver.unarchiveObject(withFile: backgroundParticlesPath) as? SKEmitterNode {
                backgroundParticles.particleColor = UIColor(red: 22.0/255.0, green: 43.0/255.0, blue: 87.0/255.0, alpha: 1.0)
                backgroundParticles.particlePositionRange.dx = self.scene!.size.width
                backgroundParticles.particlePositionRange.dy = self.scene!.size.height
                backgroundParticles.zPosition = -35
                self.camera?.addChild(backgroundParticles)
            }
        }
    }
    
    func showFireFlies () {
        if let fireFliesParticlesPath = Bundle.main.path(forResource: "FireFlies", ofType: "sks") {
            if let fireFliesParticles = NSKeyedUnarchiver.unarchiveObject(withFile: fireFliesParticlesPath) as? SKEmitterNode {
                fireFliesParticles.particlePositionRange.dx = self.scene!.size.width
                fireFliesParticles.particlePositionRange.dy = self.scene!.size.height
                fireFliesParticles.zPosition = 0
                self.camera?.addChild(fireFliesParticles)
            }
        }
    }
    
    func showRain () {
        if let rainPath = Bundle.main.path(forResource: "Rain", ofType: "sks") {
            if let rain = NSKeyedUnarchiver.unarchiveObject(withFile: rainPath) as? SKEmitterNode {
                rain.particlePositionRange.dx = self.scene!.size.width
                rain.position = CGPoint(x: 0, y: (self.scene!.size.height / 2.0) + 100)
                self.camera?.addChild(rain)
                self.rain = rain
            }
        }
    }
    
    func showMineralParticles () {
        for child in self.children {
            if child.name == "getAntiGrav" || child.name == "getImpulse" {
                if let magicPath = Bundle.main.path(forResource: "Magic", ofType: "sks") {
                    if let magic = NSKeyedUnarchiver.unarchiveObject(withFile: magicPath) as? SKEmitterNode {
                        if child.name == "getAntiGrav" {
                            magic.particleColor = UIColor.Style.ANTIGRAVMINERAL
                        } else {
                            magic.particleColor = UIColor.Style.IMPULSEMINERAL
                        }
                        magic.position = CGPoint(x: 0, y: 0)
                        child.addChild(magic)
                    }
                }
                
            }
        }
    }
    
    func showGroundParticles () {
        for child in self.children {
            if child.name == "ground" {
                if let magicPath = Bundle.main.path(forResource: "RainPatter", ofType: "sks") {
                    if let magic = NSKeyedUnarchiver.unarchiveObject(withFile: magicPath) as? SKEmitterNode {
                        magic.position = CGPoint(x: 0, y: 0)
                        child.addChild(magic)
                    }
                }
            }
        }
    }
    @discardableResult
    func transitionToNextScreen (filename: String, player: Player? = nil) -> World? {
        let world = World(fileNamed: filename)
        if let player = player {
            world?.player = player
        } else {
            world?.player = self.player
        }
        
        let transition = SKTransition.moveIn(with: .right, duration: 1)
        world?.scaleMode = SKSceneScaleMode.aspectFit
        self.player.removeFromParent()
        self.view?.presentScene(world!, transition: transition)
        
        return world
    }
    
    func removeCollectedElements () {
        if let level = self.currentLevel {
            if let elements = self.collectedElements[level] {
                for nodeName in elements {
                    if let node = self.childNode(withName: nodeName) {
                        node.removeFromParent()
                    }
                }
            }
        }
    }
}
