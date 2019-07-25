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
    
    var player:Player! {
        didSet {
            self.addChild(self.player)
        }
    }
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
    
    var counterNodes = [String:SKNode]()
    
    var messageBox:SKSpriteNode!
    var jumpButton:SKNode?
    var throwButton:SKNode?
    var throwImpulseButton:SKNode?
    var throwTeleportButton:SKNode?
    
    var throwButtons:[String:SKNode] = [String:SKNode]()
    
    var grabButton:SKNode?
    
    var forces:[Minerals] = [Minerals]()
    var impulses:[Minerals] = [Minerals]()
    
    var gravityTimeLeft:Int = 0
    let antiGravViewKey = "antiGravView"
    
    private var originalTouchPosition:CGPoint?    
    var throwingMineral:Minerals!
    var ground:SKShapeNode?
    
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
        case LEVEL4 = "Level4"
    }
    
    
    /**
     Stores all of the weight switches in the current world
     */
    var weightSwitches:[WeightSwitch]? = [WeightSwitch]()
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
    }
    
    override func didMove(to view: SKView) {
        self.setupPlayer()
        self.setupCounterNodes()
        self.sounds = SoundManager(world: self)
        self.setupAllObjectNodes()
        self.setupButtonsOnScreen()
        self.getCannons()
        self.removeCollectedElements()
        self.showParticles()
        self.changeMineralPhysicsBodies()
        self.playBackgroundMusic(fileName: "Level2")
        
        view.showsFields = true
    }
    
    
    /**
     Handle all the initial setup of the nodes within the world
     
     - Note: Make sure that for every new object you create, if necessary, you add it's initial necessary setup here.  If the node adheres to the ObjectWithManuallyGeneratedPhysicsBody protocol, than any setup for the physics body should be handled within it's setupPhysicsBody method.  However, if there's any other kind of setup needed, do it here
     
     - Todo: Make sure that all objects in the game adhere to a custom object and we move away from the use of string names to determine node type
     */
    func setupAllObjectNodes () {
        self.children.forEach { (node) in
            if node.name == "ground" {
                node.physicsBody?.friction = 1.0
                return
            }
            
            if let node = node as? ObjectWithManuallyGeneratedPhysicsBody {
                node.setupPhysicsBody()
            }
            
            if let ground = node as? Ground {
                ground.setupPhysicsBody()
                ground.physicsBody?.mass = 1000000000000
                return
            }
            
            switch node {
            case is Cannon:
                let cannon = node as! Cannon
                if self.cannons == nil {
                    self.cannons = [Cannon]()
                }
                self.cannons?.append(cannon)
            case is Rock:
                let rock = node as! Rock
                rock.setupPhysicsBody()
            case is FlipSwitch:
                let flipSwitch = node as! FlipSwitch
                flipSwitch.setMovablePlatformWithTimeInterval(timeInterval: 3.0)
                flipSwitch.setupPhysicsBody()
            case is WeightSwitch:
                let weightSwitch = node as! WeightSwitch
                weightSwitch.setup()
                self.weightSwitches?.append(weightSwitch)
            default:
                return
            }
        }
    }
    
    /**
     Show all the particle effects on the screen.  Example, the particles that need to show when a mineral hits the ground.
    */
    func showParticles () {
        self.showDoorParticles()
        self.showResetParticles()
        self.showResetParticles(nodeName: "rocks")
        self.showNoWarpParticles()
        self.showDoubleGravParticles(color: .yellow)
        self.showBackgroundParticles()
        self.showFireFlies()
    }
    
    func getProgress () {
        if let progress = ProgressTracker.getProgress() {
            self.player.hasAntigrav = progress.hasAntigrav
            self.player.hasImpulse = progress.hasImpulse
        }
    }
    
    /**
     Create the player of the game and sets up it's physics body
     */
    func createPlayer () {
        self.player = Player(imageNamed: "standing")
        self.player.setupPhysicsBody()
        self.listener = self.player
    }
    
    func changeMineralPhysicsBodies () {
        for node in self.children {
            
            func addAllMinerals (mineralGroup: MineralGroup) {
                mineralGroup.children.forEach { (mineral) in
                     if let mineral = mineral as? RetrieveMineralNode {
                        mineral.setup()
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
    
    /**
     Gets a node that has just made contact with other node by it's name
     
     - Parameter name: The name of the node
     - Parameter contact: The physics contact object which contains the node that you want.
     
     - Note: This method is called from within the contact didBegin method
    */
    func getContactNode (name: String, contact: SKPhysicsContact) -> SKNode? {
        if (contact.bodyA.node?.name?.contains(name))! {
            return contact.bodyA.node
        } else if (contact.bodyB.node?.name?.contains(name))! {
            return contact.bodyB.node
        }
        
        return nil
    }
    
    /**
     - Todo: This needs to be moved to the object that handles impulse which has not been created yet
     */
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
            impulseNode.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Portals)
            
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
    
    /**
     - Todo: This needs to be moved to within the impulse object that has not been created yet
     */
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
    
    /**
     - Todo: This needs to be moved to the Mineral object
     */
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
        teleportNode.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Portals)
        
        self.teleportNode = teleportNode
        self.addChild(teleportNode)
    }
    
    /**
     This needs to be moved to the SoundManager
     */
    func playSound (sound: Sounds) {
        if let sounds = self.sounds {
            sounds.playSound(sound: sound)
        }
    }
    
    /**
     An object needs to be created to handle this
     */
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
        
        if let jumpButton = self.jumpButton, self.messageBox != nil && self.nodes(at: pos).contains(jumpButton) {
            self.messageBox.removeFromParent()
            self.messageBox = nil
        } else if self.messageBox != nil {
            return
        }
        
        self.handleGrabButtonActions(atPoint: pos)
        
        if let jumpButton = self.jumpButton, self.nodes(at: pos).contains(jumpButton) {
            if self.player.state == .ONGROUND {
                self.player.state = .JUMP
            }
            
            return
        } else {
            for type in Minerals.allCases {
                switch type {
                case .USED_TELEPORT:
                    break;
                case .ANTIGRAV:
                    if let throwButton = self.throwButtons["\(CounterNodes.AntiGrav)"], self.nodes(at: pos).contains(throwButton) {
                        self.player.action = .THROW
                        self.throwingMineral = .ANTIGRAV
                        return
                    }
                    
                case .IMPULSE:
                     if let throwImpulseButton =  self.throwButtons["\(CounterNodes.Impulse)"], self.nodes(at: pos).contains(throwImpulseButton) {
                        self.player.action = .THROW
                        self.throwingMineral = .IMPULSE
                        return
                    }
                case .TELEPORT:
                    if let throwButton = self.throwButtons["\(CounterNodes.Teleport)"], self.nodes(at: pos).contains(throwButton) {
                        // User presses the teleport button
                        // The way that the teleport button works is that they press it once and it activates a teleportation portal at the player's current position
                        // When they press the button again, the player is automatically transported back to that position of the teleportation portal
                        if let teleportNode = self.teleportNode {
                            // Bring the player back to where they actived the teleport node
                            self.player.position = teleportNode.position
                            self.teleportNode?.removeFromParent()
                            self.teleportNode = nil
                            self.player.flipPlayerUpright()
                        } else { // Throw a Teleportation mineral
                            self.player.action = .THROW
                            self.throwingMineral = .TELEPORT
                        }
                        return
                    }
                case .FLIPGRAVITY:
                    if let throwButton = self.throwButtons["\(CounterNodes.FlipGravity)"], self.nodes(at: pos).contains(throwButton) {
                        if let flipGravArea =  self.physicsHandler.physicsAlteringAreas[.FLIPGRAVITY] {
                            flipGravArea.removeFromParent()
                            self.physicsHandler.physicsAlteringAreas[.FLIPGRAVITY] = nil
                            self.player.flipPlayerUpright()
                        } else {
                            FlipGravityMineral().throwMineral(player: self.player, world: self)
                        }
                        return
                    }
                case .MAGNETIC:
                    if let throwButton = self.throwButtons["\(CounterNodes.Magnetic)"], self.nodes(at: pos).contains(throwButton) {
                        if let magneticArea = self.physicsHandler.physicsAlteringAreas[.MAGNETIC] {
                            magneticArea.removeFromParent()
                            self.physicsHandler.physicsAlteringAreas[.MAGNETIC] = nil
                        } else {
                            MagneticMineral().throwMineral(player: self.player, world: self)
                        }
                        
                        return
                    }
                }
            }
        }
        
        if let camera = self.camera {
            if let originalPos = self.scene?.convert(pos, to: camera) {
                self.originalTouchPosition = originalPos
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        self.handleGrabbedObjectContactEnded(contact: contact)
        
        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: FlipGravity.self, nodeBType: Player.self) {
            self.player.flipPlayerUpright()
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
    
    func handlePlayerGotoNextLevel (contact: SKPhysicsContact) {
        if PhysicsHandler.contactContains(strings: ["dawud", GameLevels.Level3.uppercased()], contact: contact) {
            self.loadAndGotoNextLevel(sceneName: GameLevels.Level3, level: GameLevels.Level3)
            return
        } else if PhysicsHandler.contactContains(strings: ["dawud", GameLevels.Level4.uppercased()], contact: contact) {
            self.loadAndGotoNextLevel(sceneName: GameLevels.Level4, level: GameLevels.Level4)
            return
        } else if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: GotoLevelNode.self, nodeBType: Player.self) {
            let levelNode = contact.bodyA.node as? GotoLevelNode != nil ? contact.bodyA.node as! GotoLevelNode : contact.bodyB.node as! GotoLevelNode
            self.loadAndGotoNextLevel(sceneName: levelNode.nextLevel, level: levelNode.nextLevel)
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let contactAName = contact.bodyA.node?.name ?? ""
        let contactBName = contact.bodyB.node?.name ?? ""
        
        // Check to see if the player has just switched a weight switch, if so then handle the process after that
        PhysicsHandler.handlePlayerSwitchedWeightSwitch(contact: contact)
        // Check to see if the playe has hit the door to go to another level
        self.handlePlayerGotoNextLevel(contact: contact)
        // If the player hits fire than he dies
        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: Fire.self, nodeBType: Player.self) {
            self.player.state = .DEAD
        }
        if let mineral = PhysicsHandler.playerIsGrabbingMineral(contact: contact) {
            mineral.world = self
            mineral.getMineral(type: mineral.mineralType)
            self.addToCollectedElements(node: mineral)
            return
        }
        
        if let mineral = PhysicsHandler.playerUsedMineral(contact: contact) {
            if let useMineral = mineral as? UseMinerals {
                let physicsAlteringArea = useMineral.mineralUsed(contactPosition: contact.contactPoint)
                self.physicsHandler.physicsAlteringAreas[mineral.type] = physicsAlteringArea
                self.addChild(physicsAlteringArea)
                mineral.removeFromParent()
            }    
        }

        if (contactAName == "dawud") || (contactBName == "dawud") {
            if contactAName.contains("ground") || contactBName.contains("ground") {
                
                if self.player.hasLanded(contact: contact) {
                    self.player.zRotation = 0.0
                    if let physicsBody = self.player.physicsBody {
                        self.player.physicsBody?.velocity = CGVector(dx: physicsBody.velocity.dx / 2.0, dy: 0)
                    }
                    
                    self.lastPointOnGround = self.player.position
                    if self.player.state != .GRABBING {
                        self.player.state = .ONGROUND
                    }
                    
                    var point = self.player.position
                    if let node = getContactNode(name: "ground", contact: contact) {
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
            if let node = getContactNode(name: "mineral", contact: contact) {
                node.removeFromParent()
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["ground", "mineral", "gravity"], contactA: contactAName , contactB: contactBName) {
            if !PhysicsHandler.contactContains(strings: ["noantigrav"], contactA: contactAName, contactB: contactBName) {
                self.antiGravUsed()
                self.showMineralCrash(withColor: UIColor.Style.ANTIGRAVMINERAL, contact: contact, duration: 2)
            }
            
            if let node = getContactNode(name: "mineral", contact: contact) {
                node.removeFromParent()
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["ground", "mineral", "impulse"], contactA: contactAName , contactB: contactBName) {
            if !PhysicsHandler.contactContains(strings: ["nowarp"], contactA: contactAName, contactB: contactBName) {
                self.impulseUsed(crashPosition: contact.contactPoint)
                self.showMineralCrash(withColor: UIColor.Style.IMPULSEMINERAL, contact: contact, duration: 2)
            }
            if let node = getContactNode(name: "mineral", contact: contact) {
                node.removeFromParent()
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["dawud", "portal"], contactA: contactAName , contactB: contactBName) {
            if let node = getContactNode(name: "portal", contact: contact) {
                self.portalHit(portalNode: node as! SKSpriteNode)
                node.removeFromParent()
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["cannonball", "portal"], contactA: contactAName, contactB: contactBName) {
            if let node = getContactNode(name: "portal", contact: contact) {
                self.portalHit(portalNode: node as! SKSpriteNode)
                node.removeFromParent()
            }
            
            if let node = getContactNode(name: "cannonball", contact: contact) {
                self.impulseObjects.append(node)
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["rock", "portal"], contactA: contactAName, contactB: contactBName) {
            if let node = getContactNode(name: "portal", contact: contact) {
                self.portalHit(portalNode: node as! SKSpriteNode)
                node.removeFromParent()
            }
            
            if let node = getContactNode(name: "rock", contact: contact) {
                self.impulseObjects.append(node)
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["rock", self.abyssKey], contactA: contactAName, contactB: contactBName) {
            if let node = getContactNode(name: "rock", contact: contact) as? Rock {
                self.objectsToReset.append(node)
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["dawud", self.abyssKey], contactA: contactAName, contactB: contactBName) {
            self.player.state = .DEAD
            return
        }
        
        if PhysicsHandler.contactContains(strings: ["rock", "ground"], contact: contact) {
            if let node = getContactNode(name: "rock", contact: contact) {
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
                if let node = getContactNode(name: "cannonball", contact: contact) {
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
     
     - Parameter level: The current level that the user is playing
     
     */
    func getCollectedElements (level: String) {
        if let elements = ProgressTracker.getElementsCollected() {
            for element in elements {
                if element.level == level {
                    for node in element.nodes {
                        if element.level == GameLevels.Level1 {
                            if self.collectedElements[.LEVEL1] == nil {
                               self.collectedElements[.LEVEL1] = [String]()
                            }
                            self.collectedElements[.LEVEL1]?.append(node)
                        } else if element.level == GameLevels.Level2 {
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
     
     - Parameter node: The node that has been collected. ie: antigrav-mineral1
     
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
     This is where we handle the movement of the player.  If the user touches the screen and then moves his finger, than this method is called
     
     - Parameter toPoint: The current position of where the user is touching the screen
     */
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
    
    /**
     When the user stops touching the screen
     
     - Parameter atPoint: The position of the user's finger when he stops touching the screen
     */
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
    
    /**
     This method is called when the player is running.  If the player is in the air, then we don't want the player to move as freely as when he's on the ground obviously.
     */
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
    
    /**
     Show the player as running according to what state in the run he should be in.  The image of the player running changes according to how long he's been running for in order to make his run look fluid
     
     - Parameter currentTime: The current time of the update cycle.  We need this value to make sure that the correct running image is shown according to how long the player has been running for
    */
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
    
    /**
     When the player hits an impulse portal, this method is called and all the necessary physics adjustments are made to the player to show that he has hit the impulse portal.
    */
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
     
     Adds the Impulse force to our forces object.  See forces array object above
     
     */
    func portalHit (portalNode: SKSpriteNode) {
        self.forces.append(.IMPULSE)
    }
    
    /**
     - Todo: This needs to be moved to its own object
     */
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
    
    /**
     - Todo: This needs to be moved to its own object
     */
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
    
    /**
     - Todo: This needs to be moved to its own object
     */
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
        
        for key in self.physicsHandler.physicsAlteringAreas.keys {
            if let physicsAlteringArea = self.physicsHandler.physicsAlteringAreas[key] {
                physicsAlteringArea.applyForceToPhysicsBodies(forceOfGravity:  self.physicsWorld.gravity.dy, camera: self.camera)
            }
        }
    }
    
    // This needs to be moved to it's own object
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
    
    /**
     - Todo: We need to create a speech handler for this
     */
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
    
    /**
     Remove all the minerals that the user has already retrieved
     
     - Todo: These need to all be custom node types and since they should be codable we need to remove them from their parent instead of doing things the way we're currently doing them
     */
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
    
    /**
     Play the background music for a level.  This also plays the birds chirping mp3 in the background
     
     - Parameters:
     - fileName: The name of the file to play for the level's background music
     
     */
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
    
    /**
     - TODO: Change the way that we do cannons within the levels and instead of naming them cannons assign their object to Cannons and then remove this method
     */
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
    
    /**
     Moves the camera with the player.  If the player has gone too far left or too far right, than we stop moving the camera
     */
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
    
    /**
     Gets the number of minerals that the player has gathered so far within the game.  Every time a new mineral is added to the game, you must make sure that you add it here.
     
     - TODO: It might be better if we develop a system to where when we add a new mineral to the game we don't have to add it here so that we don't run into random bugs
     */
    func getMineralCounts () {
        if let mineralCounts = ProgressTracker.getMineralCounts() {
            for mineralCount in mineralCounts {
                if mineralCount.mineral == Minerals.ANTIGRAV.rawValue {
                    self.player.mineralCounts[.ANTIGRAV] = mineralCount.count
                } else if mineralCount.mineral == Minerals.IMPULSE.rawValue {
                    self.player.mineralCounts[.IMPULSE] = mineralCount.count
                } else if mineralCount.mineral == Minerals.TELEPORT.rawValue {
                    self.player.mineralCounts[.TELEPORT] = mineralCount.count
                } else if mineralCount.mineral == Minerals.FLIPGRAVITY.rawValue {
                    self.player.mineralCounts[.FLIPGRAVITY] = mineralCount.count
                } else if mineralCount.mineral == Minerals.MAGNETIC.rawValue {
                    self.player.mineralCounts[.MAGNETIC] = mineralCount.count
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
    
    /**
     
     Load a saved game and then goto the next level
     
     - Parameters:
     
     - sceneName: The name of the scene to load
     - level: The name of the level to load
     
     - Note: Make sure that for the scene name and the level you use the constants in the GameLevel Object
     
     - Todo: We're going to need to change the parameter types for sceneName and level to type GameLevel
     
     */
    func loadAndGotoNextLevel (sceneName: String, level:String) {
        guard let loading = Loading(fileNamed: "Loading") else {
            fatalError("The loading screen must exist")
        }
        
        self.getMineralCounts()
        loading.nextSceneName = sceneName
        self.getCollectedElements(level: level)
        loading.collectedElements = self.collectedElements
        self.gotoNextLevel(fileName: sceneName, levelType: Loading.self, loadingScreen: loading)
    }
}
