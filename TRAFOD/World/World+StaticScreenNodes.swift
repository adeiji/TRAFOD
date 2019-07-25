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
        for type in CounterNodes.allCases {
            switch type {
            case .AntiGrav:
                self.addCounterNodeToCounterNodes(counterNode: .AntiGrav, imageName: .BlueCrystal)
            case .Impulse:
                self.addCounterNodeToCounterNodes(counterNode: .Impulse, imageName: .RedCrystal)
            case .Teleport:
                self.addCounterNodeToCounterNodes(counterNode: .Teleport, imageName: .RedCrystal)
            case .FlipGravity:
                self.addCounterNodeToCounterNodes(counterNode: .FlipGravity, imageName: .BlueCrystal)
            case .Magnetic:
                self.addCounterNodeToCounterNodes(counterNode: .Magnetic, imageName: .BlueCrystal)
            case .CounterNode:
                break;
            case .Label:
                break;
            case .ThrowButtonNode:
                break;
            }
        }
    }
    
    func addCounterNodeToCounterNodes (counterNode: CounterNodes, imageName: ImageNames) {
        self.counterNodes["\(counterNode)\(CounterNodes.CounterNode)"] = SKSpriteNode(imageNamed: imageName.rawValue)
        self.counterNodes["\(counterNode)\(CounterNodes.ThrowButtonNode)"] = SKSpriteNode(imageNamed: imageName.rawValue)
        self.counterNodes["\(counterNode)\(CounterNodes.Label)"] = SKLabelNode(text: "0")
    }
    
    func showMineralCount () {
        for type in Minerals.allCases {
            if let count = self.player.mineralCounts[type] {
                switch type {
                case .ANTIGRAV:
                    self.setupThrowButton(crystalImageName: .BlueCrystal, mineralType: .AntiGrav, pos: ScreenButtonPositions.AntiGravThrowButton)
                    self.setupMineralCounterAndUseNodes(mineralType: .AntiGrav, counterMineralNodePos: ScreenButtonPositions.AntiGravCounterNode, count: count)
                case .IMPULSE:
                    self.setupThrowButton(crystalImageName: .RedCrystal, mineralType: .Impulse, pos: CGPoint(x: 613, y: -189))
                    self.setupMineralCounterAndUseNodes(mineralType: .Impulse, counterMineralNodePos: CGPoint(x: -470, y: 400), count: count)
                case .TELEPORT:
                    self.setupThrowButton(crystalImageName: .RedCrystal, mineralType: .Teleport, pos: CGPoint(x: 352, y: -115))
                    self.setupMineralCounterAndUseNodes(mineralType: .Teleport, counterMineralNodePos: CGPoint(x: -670, y: 400), count: count)
                case .USED_TELEPORT:
                    break
                case .FLIPGRAVITY:
                    self.setupThrowButton(crystalImageName: .RedCrystal, mineralType: .FlipGravity, pos: CGPoint(x: 160, y: -365))
                    self.setupMineralCounterAndUseNodes(mineralType: .FlipGravity, counterMineralNodePos: CGPoint(x: -270, y: 400), count: count)
                case .MAGNETIC:
                    self.setupThrowButton(crystalImageName: .RedCrystal, mineralType: .Magnetic, pos: CGPoint(x: -100, y: -365))
                    self.setupMineralCounterAndUseNodes(mineralType: .Magnetic, counterMineralNodePos: CGPoint(x: -70, y: 400), count: count)
                }
            }
        }
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
        self.throwButton?.isHidden = true
        self.throwImpulseButton?.isHidden = true
        
        
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
        self.jumpButton?.isHidden = false
    }
    
    func addThrowButton () {
        self.throwButton?.isHidden = false
    }
    
    func addThrowImpulseButton () {
        self.throwImpulseButton?.isHidden = false
    }
}
