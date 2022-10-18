//
//  DawudVillageLevel.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 8/29/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import GameKit
import SpriteKit

class DawudVillageLevel: Level {
    
    var storyNodes:[StoryElement] = []
    
    var visualAnimator:AnimationHandler?

    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        self.currentLevel = .DawudVillage
        super.didMove(to: view)
        self.playBackgroundMusic(fileName: Music.DawudsVillagePeaceful.rawValue)        
        self.addCameraMinXNode()
        
        
        self.visualAnimator = AnimationHandler(animations: [
//            DawudsVillageAttackedAnimationHandler(scene: self, player: self.player),
            LevelAnimationHandler(fileName: "DawudVillageAnimations", player: self.player, scene: self)
        ])
                
        self.addRopeBridge()                                
        
        GameElementsInitializer.setupGameElementsFromPlist(plistFileName: "DawudVillageElements", scene: self.scene)
        
        let enemy = FlipGravSoldier(imageNamed: "standing")
        self.addChild(enemy)
        enemy.setup()
        enemy.position = CGPoint(x: 23553, y: 2973)
        
        enemy.name = "Soldier"
        
                
    }
    
    private func addRopeBridge () {
        let ropeBridge = RopeBridge(position: CGPoint(x: 29900, y: 6122))
        self.scene?.addChild(ropeBridge)
        ropeBridge.setup(scene: self.scene!)
        guard
            let bridge = ropeBridge.bridge,
            let scene = self.scene
        else { return }
        
        let bridgePosition = ropeBridge.convert(bridge.position, to: scene)
        let vineAttachedToBridge = VineNode(length: 7, anchorPoint: bridgePosition.offset(CGPoint(x: 0, y: 10)), name: "vineAttachedToRopeBridge", segmentLength: 40)
        vineAttachedToBridge.addToScene(self.scene, anchor: ropeBridge.bridge)
    }
    
    private func getStory () {
        
        guard let path = Bundle.main.path(forResource: StoryFiles.DawudVillage, ofType: "plist") else { return }

        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        guard let storyData = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [StoryElement] else { return }
        self.storyNodes = storyData
    }
    
    public func addCameraMinXNode () {
        let cameraMinX = SKNode()
        cameraMinX.name = GameNodes.CameraMinX
        cameraMinX.position = CGPoint(x: 0, y: 0)
        self.addChild(cameraMinX)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (self.visualAnimator?.playerPaused == true) {
            self.player.stop()
            return
        }
        
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.visualAnimator?.playerPaused == true) {
            self.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            return
        }
        
        super.touchesMoved(touches, with: event)
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        self.handleSpeech()
        self.storyNodes.forEach { [weak self] (storyNode) in
            guard let self = self else { return }
            
        }
        if self.visualAnimator?.playerPaused == true {
            self.player.stop()
        }
        self.visualAnimator?.checkForAnimations(playerXPos: self.player.position.x, playerYPos: self.player.position.y)
    }
    
    private func handleSpeech () {
        
        struct speechPositions {
            let firstMorningSpeech = 1840
        }
        
        switch self.player.position.x {
        
        case let x where x > 1700 && x < 2500:
            if let node = self.scene?.nodes(at: CGPoint(x: 1830, y: -180)).first as? SKSpriteNode {
                self.showSpeech(message: "Morning Dawud", relativeToNode: node)
            }
        case let x where x > 2500 && x < 3000:
            self.removeMessageBoxFromScreen()
        default:
            return
        }
        
        if (self.player.position.x > 1700) {
                        
        }
    }
    
    public func addClimbButton () {
        
    }
    
}
