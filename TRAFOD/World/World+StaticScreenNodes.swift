//
//  World+StaticScreenNodes.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/18/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

extension World {
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
            button.zPosition = 5
            button.size = CGSize(width: 250, height: 250)
            self.camera?.addChild(button)
            self.throwButtons["\(mineralType)"] = button
        }
    }
    
    func setupButtonsOnScreen () {
        self.jumpButton = self.camera?.childNode(withName: "jumpButton")
        self.throwButton = self.camera?.childNode(withName: "throwButton")
        self.throwImpulseButton = self.camera?.childNode(withName: "throwImpulseButton")
        self.throwTeleportButton = self.camera?.childNode(withName: "throwTeleportButton")
        self.grabButton = self.camera?.childNode(withName: "grabButton")
        
        self.grabButton?.isUserInteractionEnabled = false
        self.grabButton?.isHidden = true
        
        if self.throwButton != nil {
            self.throwButton.isHidden = true
        }
        
        self.jumpButton.isHidden = true
        
        if self.throwImpulseButton != nil {
            self.throwImpulseButton.isHidden = true
        }
        
        self.addJumpButton()
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
}
