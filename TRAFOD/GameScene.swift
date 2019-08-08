//
//  GameScene.swift
//  TRAFOD
//
//  Created by adeiji on 6/7/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import SpriteKit
import GameplayKit

extension UIColor {
    struct Style {
        static var ANTIGRAVMINERAL:UIColor  { return UIColor(red: 14.0/255.0, green: 210.0/255, blue: 241.0/255, alpha: 1) }
        static var IMPULSEMINERAL:UIColor { return UIColor(red: 241.0/255.0, green: 70.0/255.0, blue: 17.0/255.0, alpha: 1.0) }
    }
}

class Ice : Ground {
    override func setupPhysicsBody() {
        super.setupPhysicsBody()
        self.physicsBody?.friction = 0
    }
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
    }
    
    override func didMove(to view: SKView) {
        self.currentLevel = .LEVEL1
        self.physicsWorld.contactDelegate = self
        super.didMove(to: view)        
        
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
        ProgressTracker.updateProgress(currentLevel: GameLevels.Level1, player: self.player)
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        self.moveCameraWithPlayer()
        let dt = currentTime - self.lastUpdateTime
        self.handlePlayerRotation(dt: dt)
        self.lastUpdateTime = currentTime
    }
    
    override func moveCameraWithPlayer() {
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
}
