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

    override func didMove(to view: SKView) {
        self.currentLevel = .DawudVillage
        super.didMove(to: view)
        self.playBackgroundMusic(fileName: "level3")
        self.addJumpButtonToScreen()
        self.addCameraMinXNode()
        
        guard let vineNode = self.scene?.childNode(withName: "spring1") else { return }
        let spring = SpringNode(length: 1, anchorPoint: vineNode.position, name: "SpringNode")
        spring.addToScene(self.scene)                
    }
    
    public func addCameraMinXNode () {
        let cameraMinX = SKNode()
        cameraMinX.name = GameNodes.CameraMinX
        cameraMinX.position = CGPoint(x: 0, y: 0)
        self.addChild(cameraMinX)
    }
    
    public func addJumpButtonToScreen () {
        let jumpButton = SKSpriteNode(imageNamed: Textures.GameElements.JumpButton)
        jumpButton.zPosition = 100
        jumpButton.position.x = 761.722
        jumpButton.position.y = -362.28
        jumpButton.size.height = 250
        jumpButton.size.width = 250        
        self.camera?.addChild(jumpButton)
        self.jumpButton = jumpButton
    }
    
    public func addClimbButton () {
        
    }
    
}
