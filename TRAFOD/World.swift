//
//  World.swift
//  TRAFOD
//
//  Created by adeiji on 6/15/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import GameKit
import SpriteKit

extension SKSpriteNode {
    
    open override var physicsBody: SKPhysicsBody? {
        didSet {
            self.physicsBody?.fieldBitMask = UInt32(Int32(PhysicsCategory.Nothing))
        }
    }
}

protocol BaseWorldObject {
    
    var allowExternalForces:Bool { get set }
    
}

class World: SKScene, SKPhysicsContactDelegate {
    
    var previousWorldCameraPosition:CGPoint!
    var previousWorldPlayerPosition:CGPoint!
    
    // Cannons
    /// All the cannon objects in the world
    var cannons:[Cannon]?
    var cannonTimes:[TimeInterval] = [ 3.0, 8.0, 3.0, 5.0, 7.0 ]
    
    /**
     The most important object in the game.  This is the Dawud player within everywhere world and level
     */
    var player:Player! {
        didSet {
            self.addChild(self.player)
        }
    }
    
    /**
     When the player leaves the ground, this point is stored containing the point of his last contact with the ground
     - Bug: Right now there is an issue with sometimes the last point is on the side of a mountain or the edge of a cliff.  This needs to be fixed
     */
    var lastPointOnGround:CGPoint?
    
    var entities = [GKEntity]()
    
    /// These nodes are the nodes that handle the displaying of the number of minerals that the user currently has.  Look at the World+StaticScreenNodes to see the implementation
    var counterNodes = [String:SKNode]()
    
    /**
     
     When messages are displayed to the player, a message box is used
     
     - Todo: Stop using the message box and start to use another means of displaying messages to the user
     */
    var messageBox:SKSpriteNode!
    
    var jumpButton:SKNode?
    var throwButton:SKNode?
    
    /// All the buttons that are used to throw a mineral.  These buttons are generated at runtime programatically.
    var throwButtons:[String:SKNode] = [String:SKNode]()
    
    ///The button uused to grab grabble objects
    var grabButton:SKNode?
    
    /// The forces that are currently being applied within the world
    var forces:[Minerals] = [Minerals]()
    /// The impulses that are currently being applied within the world.  There can only be a maximum of three at one time
    var impulses:[Minerals] = [Minerals]()
    /// THe amount of time left that antiGrav will be applied to the world
    var gravityTimeLeft:Int = 0
    let antiGravViewKey = "antiGravView"
    
    // The original position where the user touched the screen
    private var originalTouchPosition:CGPoint?    
    var throwingMineral:Minerals!
    var lastGroundObjectPlayerStoodOn:SKShapeNode?
    
    /// This property is used to get the length of time the player has been running for, and we use this to show the proper running image
    private var runTime:TimeInterval = TimeInterval()
    private var stepCounter = 0
    
    var backgroundMusic:SKAudioNode!
    var ambiance:SKAudioNode!
    
    private let abyssKey = "abyss"
    
    var rain:SKEmitterNode!
    var lastUpdateTime : TimeInterval = 0
    var gravityTimeLeftLabel:SKLabelNode!
    
    var rewindPoints = [CGPoint]()
    var rewindPointCounter = 0
    
    var collectedElements:[Levels:[String]] = [Levels:[String]]()
    var sounds:SoundManager?
    var currentLevel:Levels?
    
    var impulseObjects:[SKNode] = [SKNode]()
    
