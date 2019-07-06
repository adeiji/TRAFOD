//
//  GameScene.swift
//  TRAFOD
//
//  Created by adeiji on 6/7/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Minerals: String {
    case ANTIGRAV = "antigrav"
    case IMPULSE = "impulse"
    case TELEPORT = "teleport"
    case USED_TELEPORT = "teleport-mineral"
}

extension UIColor {
    struct Style {
        static var ANTIGRAVMINERAL:UIColor  { return UIColor(red: 14.0/255.0, green: 210.0/255, blue: 241.0/255, alpha: 1) }
        static var IMPULSEMINERAL:UIColor { return UIColor(red: 241.0/255.0, green: 70.0/255.0, blue: 17.0/255.0, alpha: 1.0) }
    }
}

class Ground : SKShapeNode {
    
    override init() {
        super.init()
        self.name = "GROUND"
        self.lineWidth = 5
        self.physicsBody = SKPhysicsBody(edgeChainFrom: self.path!)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.restitution  = 0
        self.physicsBody?.categoryBitMask = 1
        self.physicsBody?.contactTestBitMask = 1
        self.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Player : SKSpriteNode {
    
    public var hasAntigrav = false
    public var hasImpulse = false
    public var hasTeleport = false
    public var mineralCounts = [Minerals:Int]()
    public var strength:CGFloat = 10.0
    public var grabbedObject:SKNode?
    
}

class GameScene: Level {
    
    var graphs = [String : GKGraph]()
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var minCameraX:CGFloat = 882.971130371094
    
    enum Minerals {
        case ANTIGRAV
        case IMPULSE
    }
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        self.currentLevel = .LEVEL1
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.currentLevel = .LEVEL1
        self.showDoorParticles()
        self.physicsWorld.contactDelegate = self
        self.removeCollectedElements()        
        self.changeMineralPhysicsBodies()
        self.setupPlayer()
        if self.player.hasAntigrav {
            self.addThrowButton()
            self.showMineralCount()
        }
        
        if self.player.hasImpulse {
            self.addThrowImpulseButton()
            self.showMineralCount()
        }
        
        self.showFireFlies()
        self.showMineralParticles()
        self.showBackgroundParticles()
                        
        self.playBackgroundMusic()
        
        let antiGravNode = self.camera?.childNode(withName: self.antiGravViewKey)
        antiGravNode?.isHidden = true
        
        self.updateProgressLevel()
    }
    
    func playBackgroundMusic () {
        if let musicURL = Bundle.main.url(forResource: "Level1_Theme", withExtension: "mp3") {
            self.backgroundMusic = SKAudioNode(url: musicURL)
            addChild(self.backgroundMusic)
        }
        
        if let musicURL = Bundle.main.url(forResource: "birdschirping", withExtension: "wav") {
            self.ambiance = SKAudioNode(url: musicURL)
            self.ambiance.run(SKAction.changeVolume(by: -0.7, duration: 0))
            addChild(self.ambiance)
        }
    }
    
    func updateProgressLevel () {
        ProgressTracker.updateProgress(currentLevel: GameLevels.level1, player: self.player)
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        self.moveCamera()
        let dt = currentTime - self.lastUpdateTime
        self.handlePlayerRotation(dt: dt)
        self.lastUpdateTime = currentTime
    }
    
    override func moveCamera() {
        if ((self.player.position.x >= self.minCameraX)) && self.player.position.x < 31862 {
            self.camera?.position.x = self.player.position.x
        } else if self.player.position.x < self.minCameraX {
            self.camera?.position.x = self.minCameraX
        } else if self.player.position.x >= 31862 {
            self.camera?.position.x = 31862
        }
        
        if self.player.position.y > 400 {
            self.camera?.position.y = self.player.position.y
        } else {
            self.camera?.position.y = -159
        }
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        super.didBegin(contact)

        let contactAName = contact.bodyA.node?.name ?? ""
        let contactBName = contact.bodyB.node?.name ?? ""
        
        if contactContains(strings: ["dawud", "endOfGame"], contactA: contactAName, contactB: contactBName) {
            if let transferLevel = self.transitionToNextScreen(filename: "TransferLevel") as? TransferLevel {            
                transferLevel.collectedElements = self.collectedElements
                transferLevel.previousWorldPlayerPosition = self.player.position
                transferLevel.previousWorldCameraPosition = self.camera?.position
                return
            }
        }                
    }
}
