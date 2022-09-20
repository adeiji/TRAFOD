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

struct ActionButtons {
    var climbButton:SKNode?
}

class World: SKScene, SKPhysicsContactDelegate, MineralPurchasing {
    
    var previousWorldCameraPosition:CGPoint!
    var previousWorldPlayerPosition:CGPoint!
    
    lazy var buyMineralButtons: [Minerals : BuyButton]? = [Minerals: BuyButton]()
    var purchaseScreen: PurchaseMineralsViewController?
    
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
    /**
     
     When messages are displayed to the player, a message box is used
     
     - Todo: Stop using the message box and start to use another means of displaying messages to the user
     */
    var messageBox:SKSpriteNode?
    
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
    
    private var touchesMovedTimer:Timer?
    
    var backgroundMusic:SKAudioNode?
    var ambiance:SKAudioNode?
    
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
    
    weak var thrownMineral:Mineral?
    /// Contains all the special fields within this level
    var specialFields:[SpecialField] = [SpecialField]()
    var counterNodes: [String : SKNode] = [String: SKNode]()
    
    var leftHandView:UIView?
    var rightHandView:UIView?
    
    var worldGestures:WorldGestures?
    
    enum Levels:String {
        case DawudVillage = "DawudVillage"
        case LEVEL1 = "GameScene"
        case LEVEL2 = "Level2"
        case LEVEL3 = "Level3"
        case LEVEL4 = "Level4"
        case LEVEL5 = "Level5"
    }
    
    internal var actionButtons = ActionButtons()
    
    
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
        self.removeCollectedElements()
        self.showParticles()
        
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        view.showsFields = true