    /**
     - Todo: Make sure that this is not a Rock object but instead use a protocol for all objects that can be reset when hitting another object
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
        case LEVEL5 = "Level5"
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
        self.getMineralCounts()
        self.setupCounterNodes()
        self.sounds = SoundManager(world: self)
        self.setupAllObjectNodes(nodes: self.children)
        self.setupButtonsOnScreen()
        self.getCannons()
        self.removeCollectedElements()
        self.showParticles()
        self.changeMineralPhysicsBodies()
        
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        view.showsFields = true
    }
    
    
    /**
     Handle all the initial setup of the nodes within the world
     
     - Note: Make sure that for every new object you create, if necessary, you add it's initial necessary setup here.  If the node adheres to the ObjectWithManuallyGeneratedPhysicsBody protocol, than any setup for the physics body should be handled within it's setupPhysicsBody method.  However, if there's any other kind of setup needed, do it here
     
     - Todo: Make sure that all objects in the game adhere to a custom object and we move away from the use of string names to determine node type
     */
    func setupAllObjectNodes (nodes: [SKNode]) {
        for node in nodes {
            if let node = node as? ObjectWithManuallyGeneratedPhysicsBody {
                node.setupPhysicsBody()
            }
            
            switch node {
            case is Cannon:
                let cannon = node as! Cannon
                if self.cannons == nil {
                    self.cannons = [Cannon]()
                }
                self.cannons?.append(cannon)
            case is Rock:
                break;
            case is FlipSwitch:
                let flipSwitch = node as! FlipSwitch
                flipSwitch.setMovablePlatformWithTimeInterval(timeInterval: 3.0)
            case is WeightSwitch:
                let weightSwitch = node as! WeightSwitch
                weightSwitch.setup()
                self.weightSwitches?.append(weightSwitch)
            default:
                break;
            }
            
            if node.children.count > 0 {
                self.setupAllObjectNodes(nodes: node.children)
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
                                node.physicsBody?.collisionBitMask = UInt32(PhysicsCategory.Nothing)
                                node.physicsBody?.categoryBitMask = UInt32(PhysicsCategory.Minerals)
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
        guard let nodeNameA = contact.bodyA.node?.name, let nodeNameB = contact.bodyB.node?.name else {
            return nil
        }
        
        if nodeNameA.contains(name) {
            return contact.bodyA.node
        } else if nodeNameB.contains(name) {
            return contact.bodyB.node
        }
        
        return nil
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
     This needs to be moved to the SoundManager
     */
    func playSound (sound: Sounds) {
        if let sounds = self.sounds {
            sounds.playSound(sound: sound)
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
            if self.player.state == .ONGROUND  || self.player.state == .SLIDINGONWALL {
                self.handleJump()
            }
            
            return
        } else {
            for type in Minerals.allCases {
                switch type {
                case .USED_TELEPORT:
                    break;
                case .ANTIGRAV:
                    if let throwButton = self.throwButtons["\(CounterNodes.AntiGrav)"], self.nodes(at: pos).contains(throwButton) {
                        AntiGravityMineral().throwMineral(player: self.player, world: self)
                        
                        return
                    }
                case .IMPULSE:
                    if let throwButton = self.throwButtons["\(CounterNodes.Impulse)"], self.nodes(at: pos).contains(throwButton) {
                        ImpulseMineral().throwMineral(player: self.player, world: self)
                        
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
                            TeleportMineral().throwMineral(player: self.player, world: self)
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

    func handlePlayerHitGround (contact: SKPhysicsContact) {
        if self.player.hasLanded(contact: contact) {
            if let physicsBody = self.player.physicsBody {
                self.player.physicsBody?.velocity = CGVector(dx: physicsBody.velocity.dx / 2.0, dy: 0)
            }
            self.lastPointOnGround = self.player.position
            if self.player.state != .GRABBING {
                self.player.state = .ONGROUND
            }
        } else if self.player.isSlidingOnWall(contact: contact) {
            self.player.slidOnWall()
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
        
        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: Impulse.self, nodeBType: SKSpriteNode.self) {
            Impulse.applyImpulseToNodeInContact(contact: contact)
            if let impulse = contact.bodyA.node as? Impulse != nil ? contact.bodyA.node : contact.bodyB.node {
                impulse.removeFromParent()
                if let index = self.impulses.firstIndex(of: .IMPULSE) {
                    self.impulses.remove(at: index)
                }
            }
        }
        
        if let mineral = PhysicsHandler.playerIsGrabbingMineral(contact: contact) {
            mineral.world = self
            mineral.getMineral(type: mineral.mineralType)
            self.addToCollectedElements(node: mineral)
            return
        }
        
        if let mineral = PhysicsHandler.playerUsedMineral(contact: contact) {
            if let useMineral = mineral as? UseMinerals {
                self.playSound(fileName: "mineralcrash")
                if let physicsAlteringArea = try? useMineral.mineralUsed(contactPosition: contact.contactPoint, world: self) {
                    self.physicsHandler.physicsAlteringAreas[mineral.type] = physicsAlteringArea
                    if let physicsAlteringArea = physicsAlteringArea {
                        self.addChild(physicsAlteringArea)
                    }
                }
                
                mineral.removeFromParent()
            }    
        }

        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: Player.self, nodeBType: GroundProtocol.self) {
            self.handlePlayerHitGround(contact: contact)
        }
        else if (contactAName == "dawud") || (contactBName == "dawud") {
            if contactAName.contains("ground") || contactBName.contains("ground")  {
                self.handlePlayerHitGround(contact: contact)
            }
        }
    
        if PhysicsHandler.contactContains(strings: ["dawud", "portal"], contactA: contactAName , contactB: contactBName) {
            if let node = getContactNode(name: "portal", contact: contact) {
                self.portalHit(portalNode: node as! SKSpriteNode)
                node.removeFromParent()
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
        
        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: Player.self, nodeBType: Rock.self) {
            if self.handleContactWithGrabbableObject(contact: contact) {
                self.showGrabButton()
            }
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
    func handlePlayerMovement () {
        guard let dx = self.player.physicsBody?.velocity.dx else { return }
        let multiplier:CGFloat = self.player.runningState == .RUNNINGLEFT ? 1 : -1
        
        switch self.player.state {
        case .ONGROUND:
            self.player.physicsBody?.velocity = CGVector(dx: -PhysicsHandler.kRunVelocity * multiplier, dy: self.player.physicsBody?.velocity.dy ?? 0)
        case .INAIR:
            if self.player.runningState == .RUNNINGLEFT {
                if dx > -PhysicsHandler.kRunVelocity {
                    self.player.physicsBody?.applyImpulse(CGVector(dx: -PhysicsHandler.kRunInAirImpulse * multiplier, dy: 0))
                }
            } else {
                if dx < PhysicsHandler.kRunVelocity {
                    self.player.physicsBody?.applyImpulse(CGVector(dx: -PhysicsHandler.kRunInAirImpulse * multiplier, dy: 0))
                }
            }
        case .SLIDINGONWALL:
            if self.player.runningState != .STANDING {
                self.player.physicsBody?.applyImpulse(CGVector(dx: -PhysicsHandler.kRunInAirImpulse * 2.0 * multiplier, dy: 0))
            }
        default:
            break;
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
                
                self.playSound(sound: .RUN)
            }
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
    func playMineralSound () {
        let getMineralSound = SKAction.playSoundFileNamed("mineralgrab", waitForCompletion: false)
        run(getMineralSound)
    }
    
    func playSound (fileName: String) {
        let sound = SKAction.playSoundFileNamed(fileName, waitForCompletion: false)
        self.run(sound)
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
        
        if self.player.state == .DEAD {
            self.handlePlayerDied()
        } else {
            if self.player.state == .SLIDINGONWALL {
                self.player.texture = SKTexture(imageNamed: "standing")
                self.handlePlayerMovement()
                
            } else if self.player.state != .GRABBING { // User can only move left to right when grabbing something
                if self.player.runningState != .STANDING {
                    self.showRunning(currentTime: currentTime)
                    self.handlePlayerMovement()
                } else {
                    if self.player.state != .INAIR {
                        self.player.texture = SKTexture(imageNamed: "standing")
                        self.stopPlayer()
                    }
                }
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
