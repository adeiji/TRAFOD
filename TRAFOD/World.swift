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
    
    var previousWorldCameraPosition:CGPoint!
    var previousWorldPlayerPosition:CGPoint!
    
    // Cannons
    // The cannon objects that are in various level
    var cannons:[Cannon]?
    var cannonTimes:[TimeInterval] = [ 3.0, 8.0, 3.0, 5.0, 7.0 ]
    
    var player:Player!
    var lastPointOnGround:CGPoint?
    var entities = [GKEntity]()
    
    private let antiGravCounterThrowNode = SKSpriteNode(imageNamed: "Blue Crystal")
    private let antiGravCounterNode = SKSpriteNode(imageNamed: "Blue Crystal")
    private let antiGravCounterLabel = SKLabelNode(text: "0")
    
    private let impulseCounterThrowNode = SKSpriteNode(imageNamed: "Red Crystal")
    private let impulseCounterNode = SKSpriteNode(imageNamed: "Red Crystal")
    private let impulseCounterLabel = SKLabelNode(text: "0")
    
    private let teleportCounterThrowNode = SKSpriteNode(imageNamed: "Blue Crystal")
    private let teleportCounterNode = SKSpriteNode(imageNamed: "Blue Crystal")
    private let teleportCounterLabel = SKLabelNode(text: "0")
    
    private var counterNodes = [String:SKNode]()
    
    var messageBox:SKSpriteNode!
    var jumpButton:SKNode!
    
    
    var throwButton:SKNode!
    var throwImpulseButton:SKNode!
    var throwTeleportButton:SKNode?
    
    var throwButtons:[String:SKNode] = [String:SKNode]()
    
    var grabButton:SKNode?
    
    var forces:[Minerals] = [Minerals]()
    var impulses:[Minerals] = [Minerals]()
    
    var gravityTimeLeft:Int = 0
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
    
    var impulseObjects:[SKNode] = [SKNode]()
    /**
     - todo: Make sure that this is not a Rock object but instead use a protocol for all objects that can be reset when hitting another object
     */
    var objectsToReset:[SKSpriteNode] = [SKSpriteNode]()
    
    var teleportNode:SKNode?
    var volumeIsMuted:Bool = false
    let physicsHandler = PhysicsHandler()
    
    enum Levels:String {
        case LEVEL1 = "GameScene"
        case LEVEL2 = "Level2"
        case LEVEL3 = "Level3"
    }
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
    }
    
    func setupCounterNodes () {
        self.counterNodes["\(CounterNodes.AntiGrav)\(CounterNodes.CounterNode)"] = SKSpriteNode(imageNamed: ImageNames.BlueCrystal.rawValue)
        self.counterNodes["\(CounterNodes.AntiGrav)\(CounterNodes.ThrowButtonNode)"] = SKSpriteNode(imageNamed: ImageNames.BlueCrystal.rawValue)
        self.counterNodes["\(CounterNodes.AntiGrav)\(CounterNodes.Label)"] = SKLabelNode(text: "0")
        
        self.counterNodes["\(CounterNodes.Impulse)\(CounterNodes.CounterNode)"] = SKSpriteNode(imageNamed: ImageNames.BlueCrystal.rawValue)
        self.counterNodes["\(CounterNodes.Impulse)\(CounterNodes.ThrowButtonNode)"] = SKSpriteNode(imageNamed: ImageNames.BlueCrystal.rawValue)
        self.counterNodes["\(CounterNodes.Impulse)\(CounterNodes.Label)"] = SKLabelNode(text: "0")
        
        self.counterNodes["\(CounterNodes.Teleport)\(CounterNodes.CounterNode)"] = SKSpriteNode(imageNamed: ImageNames.RedCrystal.rawValue)
        self.counterNodes["\(CounterNodes.Teleport)\(CounterNodes.ThrowButtonNode)"] = SKSpriteNode(imageNamed: ImageNames.RedCrystal.rawValue)
        self.counterNodes["\(CounterNodes.Teleport)\(CounterNodes.Label)"] = SKLabelNode(text: "0")
        
        self.counterNodes["\(CounterNodes.FlipGravity)\(CounterNodes.CounterNode)"] = SKSpriteNode(imageNamed: ImageNames.RedCrystal.rawValue)
        self.counterNodes["\(CounterNodes.FlipGravity)\(CounterNodes.ThrowButtonNode)"] = SKSpriteNode(imageNamed: ImageNames.RedCrystal.rawValue)
        self.counterNodes["\(CounterNodes.FlipGravity)\(CounterNodes.Label)"] = SKLabelNode(text: "0")
    }
    
    func setupThrowButton (crystalImageName: ImageNames, mineralType: CounterNodes, pos: CGPoint) {
        if self.throwButtons["\(mineralType)"] == nil
        {
            let throwOutline = SKTexture(imageNamed: "throwbutton")
            let button = SKSpriteNode(texture: throwOutline, color: .clear, size: throwOutline.size())
            button.position = pos
            button.addChild(SKSpriteNode(imageNamed: crystalImageName.rawValue))
            self.camera?.addChild(button)
            self.throwButtons["\(mineralType)"] = button
        }
    }
    
    override func didMove(to view: SKView) {
        self.setupPlayer()
        self.setupCounterNodes()
        self.jumpButton = self.camera?.childNode(withName: "jumpButton")
        self.throwButton = self.camera?.childNode(withName: "throwButton")
        self.throwImpulseButton = self.camera?.childNode(withName: "throwImpulseButton")
        self.throwTeleportButton = self.camera?.childNode(withName: "throwTeleportButton")
        self.grabButton = self.camera?.childNode(withName: "grabButton")
        
        self.grabButton?.isUserInteractionEnabled = false
        self.grabButton?.isHidden = true
        
        self.sounds = SoundManager(world: self)
        self.player.previousRunningState = .RUNNINGRIGHT
        if self.throwButton != nil {
            self.throwButton.isHidden = true
        }
        
        self.jumpButton.isHidden = true
        
        if self.throwImpulseButton != nil {
            self.throwImpulseButton.isHidden = true
        }
        
        self.addJumpButton()
        self.showDoubleGravParticles(color: .yellow)
        self.enumerateChildNodes(withName: "ground") { (node, pointer) in
            node.physicsBody?.friction = 1.0
        }
        
        self.getCannons()
        self.removeCollectedElements()
        self.showDoorParticles()
        self.changeMineralPhysicsBodies()
        self.showResetParticles()
        self.showResetParticles(nodeName: "rocks")
        self.showNoWarpParticles()
        self.playBackgroundMusic(fileName: "Level2")
        self.showBackgroundParticles()
        self.showFireFlies()        
    }
    
    func getProgress () {
        if let progress = ProgressTracker.getProgress() {
            self.player.hasAntigrav = progress.hasAntigrav
            self.player.hasImpulse = progress.hasImpulse
        }
    }
    
    func createPlayer () {
        self.player = Player(imageNamed: "standing")
        self.player.previousRunningState = .RUNNINGRIGHT
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
        self.player.physicsBody?.contactTestBitMask = 1 | UInt32(PhysicsCategory.InteractableObjects) | UInt32(PhysicsCategory.NonInteractableObjects) | UInt32(PhysicsCategory.Minerals)
        self.player.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.InteractableObjects)
        self.player.physicsBody?.allowsRotation = false
        self.player.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Player)
        self.listener = self.player
        addChild(self.player)
    }
    
    func changeMineralPhysicsBodies () {
        for node in self.children {
            func addAllMinerals (mineralGroup: MineralGroup) {
                mineralGroup.children.forEach { (mineral) in
                    if mineral.name == "FLIP_GRAVITY" {
                        let flipGravityMineral = FlipGravityRetrieveMineral(texture: SKTexture(imageNamed: ImageNames.BlueCrystal.rawValue))
                        mineral.addChild(flipGravityMineral)
                    }
                }
            }
            
            if let node = node as? MineralGroup {
                addAllMinerals(mineralGroup: node)
            }
            
            
            if let name = node.name {
                if name.contains("getAntiGrav") || name.contains("getImpulse") {
                    if let _ = node.physicsBody {
                        if let node = node as? SKSpriteNode {
                            if let size = node.texture?.size() {
                                node.physicsBody = SKPhysicsBody(rectangleOf: size)
                                node.physicsBody?.affectedByGravity = false
                                node.physicsBody?.restitution = 0
                                node.physicsBody?.mass = 0
                                node.physicsBody?.isDynamic = true
                                node.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.NonInteractableObjects)
                                node.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Nothing)
                                node.physicsBody?.allowsRotation = false
                            }
                        }
                    }
                }
            }
        }
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
                } else if key == .TELEPORT {
                    if self.throwTeleportButton?.isHidden == true {
                        self.addThrowMineralButton(type: .TELEPORT)
                    }
                    
                    self.teleportCounterNode.position = CGPoint(x: -230, y: 400)
                    self.teleportCounterLabel.position = CGPoint(x: -160,  y: 390)
                    self.teleportCounterLabel.fontSize = 50
                    self.teleportCounterLabel.fontName = "HelveticaNeue-Bold"
                    
                    if self.teleportCounterNode.parent == nil {
                        self.camera?.addChild(self.teleportCounterNode)
                        self.camera?.addChild(self.teleportCounterLabel)
                    }
                    
                    self.teleportCounterLabel.text = "\(count)"
                } else if key == .FLIPGRAVITY {
                    self.setupThrowButton(crystalImageName: .RedCrystal, mineralType: .FlipGravity, pos: CGPoint(x: 762, y: -127                                                    ))
                    self.setupMineralCounterAndUseNodes(mineralType: .FlipGravity, counterMineralNodePos: CGPoint(x: -60, y: 390), count: count)
                }
            }
        }
    }
    
    func setupMineralCounterAndUseNodes (mineralType: CounterNodes, counterMineralNodePos: CGPoint, count: Int) {
        let mineralThrowNode = self.counterNodes["\(mineralType)\(CounterNodes.ThrowButtonNode)"]
        let mineralCounterNode = self.counterNodes["\(mineralType)\(CounterNodes.CounterNode )"]
        let mineralCounterLabel = self.counterNodes["\(mineralType)\(CounterNodes.Label )"] as? SKLabelNode
        
        mineralThrowNode?.isHidden = false
        mineralCounterLabel?.fontSize = 50
        mineralCounterLabel?.fontName = "HelveticaNeue-Bold"
        mineralCounterNode?.position = counterMineralNodePos
        mineralCounterLabel?.position = counterMineralNodePos
        mineralCounterLabel?.position.x = counterMineralNodePos.x + 75
        
        if mineralCounterNode?.parent == nil {
            self.camera?.addChild(mineralCounterNode!)
            self.camera?.addChild(mineralCounterLabel!)
        }
        
        mineralCounterLabel?.text = "\(count)"
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
    
    func addThrowMineralButton (type: Minerals) {
        switch type {
        case .ANTIGRAV:
            self.throwButton.isHidden = false
            break;
        case .IMPULSE:
            self.throwImpulseButton.isHidden = false
            break;
        case .TELEPORT:
            self.throwImpulseButton.isHidden = false
            break;
        default:
            break;
        }
    }
    
    func impulseUsed (crashPosition: CGPoint) {
        // Add an impulse node to the screen
        self.playSound(sound: .MINERALCRASH)
        
        if self.impulses.count < 3 {
            let impulseNode = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 200))
            impulseNode.position = crashPosition
            
            if let portalPath = Bundle.main.path(forResource: "Doors", ofType: "sks") {
                if let portal = NSKeyedUnarchiver.unarchiveObject(withFile: portalPath) as? SKEmitterNode {
                    portal.particleBirthRate = portal.particleBirthRate * 2.0

                    portal.particlePositionRange.dx = portal.particlePositionRange.dx * 2.0
                    portal.particleColor = .orange
                    impulseNode.addChild(portal)
                }
            }
            
            if self.player.previousRunningState == .RUNNINGRIGHT {
                impulseNode.position.x = impulseNode.position.x + 150
            } else {
                impulseNode.position.x = impulseNode.position.x - 150
            }
            
            impulseNode.zPosition = -5
            impulseNode.position.y = impulseNode.position.y + impulseNode.size.height / 2.0
            impulseNode.name = "portal"
            impulseNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: impulseNode.size.height))
            impulseNode.physicsBody?.allowsRotation = false
            impulseNode.physicsBody?.pinned = false
            impulseNode.physicsBody?.affectedByGravity = false
            impulseNode.physicsBody?.isDynamic = true
            impulseNode.physicsBody?.collisionBitMask = 0
            impulseNode.physicsBody?.categoryBitMask = 0b0001
            
            let warpTime = SKAction.wait(forDuration: 10.0)
            let timeNode = SKLabelNode()
            timeNode.fontSize = 40
            timeNode.zPosition = 5
            impulseNode.addChild(timeNode)
            
            self.showImpulseTimeLeft(timeNode: timeNode)
            let impulseBlock = SKAction.run {
                
                if let _ = impulseNode.parent {
                    if let _ = self.impulses.last {
                        self.impulses.removeLast()
                    }
                }
                
                impulseNode.removeFromParent()
            }
            
            let sequence = SKAction.sequence([warpTime, impulseBlock])
            run(sequence)
            
            self.addChild(impulseNode)
            self.impulses.append(.IMPULSE)
        }
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
    
    func mineralUsed (particleResourceName: String, mineralNodeName: Minerals, crashPosition: CGPoint) {
        // Add an impulse node to the screen
        self.playSound(sound: .MINERALCRASH)
        
        let teleportNode = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 200))
        teleportNode.position = crashPosition
        
        if let portalPath = Bundle.main.path(forResource: particleResourceName, ofType: "sks") {
            if let portal = NSKeyedUnarchiver.unarchiveObject(withFile: portalPath) as? SKEmitterNode {
                portal.particleBirthRate = portal.particleBirthRate * 2.0
                
                portal.particlePositionRange.dx = portal.particlePositionRange.dx * 2.0
                portal.particleColor = .orange
                teleportNode.addChild(portal)
            }
        }
        
        teleportNode.position.x = teleportNode.position.x
        teleportNode.zPosition = -5
        teleportNode.position.y = teleportNode.position.y + teleportNode.size.height / 2.0
        teleportNode.name = "mineral-used"
        teleportNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: teleportNode.size.height))
        teleportNode.physicsBody?.allowsRotation = false
        teleportNode.physicsBody?.pinned = false
        teleportNode.physicsBody?.affectedByGravity = false
        teleportNode.physicsBody?.isDynamic = true
        teleportNode.physicsBody?.collisionBitMask = 0
        teleportNode.physicsBody?.categoryBitMask = 0b0001
        
        self.teleportNode = teleportNode
        self.addChild(teleportNode)
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
        
        if let camera = self.camera, let zoomOut = camera.childNode(withName: "zoomOut") {
            if self.nodes(at: pos).contains(zoomOut) {
                if camera.xScale == 1 {
                    self.camera?.xScale = 2
                    self.camera?.yScale = 2
                } else if camera.xScale == 2 {
                    camera.xScale = 1
                    camera.yScale = 1
                }
            }
        }
        
        if self.messageBox != nil && self.nodes(at: pos).contains(self.jumpButton) {
            self.messageBox.removeFromParent()
            self.messageBox = nil
        } else if self.messageBox != nil {
            return
        }
        
        self.handleGrabButtonActions(atPoint: pos)
        
        if self.jumpButton != nil && self.nodes(at: pos).contains(self.jumpButton) {
            if self.player.state == .ONGROUND {
                self.player.state = .JUMP
            }
        } else if self.throwButton != nil && self.nodes(at: pos).contains(self.throwButton) {
            self.player.action = .THROW
            self.throwingMineral = .ANTIGRAV
        } else if self.throwImpulseButton != nil && self.nodes(at: pos).contains(self.throwImpulseButton) {
            self.player.action = .THROW
            self.throwingMineral = .IMPULSE
        } else if let throwButton = self.throwTeleportButton, self.nodes(at: pos).contains(throwButton) {
            // User presses the teleport button
            // The way that the teleport button works is that they press it once and it activates a teleportation portal at the player's current position
            // When they press the button again, the player is automatically transported back to that position of the teleportation portal
            if let teleportNode = self.teleportNode {
                // Bring the player back to where they actived the teleport node
                self.player.position = teleportNode.position
                self.teleportNode?.removeFromParent()
                self.teleportNode = nil
            } else { // Throw a Teleportation mineral
                self.player.action = .THROW
                self.throwingMineral = .TELEPORT
            }
        
        } else if let throwButton = self.throwButtons["\(CounterNodes.FlipGravity)"], self.nodes(at: pos).contains(throwButton) {
            FlipGravityMineral.throwMineral(imageName: ImageNames.RedCrystal.rawValue, player: self.player, world: self)            
        } else {
            if let camera = self.camera {
                if let originalPos = self.scene?.convert(pos, to: camera) {
                    self.originalTouchPosition = originalPos
                }
            }
            
        }
    }
    
    func grabObject () {
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        self.handleGrabbedObjectContactEnded(contact: contact)
        
        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: FlipGravity.self, nodeBType: Player.self) {
            self.player.flipPlayer(flipUpsideDown: false)
        }
    }
    
    /**
     
     When the player collides with a mineral and retrieves it if it's the first time then we display a box that shows player how to use the minerals
     or it simply adds ten more minerals to the player's mineral count
     
     - Parameter type: The type of Mineral that the player is getting
     
     */
    func getMineral (type: Minerals) {
        if var mineralCount = self.player.mineralCounts[type] {
            mineralCount = mineralCount + 10
            self.player.mineralCounts[type] = mineralCount
            ProgressTracker.updateMineralCount(myMineral: type.rawValue, count: mineralCount)
        } else {
            self.player.mineralCounts[type] = 10;
            ProgressTracker.updateMineralCount(myMineral: type.rawValue, count: 10)
        }
        
        self.playMineralSound()
        self.showMineralCount()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactAName = contact.bodyA.node?.name ?? ""
        let contactBName = contact.bodyB.node?.name ?? ""
        
        if let mineral = PhysicsHandler.playerIsGrabbingMineral(contact: contact) {
            self.getMineral(type: mineral.mineralType)
            self.addToCollectedElements(node: mineral)
            return
        }
        
        if let mineral = PhysicsHandler.playerUsedFlipGrav(contact: contact) {
            self.physicsHandler.flipGravArea = try? mineral.mineralUsed(contactPosition: contact.contactPoint)
            self.addChild(self.physicsHandler.flipGravArea!)
            mineral.removeFromParent()
        }
        
        if (contactAName == "dawud") || (contactBName == "dawud") {
            if contactAName.contains("ground") || contactBName.contains("ground") {
                if self.player.position.y - contact.contactPoint.y >= (self.player.size.height / 2.0) - 10 {
                    self.player.zRotation = 0.0
                    if let physicsBody = self.player.physicsBody {
                        self.player.physicsBody?.velocity = CGVector(dx: physicsBody.velocity.dx / 2.0, dy: 0)
                        if physicsBody.velocity.dy == -260 {
                            self.playSound(sound: .LANDED)
                        }
                    }
                    
                    self.lastPointOnGround = self.player.position
                    if self.player.state != .GRABBING {
                        self.player.state = .ONGROUND
                    }
                    
                    var point = self.player.position
                    if let node = getContactNode(string: "ground", contact: contact) {
                        point.x = node.position.x
                        
                        if let node = node as? SKSpriteNode {
                            let minX = node.position.x - (node.size.width / 2.0)
                            let maxX = node.position.x + (node.size.width / 2.0)
                            
                            if self.player.position.x < minX + (self.player.size.width / 2.0) {
                                self.lastPointOnGround?.x = minX + (self.player.size.width / 2.0)
                            } else if self.player.position.x > maxX - (self.player.size.width / 2.0) {
                                self.lastPointOnGround?.x = maxX - (self.player.size.width / 2.0)
                            }
                        }
                    }
                    
                    self.rewindPoints = [point]
                }
            }
        }
        
        if PhysicsHandler.contactContains(strings: ["ground", "mineral", "teleport"], contactA: contactAName , contactB: contactBName) {
            self.mineralUsed(particleResourceName: "Doors", mineralNodeName: .USED_TELEPORT, crashPosition: contact.contactPoint)
            self.showMineralCrash(withColor: UIColor.Style.ANTIGRAVMINERAL, contact: contact, duration: 2)
            if let node = getContactNode(string: "mineral", contact: contact) {
                node.removeFromParent()
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["ground", "mineral", "gravity"], contactA: contactAName , contactB: contactBName) {
            if !PhysicsHandler.contactContains(strings: ["noantigrav"], contactA: contactAName, contactB: contactBName) {
                self.antiGravUsed()
                self.showMineralCrash(withColor: UIColor.Style.ANTIGRAVMINERAL, contact: contact, duration: 2)
            }
            
            if let node = getContactNode(string: "mineral", contact: contact) {
                node.removeFromParent()
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["ground", "mineral", "impulse"], contactA: contactAName , contactB: contactBName) {
            if !PhysicsHandler.contactContains(strings: ["nowarp"], contactA: contactAName, contactB: contactBName) {
                self.impulseUsed(crashPosition: contact.contactPoint)
                self.showMineralCrash(withColor: UIColor.Style.IMPULSEMINERAL, contact: contact, duration: 2)
            }
            if let node = getContactNode(string: "mineral", contact: contact) {
                node.removeFromParent()
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["dawud", "portal"], contactA: contactAName , contactB: contactBName) {
            if let node = getContactNode(string: "portal", contact: contact) {
                self.portalHit(portalNode: node as! SKSpriteNode)
                node.removeFromParent()
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["cannonball", "portal"], contactA: contactAName, contactB: contactBName) {
            if let node = getContactNode(string: "portal", contact: contact) {
                self.portalHit(portalNode: node as! SKSpriteNode)
                node.removeFromParent()
            }
            
            if let node = getContactNode(string: "cannonball", contact: contact) {
                self.impulseObjects.append(node)
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["rock", "portal"], contactA: contactAName, contactB: contactBName) {
            if let node = getContactNode(string: "portal", contact: contact) {
                self.portalHit(portalNode: node as! SKSpriteNode)
                node.removeFromParent()
            }
            
            if let node = getContactNode(string: "rock", contact: contact) {
                self.impulseObjects.append(node)
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["rock", self.abyssKey], contactA: contactAName, contactB: contactBName) {
            if let node = getContactNode(string: "rock", contact: contact) as? Rock {
                self.objectsToReset.append(node)
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["dawud", self.abyssKey], contactA: contactAName, contactB: contactBName) {
            self.player.state = .DEAD
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["rock", "ground"], contact: contact) {
            if let node = getContactNode(string: "rock", contact: contact) {
                node.physicsBody?.velocity.dy = 0
            }
        }
        
        if PhysicsHandler.contactContains(strings: ["dawud", "rock"], contactA: contactAName, contactB: contactBName) {
            if self.handleContactWithGrabbableObject(contact: contact) {
                self.showGrabButton()
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["cannonball", "ground"], contact: contact) {
            if PhysicsHandler.contactContains(strings: ["rock"], contact: contact) == false {
                if let node = getContactNode(string: "cannonball", contact: contact) {
                    if let parent = node.parent {
                        // Gets the objects position relative to the scene
                        if let position = node.scene?.convert(node.position, from: parent) {
                            self.showParticle(atPosition: position, duration: 0.2)
                        }
                    }
                    
                    node.removeFromParent()
                }
            }
            
            return
        }
    }
    
    /**
     
     Gets all the elements that the user has gotten so far
     
     - parameters:
        - level The current level that the user is playing
     
     */
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
                        } else if element.level == GameLevels.level2 {
                            if self.collectedElements[.LEVEL2] == nil {
                                self.collectedElements[.LEVEL2] = [String]()
                            }
                            self.collectedElements[.LEVEL2]?.append(node)
                        }
                    }
                }
            }
        }
    }
    
    /**
     
     Adds the current element to the elements that the user has collected
     
     - parameters:
        - node The node that has been collected. ie: antigrav-mineral1
     
     */
    func addToCollectedElements (node:SKNode) {
        if let level = self.currentLevel {
            if self.collectedElements[level] == nil {
                self.collectedElements[level] = [String]()
            }
            
            if let name = node.name {
                self.collectedElements[level]?.append(name)
                ProgressTracker.updateElementsCollected(level: self.currentLevel!.rawValue, node: name)
            }
        }
    }
    
    /**
     
     Checks to see if the player has fallen below the last time he was on the ground
     
     - returns: A boolean value indicating whether the player is falling
     
     */
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
    /**
     
     Checks to see if the player is on the ground
     
     - todo: Only return true if the player is standing on the ground
     - returns: Bool If the player is on the ground or not
     
     */
    private func isGrounded () -> Bool {
        if let bodies = self.player.physicsBody?.allContactedBodies(), let groundPhysicsBody = self.ground?.physicsBody {
            if bodies.contains(groundPhysicsBody) {
                return true
            }
        }
        
        return false
    }
    
    /**
     
     Adds an impulse to the character to cuase him to jump and shows him as jumping
     
     */
    private func jump() {
        self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: PhysicsHandler.kJumpImpulse))
        self.player.texture = SKTexture(imageNamed: "running_step2")
        self.player.state = .INAIR
    }
    
    func rotateJumpingPlayer (rotation: Double) {
        if self.player.previousRunningState == .RUNNINGRIGHT || self.player.previousRunningState == .STANDING {
            self.player.zRotation = self.player.zRotation + CGFloat(Double.pi / rotation)
        } else if self.player.previousRunningState == .RUNNINGLEFT {
            self.player.zRotation = self.player.zRotation - CGFloat(Double.pi / rotation)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
        if self.messageBox != nil {
            return
        }
        
        if let originalPos = self.originalTouchPosition {
            
            let position = self.scene?.convert(pos, to: self.camera!)
            let differenceInXPos = originalPos.x - position!.x
            self.player.changeDirection(differenceInXPos: differenceInXPos)
            
            if self.player.runningState == .STANDING {
                self.sounds?.stopSoundWithKey(key: Sounds.RUN.rawValue)
            }
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        self.player.runningState = .STANDING
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
        if self.player.state != .INAIR {
            if self.player.runningState == .RUNNINGLEFT {
                self.player.physicsBody?.velocity = CGVector(dx: -PhysicsHandler.kRunVelocity, dy: self.player.physicsBody?.velocity.dy ?? 0)
            } else if self.player.runningState == .RUNNINGRIGHT {
                self.player.physicsBody?.velocity = CGVector(dx: PhysicsHandler.kRunVelocity, dy: self.player.physicsBody?.velocity.dy ?? 0)
            }
        } else if self.player.state == .INAIR {
            if self.player.runningState == .RUNNINGLEFT {
                if let dx = self.player.physicsBody?.velocity.dx {
                    if dx > -PhysicsHandler.kRunVelocity {
                        self.player.physicsBody?.applyImpulse(CGVector(dx: -PhysicsHandler.kRunInAirImpulse, dy: 0))
                    }
                }
            } else if self.player.runningState == .RUNNINGRIGHT {
                if let dx = self.player.physicsBody?.velocity.dx {
                    if dx < PhysicsHandler.kRunVelocity {
                        self.player.physicsBody?.applyImpulse(CGVector(dx: PhysicsHandler.kRunInAirImpulse, dy: 0))
                    }
                }
            }
        }
    }
    
    func showRunning (currentTime: TimeInterval) {
        // Show the first running image
        if currentTime - self.runTime == 0 {
            if self.player.state != .INAIR {
                self.player.texture = SKTexture(imageNamed: "standing")                
            }
        } else if currentTime - self.runTime > 0.1 {
            if self.player.state != .INAIR {
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
    
    func handlePlayerDied () {
        if let point = self.lastPointOnGround {
            self.player.position = point
        }
        
        self.player.zRotation = 0.0
        self.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.player.runningState = .STANDING
        self.player.state = .ONGROUND
    }
    
    func handleImpulse () {
        if let index = self.forces.index(of: .IMPULSE) {
            self.forces.remove(at: index)
            
            if let _ = self.impulses.last {
                self.impulses.removeLast()
            }
            if self.impulseObjects.count == 0 {
                if self.player.physicsBody!.velocity.dx > 0.0 {
                    self.player.physicsBody?.applyImpulse(CGVector(dx: 600, dy: 250))
                } else {
                    self.player.physicsBody?.applyImpulse(CGVector(dx: -600, dy: 250))
                }
            } else {
                for object in self.impulseObjects {
                    if object.physicsBody!.velocity.dx > 0.0 {
                        object.physicsBody?.applyImpulse(CGVector(dx: 600 * (object.physicsBody?.mass ?? 1), dy: 250))
                    } else {
                        object.physicsBody?.applyImpulse(CGVector(dx: -600 * (object.physicsBody?.mass ?? 1), dy: 250))
                    }
                }
                
                self.impulseObjects.removeAll()
            }
            
            self.player.state = .INAIR
        }
    }
    
    /**
     
     Adds the Impulse force to our forces object
     
     */
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
        mineralNode.physicsBody?.contactTestBitMask = 1 | UInt32(PhysicsCategory.InteractableObjects)
        mineralNode.physicsBody?.categoryBitMask = 0b0001
        mineralNode.physicsBody?.collisionBitMask = 0 | UInt32(PhysicsCategory.InteractableObjects)
        mineralNode.physicsBody?.allowsRotation = false
        addChild(mineralNode)
        
        if self.player.previousRunningState == .RUNNINGRIGHT {
            mineralNode.position.x = self.player.position.x + mineralNode.size.width
            mineralNode.physicsBody?.applyImpulse(CGVector(dx: 10, dy: -30))
        } else {
            mineralNode.position.x = self.player.position.x - mineralNode.size.width
            mineralNode.physicsBody?.applyImpulse(CGVector(dx: -10, dy: -30))
        }
        
    }
    
    func handleThrow () {
        if self.player.action == .THROW {
            if self.throwingMineral == .ANTIGRAV && self.player.hasAntigrav {
                let mineralNode = SKSpriteNode(imageNamed: "Blue Crystal")
                mineralNode.name = "mineral-gravity"
                self.showThrowMineral(mineralNode: mineralNode)
            } else if self.throwingMineral == .IMPULSE {
                let mineralNode = SKSpriteNode(imageNamed: "Red Crystal")
                mineralNode.name = "mineral-impulse"
                self.showThrowMineral(mineralNode: mineralNode)
            } else if self.throwingMineral == .TELEPORT {
                let mineralNode = SKSpriteNode(imageNamed: "Blue Crystal")
                mineralNode.name = "mineral-teleport"
                self.showThrowMineral(mineralNode: mineralNode)
            }
        }
        
        self.player.action = .NONE
    }
    
    func handlePlayerRotation (dt: TimeInterval) {
        if self.player.state == .INAIR {
            //self.rotateJumpingPlayer(rotation: -Double(dt * 500))
        } else {
//            self.player.zRotation = 0.0
        }
    }
    
    func handleJump () {
        if self.player.state == .JUMP {
            self.sounds?.stopSoundWithKey(key: Sounds.RUN.rawValue)
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
        
        if self.player.state == .DEAD {
            self.handlePlayerDied()
        } else {
            if self.player.state != .GRABBING { // User can only move left to right when grabbing something
                if self.player.runningState != .STANDING {
                    self.showRunning(currentTime: currentTime)
                    self.run()
                    
                    if self.player.state != .INAIR {
                        self.playSound(sound: .RUN)
                    }
                } else {
                    if self.player.state != .INAIR {
                        self.player.texture = SKTexture(imageNamed: "standing")
                        self.stopPlayer()
                    }
                }
                
                self.handleJump()
                self.handleThrow()
            }
            
            if self.player.state == .GRABBING {
                self.moveGrabbedObject()
                
                if self.player.runningState != .STANDING {
                    self.showRunning(currentTime: currentTime)
                }
            }
        }
        
        self.resetObjectsToOriginalPosition()
        self.physicsHandler.flipGravArea?.applyFlipGravityToContactedBodies(forceOfGravity: self.physicsWorld.gravity.dy, camera: self.camera)
    }
    
    func stopPlayer () {
        self.player.physicsBody?.velocity = CGVector(dx: 0, dy: self.player.physicsBody?.velocity.dy ?? 0)
    }
    
    func resetObjectsToOriginalPosition () {
        for object in self.objectsToReset {
            if let grabbedObject = self.player.grabbedObject {
                if grabbedObject == object {
                    self.stopGrabbing()
                }
            }
            
            if let object = object as? Rock {
                object.position = object.startingPos
                object.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            }
        }
        
        self.objectsToReset = [SKSpriteNode]()
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
    
    func showSpeech (message: String, relativeToNode: SKSpriteNode) {
        
        if self.messageBox == nil {
            let node = SKSpriteNode(imageNamed: "speechBubble")
            let text = SKLabelNode(text: message)
            
            text.fontColor = .black
            text.fontSize = 36.0
            text.fontName = "HelveticaNeue-Medium"
            text.position.y = text.position.y - 15
            if #available(iOS 11.0, *) {
                text.numberOfLines = 0
            } else {
                // Fallback on earlier versions
            }
            node.addChild(text)
            node.zPosition = 15
            text.zPosition = 5
            node.position = relativeToNode.position
            node.position.y = node.position.y + 160
            node.position.x = node.position.x + 45
            self.addChild(node)
            
            self.messageBox = node
        }
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
    
    // Take the user to the next level of the game
    func gotoNextLevel (sceneName: String) {
        
        let loading = Loading(fileNamed: "Loading")
        loading?.nextSceneName = sceneName
        loading?.player = self.player
        self.player.removeFromParent()
        let transition = SKTransition.moveIn(with: .right, duration: 0)
        loading?.scaleMode = SKSceneScaleMode.aspectFit
        self.view?.presentScene(loading!, transition: transition)
    }
    
    func playBackgroundMusic (fileName: String) {        
        if self.volumeIsMuted == false {
            if let musicURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
                self.backgroundMusic = SKAudioNode(url: musicURL)
                addChild(self.backgroundMusic)
            }
            
            if let musicURL = Bundle.main.url(forResource: "birdschirping", withExtension: "wav") {
                self.ambiance = SKAudioNode(url: musicURL)
                self.ambiance.run(SKAction.changeVolume(by: -0.7, duration: 0))
                addChild(self.ambiance)
            }
        }
    }
    
    func setupPlayer () {
        if self.player == nil {
            self.createPlayer()
        }
        
        self.player.xScale = 1
        self.player.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let start = self.childNode(withName: "start") {
            self.player.position = start.position
        }
    }
    
    func getCannons () {
        if let cannonsGroup = self.childNode(withName: "cannons") {
            if let cannons  = cannonsGroup.children as? [Cannon] {
                self.cannons = cannons
                for i in 0...(cannons.count - 1) {
                    self.cannons![i].timeToFire = self.cannonTimes[i]
                }
            }
        }
    }
    
    func moveCamera () {
        if let _ = self.childNode(withName: "cameraMinX") {
            self.camera?.position.x = self.player.position.x
            self.camera?.position.y = self.player.position.y
        }
        
        if let leftBoundary = self.camera?.childNode(withName: "leftBoundary"), let rightBoundary = self.camera?.childNode(withName: "rightBoundary"), let camera = self.camera {
            leftBoundary.position.y = camera.position.y
            rightBoundary.position.y = camera.position.y
        }
    }
    
    func getMineralCounts () {
        if let mineralCounts = ProgressTracker.getMineralCounts() {
            for mineralCount in mineralCounts {
                if mineralCount.mineral == Minerals.ANTIGRAV.rawValue {
                    self.player.mineralCounts[.ANTIGRAV] = mineralCount.count
                } else if mineralCount.mineral == Minerals.IMPULSE.rawValue {
                    self.player.mineralCounts[.IMPULSE] = mineralCount.count
                } else if mineralCount.mineral == Minerals.TELEPORT.rawValue {
                    self.player.mineralCounts[.TELEPORT] = mineralCount.count
                }
            }
        }
    }
    
    /*
     
     Load a saved game, continue the story
     
     */
    func loadSavedGame (sceneName: String, level:String) {
        self.getMineralCounts()
        self.getCollectedElements(level: level)
    }
    
    /**
     
     Traverses through the node hierarchy until it finds the world object and returns it
     
     - Parameters:
     - node: The node to get find the parent world of
     
     */
    @discardableResult class func getMainWorldFromNode (node: SKNode) -> World? {
        
        if let parentNode = node.parent {
            if let world = parentNode as? World {
                return world
            } else {
                self.getMainWorldFromNode(node: parentNode)
            }
        }
        
        return nil
    }
}