        self.worldGestures = WorldGestures(world: self, player: self.player)
    }
    
    
    /**
     Handle all the initial setup of the nodes within the world
     
     - Note: Make sure that for every new object you create, if necessary, you add it's initial necessary setup here.  If the node adheres to the ObjectWithManuallyGeneratedPhysicsBody protocol, than any setup for the physics body should be handled within it's setupPhysicsBody method.  However, if there's any other kind of setup needed, do it here
     
     - Todo: Make sure that all objects in the game adhere to a custom object and we move away from the use of string names to determine node type
     */
    func setupAllObjectNodes (nodes: [SKNode]) {
        var retrievalMineralNodeIndex = 0
        
        for node in nodes {
            retrievalMineralNodeIndex += 1
            
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
            case is RetrieveMineralNode:
                if let mineralNode = node as? RetrieveMineralNode {
                    guard let currentLevelName = self.currentLevel?.rawValue else { fatalError("The current level name must be set") }
                    mineralNode.setup(name: "\(currentLevelName)\(retrievalMineralNodeIndex)")
                }
            case is SpecialField:
                if let specialField = node as? SpecialField {
                    self.specialFields.append(specialField)
                }
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
        self.player.zPosition = ZPositions.Layer3
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
                if let _ = self.forces.firstIndex(of: .ANTIGRAV) {
                    self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
                    self.forces.remove(at: self.forces.firstIndex(of: .ANTIGRAV)!)
                    antiGravView?.isHidden = true
                    timeLabel.removeFromParent()
                }
            }
        }
        
        let sequence = SKAction.sequence([seconds, changeGravityBlock])
        run(sequence)
    }
    
    private func climbButtonPressed (atPoint pos: CGPoint) -> Bool {
        if let climbButton = self.actionButtons.climbButton, self.nodes(at: pos).contains(climbButton) {
            // If the climb button is not being shown currently, then disregard the press
            if climbButton.alpha == 0.0 {
                return false
            }
            
            if self.player.state != .CLIMBING {
                self.player.startClimbing()
            }
            
            return true
        }
        
        return false
    }
    
    /** If there's a message box currently being displayed on the screen then remove it */
    func removeMessageBoxFromScreen () {
        if let messageBox = self.messageBox {
            if messageBox.parent != nil {
                messageBox.removeFromParent()
                self.messageBox = nil
            }
        }
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
        
        self.removeMessageBoxFromScreen()
        
        self.handleGrabButtonActions(atPoint: pos)
        
        if self.climbButtonPressed(atPoint: pos) { return }
        
        if let buyButton = self.checkIfBuyMineralButtonWasPressedAndReturnButtonIfTrue(touchPoint: pos) {
            self.purchaseScreen = self.showPurchaseScreen(mineralType: buyButton.mineralType, world: self, completion: { (mineral, count) in
                guard let count = count else { return }
                guard let currentCount = self.player.mineralCounts[buyButton.mineralType] else { return }
                self.player.mineralCounts[buyButton.mineralType] = currentCount + count
                self.sounds?.playSound(sound: .GRABMINERAL)
                ProgressTracker.updateMineralCount(myMineral: buyButton.mineralType, count: count)
            } )
            return
        }
        
        if let jumpButton = self.jumpButton, self.nodes(at: pos).contains(jumpButton) {
                        
            // Grab onto the rope at whatever node it's touching
//            self.player.handleRopeGrabInteraction()
                        
            if self.player.state == .ONGROUND || self.player.state == .SLIDINGONWALL {
//                self.handleJump()
            } else if (self.player.isClimbing()) {
                self.player.stoppedClimbing()
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
                case .DESTROYER:
                    break;
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
        
        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: Player.self, nodeBType: RopeTypeSegment.self) {
//            self.player.setRopeContactPoint(nil)
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
            ProgressTracker.updateMineralCount(myMineral: type, count: mineralCount)
        } else {
            self.player.mineralCounts[type] = 10;
            ProgressTracker.updateMineralCount(myMineral: type, count: 10)
        }
        
        self.playMineralSound()        
    }
    
    func handlePlayerGotoNextLevel (contact: SKPhysicsContact) {
        guard let levelNode = contact.bodyA.node as? GotoLevelNode != nil ? contact.bodyA.node as? GotoLevelNode : contact.bodyB.node as? GotoLevelNode else {
            return
        }

        if let nextLevel = levelNode.nextLevel {
            self.loadAndGotoNextLevel(level: nextLevel)
        } else if let bookChapter = levelNode.nextBookChapter {
            let book = self.getChapterScene(bookChapter: bookChapter)
            self.showChapter(bookChapter: book)
        }
    }

    /** Player lands on the ground from the air. Take care of the changes to the character based off of this action */
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
            self.player.physicsBody?.friction = 0.0
            self.player.slidOnWall()
        }
    }
    
    func handleMineralUsed (mineral: Mineral?, contact: SKPhysicsContact) {
        // Get the object that made contact with the mineral. We do this because sometimes we want to make a change to the object that made contact with the mineral
        guard let objectHitByMineral = contact.bodyA.node is Mineral ? contact.bodyB.node : contact.bodyA.node  else { return }
        
        if let mineral = mineral {
            if let useMineral = mineral as? UseMinerals {
                self.playSound(fileName: SoundFiles.FX.MineralCrash)
                
                // Uses the mineral and than if it returns an object that can alter the physics of other objects, than we add this to the world
                if let physicsAlteringArea = useMineral.mineralUsed(contactPosition: contact.contactPoint, world: self, objectHitByMineral: objectHitByMineral) {
                    self.physicsHandler.physicsAlteringAreas[mineral.type] = physicsAlteringArea
                    self.addChild(physicsAlteringArea)
                }
                
                self.player.handleMineralUsed(mineralType: mineral.type)                 
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactAName = contact.bodyA.node?.name ?? ""
        let contactBName = contact.bodyB.node?.name ?? ""
        
        // Check to see if the player has just switched a weight switch, if so then handle the process after that
        PhysicsHandler.handlePlayerSwitchedWeightSwitch(contact: contact)
        // Check to see if the playe has hit the door to go to another level
        
        if Arrow.didHitPlayer(contact) {
            self.player.died()
            return
        }
        
        Arrow.hitGround(contact)
        
        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: GotoLevelNode.self, nodeBType: Player.self) {
            self.handlePlayerGotoNextLevel(contact: contact)
            return
        }
        // If the player hits fire than he dies
        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: Fire.self, nodeBType: Player.self) {
            self.player.died()
            return
        }
        
        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: Player.self, nodeBType: RopeTypeSegment.self) {
            self.player.setRopeContactPoint(contact.contactPoint)
        }
        
        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: Impulse.self, nodeBType: SKSpriteNode.self) {
            Impulse.applyImpulseToNodeInContact(contact: contact)
            if let impulse = contact.bodyA.node as? Impulse != nil ? contact.bodyA.node : contact.bodyB.node {
                impulse.removeFromParent()
                if let index = self.impulses.firstIndex(of: .IMPULSE) {
                    self.impulses.remove(at: index)
                }
            }
            
            return
        }
        
        if let mineral = PhysicsHandler.playerIsGrabbingMineral(contact: contact) {
            mineral.world = self
            mineral.getMineral(type: mineral.mineralType)
            self.addToCollectedElements(node: mineral)
            return
        }
        
        if let mineral = PhysicsHandler.playerUsedMineral(contact: contact) {
            self.handleMineralUsed(mineral: mineral, contact: contact)
            return
        }

        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: Player.self, nodeBType: GroundProtocol.self) ||
           PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: Player.self, nodeBType: Cannon.self)  {
            self.handlePlayerHitGround(contact: contact)            
        }
    
        if PhysicsHandler.contactContains(strings: [ PhysicsObjectTitles.Dawud, PhysicsObjectTitles.Portal], contactA: contactAName , contactB: contactBName) {
            if let node = getContactNode(name: PhysicsObjectTitles.Portal, contact: contact) {
                self.portalHit(portalNode: node as! SKSpriteNode)
                node.removeFromParent()
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: [PhysicsObjectTitles.Rock, self.abyssKey], contactA: contactAName, contactB: contactBName) {
            if let node = getContactNode(name: PhysicsObjectTitles.Rock, contact: contact) as? Rock {
                self.objectsToReset.append(node)
            }
            
            return
        }
        
        if PhysicsHandler.contactContains(strings: [PhysicsObjectTitles.Dawud, self.abyssKey], contactA: contactAName, contactB: contactBName) {
            self.player.died()
            return
        }
        
        if PhysicsHandler.contactContains(strings: [PhysicsObjectTitles.Rock, PhysicsObjectTitles.Ground], contact: contact) {
            if let node = getContactNode(name: PhysicsObjectTitles.Rock, contact: contact) {
                node.physicsBody?.velocity.dy = 0
            }
        }
        
        if PhysicsHandler.nodesAreOfType(contact: contact, nodeAType: Player.self, nodeBType: Rock.self) {
            if self.handleContactWithGrabbableObject(contact: contact) {
                self.showGrabButton()
            }
        }
        
        if PhysicsHandler.contactContains(strings: [PhysicsObjectTitles.CannonBall, PhysicsObjectTitles.Ground], contact: contact) {
            if PhysicsHandler.contactContains(strings: [PhysicsObjectTitles.Rock], contact: contact) == false {
                if let node = getContactNode(name: PhysicsObjectTitles.CannonBall, contact: contact) {
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
                        if element.level == GameLevels.Level1.rawValue {
                            if self.collectedElements[.LEVEL1] == nil {
                               self.collectedElements[.LEVEL1] = [String]()
                            }
                            self.collectedElements[.LEVEL1]?.append(node)
                        } else if element.level == GameLevels.Level2.rawValue {
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
                        
        guard let camera = self.camera else { return }
        
        let position = self.scene?.convertPoint(toView: pos)
        if self.rightHandView?.frame.contains(position!) == true {
            return
        }
                                        
        if let originalPos = self.originalTouchPosition {
            
            guard let position = self.scene?.convert(pos, to: camera) else { return }
            let differenceInXPos = originalPos.x - position.x
            
            if (abs(differenceInXPos) < 10) { return }
                                    
            if self.player.isClimbing() {
                let differenceInYPos = originalPos.y - position.y
                self.player.updatePlayerClimbingState(differenceInXPos: differenceInXPos, differenceInYPos: differenceInYPos)
                return
            }
            
            self.player.updatePlayerRunningState(differenceInXPos: differenceInXPos)
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
        
        guard let camera = self.camera else { return }
        guard let position = self.scene?.convert(pos, to: camera) else { return }
        
               
        self.player.runningState = .STANDING
                
        if self.player.isClimbing() {
            self.player.climbingState = .STILL
        } else {
            self.player.climbingState = nil
        }
        
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
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    /**
     Show the player as running according to what state in the run he should be in.  The image of the player running changes according to how long he's been running for in order to make his run look fluid
     
     - Parameter currentTime: The current time of the update cycle.  We need this value to make sure that the correct running image is shown according to how long the player has been running for
    */
    func showRunning (currentTime: TimeInterval) {
        // Show the first running image
        if currentTime - self.runTime == 0 {
            if self.player.state != .INAIR {
                self.player.texture = SKTexture(imageNamed: Textures.Dawud.Standing)
            }
        } else if currentTime - self.runTime > 0.1 {
            if self.player.state != .INAIR {
                // Alternate images
                self.runTime = currentTime
                self.stepCounter = self.stepCounter + 1
                self.player.texture = SKTexture(imageNamed: "\(SoundFiles.FX.RunningStep)\(self.stepCounter)")
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
        let getMineralSound = SKAction.playSoundFileNamed(SoundFiles.FX.MineralGrab, waitForCompletion: false)
        run(getMineralSound)
    }
    
    func playSound (fileName: String) {
        let sound = SKAction.playSoundFileNamed(fileName, waitForCompletion: false)
        self.run(sound)
    }
    
    func stopClimbingIfNecessary () {
        if self.player.isInContactWithFence() == false {
            self.player.stoppedClimbing()
        }
    }
    
    private func checkIfDawudInAir () {                
        if self.player.physicsBody?.allContactedBodies().filter({ $0.node is GroundProtocol }) .count == 0 {
            // If the player is in contact with a fence, then he's climbing and we don't need to set his state to in the air
            if Fence.playerInContact(player: self.player) {
                return
            }
            
            self.player.state = .INAIR
        } 
    }
    
    override func update(_ currentTime: TimeInterval) {
//        self.showMineralCount()
        self.stopClimbingIfNecessary()
        self.showClimbButton()
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        self.checkIfDawudInAir()
        
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
        
        self.player.handleIsContactedWithFlipGravity()
        
        self.specialFields.forEach { (field) in
            field.applyChange()
        }
        
        if self.player.dead {
            self.handlePlayerDied()
        } else {
            if self.player.state == .SLIDINGONWALL {
                self.player.texture = SKTexture(imageNamed: Textures.Dawud.Standing)
                self.player.handlePlayerMovement()
                
            } else if self.player.state != .GRABBING { // User can only move left to right when grabbing something
                if self.player.state == .CLIMBING {
                    self.player.handleClimbingMovement()
                    return
                }                
                else if self.player.runningState != .STANDING {
                    self.showRunning(currentTime: currentTime)
                    self.player.handlePlayerMovement()
                } else {
                    if self.player.state != .INAIR {
                        self.player.texture = SKTexture(imageNamed: Textures.Dawud.Standing)
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
    
    func stopShowingSpeech () {
        self.messageBox?.removeFromParent()
        self.messageBox = nil
    }
    
    /**
     - Todo: We need to create a speech handler for this
     */
    func showSpeech (message: String, relativeToNode: SKSpriteNode) {
        
        if self.messageBox == nil {
            let node = SKSpriteNode(imageNamed: GameNodes.SpeechBubble)
            node.size = CGSize(width: 450, height: 350)
            let text = SKLabelNode(text: message)
            
            text.fontColor = .black
            text.fontSize = 36.0
            text.fontName = "HelveticaNeue-Medium"
            text.position.y = text.position.y - 45
            text.preferredMaxLayoutWidth = 300
            if #available(iOS 11.0, *) {
                text.numberOfLines = 0
            } else {
                // Fallback on earlier versions
            }
            node.addChild(text)
            node.zPosition = 500
            text.zPosition = 400
            node.position = relativeToNode.position
            node.position.y = node.position.y + 260
            node.position.x = node.position.x - 75
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
                let backgroundMusic = SKAudioNode(url: musicURL)
                self.backgroundMusic = backgroundMusic
                self.camera?.addChild(backgroundMusic)
            }                    
        }
    }
    
    func playAmbiance () {
        if let musicURL = Bundle.main.url(forResource: SoundFiles.FX.BirdsChirping, withExtension: "wav") {
            let ambiance = SKAudioNode(url: musicURL)
            self.ambiance = ambiance
            self.ambiance?.run(SKAction.changeVolume(by: -0.7, duration: 0))
            self.camera?.addChild(ambiance)
        }
    }
    
    /**
     Moves the camera with the player.  If the player has gone too far left or too far right, than we stop moving the camera
     */
    func moveCameraWithPlayer () {
        if let _ = self.childNode(withName: GameNodes.CameraMinX) {
            self.camera?.position.x = self.player.position.x
            self.camera?.position.y = self.player.position.y + 200
        }
        
        if let leftBoundary = self.camera?.childNode(withName: GameNodes.LeftBoundary), let rightBoundary = self.camera?.childNode(withName: GameNodes.RightBoundary), let camera = self.camera {
            leftBoundary.position.y = camera.position.y
            rightBoundary.position.y = camera.position.y
        }
    }
    
    func moveCameraToFollowPlayerXPos () {
        self.camera?.position.x = self.player.position.x
    }
    
    func moveCameraToFollowPlayerYPos () {
        self.camera?.position.y = self.player.position.y
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
    func loadAndGotoNextLevel (level:GameLevels) {
        guard let loading = Loading(fileNamed: "Loading") else {
            fatalError("The loading scene file must exist")
        }
        
        self.getMineralCounts()
        loading.nextSceneName = level.rawValue
        self.getCollectedElements(level: level.rawValue)
        loading.collectedElements = self.collectedElements
        self.gotoNextLevel(fileName: level.rawValue, levelType: Loading.self, loadingScreen: loading)
    }
    
    func getChapterScene (bookChapter: BookChapters) -> Book? {
        guard let book = Book(fileNamed: "Book") else {
            fatalError("The Book scene file must exist")
        }
        for type in BookChapters.allCases {
            switch type {
            case .Chapter1:
                if bookChapter == .Chapter1 {
                    book.setChapter(chapter: bookChapter)
                    book.setup()
                    return book
                }
            }
        }
        
        return nil
    }
    
    func showChapter (bookChapter:Book?) {
        guard let bookChapter = bookChapter else { return }
        let transition = SKTransition.moveIn(with: .right, duration: 1)
        bookChapter.scaleMode = SKSceneScaleMode.aspectFit
        self.view?.presentScene(bookChapter, transition: transition)
    }
}
