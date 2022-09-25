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
    
    func getCounterNode (counterNode: CounterNodes, buttonType: CounterNodes) -> SKNode? {
        return self.counterNodes["\(counterNode)\(buttonType)"]
    }
    
    /** Show the button on the main screen allowing a player to purchase minerals. */
    func showBuyMineralButton(mineralType: Minerals) {
        let purchaseButton = self.getPurchaseButton(mineralType: mineralType)
        self.throwButtons["\(mineralType.rawValue)"]?.alpha = 0.5
        
        if self.buyMineralButtons?[mineralType] == nil {
            self.camera?.addChild(purchaseButton)
            self.buyMineralButtons?[mineralType] = purchaseButton
        }
    }
    
    /**
     Checks to see if the user has just pressed the buy minerals button
     */
    func checkIfBuyMineralButtonWasPressedAndReturnButtonIfTrue (touchPoint: CGPoint) -> BuyButton? {
        guard let buyButtons = self.buyMineralButtons else { return nil }
        
        for key in buyButtons.keys {
            if let buyButton = buyButtons[key] {
                if self.nodes(at: touchPoint).contains(buyButton) {
                    return buyButton
                }
            }
        }
        
        return nil
    }
    
    func removeBuyButton(mineralType: Minerals) {
        if let buyButton = self.buyMineralButtons?[mineralType] {
            buyButton.removeFromParent()
            self.buyMineralButtons?[mineralType] = nil
        }
    }
    
    func showMineralCount () {
        for type in Minerals.allCases {
            if let numberOfMineralsLeft = self.player.mineralCounts[type] {
                
                if (numberOfMineralsLeft <= 0) {
                    self.showBuyMineralButton(mineralType: type)
                } else {
                    self.removeBuyButton(mineralType: type)
                }
                
                switch type {
                case .ANTIGRAV:
                    self.setupThrowButton(crystalImageName: .BlueCrystal, mineralType: .AntiGrav, pos: ScreenButtonPositions.AntiGravThrowButton)
                    self.setupMineralCounterAndUseNodes(mineralType: .AntiGrav, counterMineralNodePos: ScreenButtonPositions.AntiGravCounterNode, count: numberOfMineralsLeft)
                case .IMPULSE:
                    self.setupThrowButton(crystalImageName: .RedCrystal, mineralType: .Impulse, pos: CGPoint(x: 613, y: -139))
                    self.setupMineralCounterAndUseNodes(mineralType: .Impulse, counterMineralNodePos: ScreenButtonPositions.Impulse.CounterNode, count: numberOfMineralsLeft)
                case .TELEPORT:
                    self.setupThrowButton(crystalImageName: .RedCrystal, mineralType: .Teleport, pos: CGPoint(x: 332, y: -115))
                    self.setupMineralCounterAndUseNodes(mineralType: .Teleport, counterMineralNodePos: CGPoint(x: -670, y: 400), count: numberOfMineralsLeft)
                case .USED_TELEPORT:
                    break
                case .FLIPGRAVITY:
                    self.setupThrowButton(crystalImageName: .RedCrystal, mineralType: .FlipGravity, pos: CGPoint(x: 160, y: -365))
                    self.setupMineralCounterAndUseNodes(mineralType: .FlipGravity, counterMineralNodePos: CGPoint(x: -270, y: 400), count: numberOfMineralsLeft)
                case .MAGNETIC:
                    self.setupThrowButton(crystalImageName: .RedCrystal, mineralType: .Magnetic, pos: CGPoint(x: -120, y: -365))
                    self.setupMineralCounterAndUseNodes(mineralType: .Magnetic, counterMineralNodePos: CGPoint(x: -70, y: 400), count: numberOfMineralsLeft)
                case .DESTROYER:
                    break
                }
            }
        }
    }
            
    func setupThrowButton (crystalImageName: ImageNames, mineralType: CounterNodes, pos: CGPoint) {
        if self.throwButtons["\(mineralType)"] == nil
        {
            let throwButton = UIButton()
            throwButton.setImage(UIImage(named: crystalImageName.rawValue), for: .normal)
            throwButton.layer.cornerRadius = 50
            
            guard let rightHandView = self.rightHandView else { return }
            throwButton.frame = CGRect(x: rightHandView.frame.width - 120, y: rightHandView.frame.height / 2.0, width: 100, height: 100)
            throwButton.layer.borderWidth = 5
            throwButton.layer.borderColor = UIColor.white.cgColor
            self.rightHandView?.addSubview(throwButton)
            throwButton.showsTouchWhenHighlighted = true
            
            throwButton.addTargetClosure { button in
                switch mineralType {
                case .AntiGrav:
                    AntiGravityMineral().throwMineral(player: self.player, world: self)
                default:
                    AntiGravityMineral().throwMineral(player: self.player, world: self)
                }
            }
            
//            let throwOutline = SKTexture(imageNamed: "throwbutton")
//            let button = SKSpriteNode(texture: throwOutline, color: .clear, size: throwOutline.size())
//            button.position = pos
//            let crystal = SKSpriteNode(imageNamed: crystalImageName.rawValue)
//            crystal.size = CGSize(width: 75, height: 75)
//            button.addChild(crystal)
//            button.zPosition = ZPositions.Foreground
//            button.size = CGSize(width: 100, height: 100)
//            self.camera?.addChild(button)

        }
    }
    
    /**
     Adds the buttons that the user uses to interact with the screen
     */
    func setupButtonsOnScreen () {
        self.jumpButton = self.camera?.childNode(withName: "jumpButton")
        self.grabButton = self.camera?.childNode(withName: "grabButton")
        self.actionButtons.climbButton = self.camera?.childNode(withName: "climbButton")
        let zoomButton = SKSpriteNode(texture: SKTexture(imageNamed: "throwbutton"))
        zoomButton.position = CGPoint(x: 761, y: 320)
        zoomButton.name = "zoomOut"
        self.camera?.addChild(zoomButton)
        
        let grabButton = SKSpriteNode(texture: SKTexture(imageNamed: "throwbutton"))
        grabButton.position = CGPoint(x: 792, y: -139)
        grabButton.name = "grabButton"
        self.camera?.addChild(grabButton)
        self.grabButton = grabButton
        self.grabButton?.isUserInteractionEnabled = false
        self.grabButton?.isHidden = true        
        
        self.jumpButton?.zPosition = ZPositions.Foreground
        self.actionButtons.climbButton?.zPosition = ZPositions.Foreground
    }
    
    func setupMineralCounterAndUseNodes (mineralType: CounterNodes, counterMineralNodePos: CGPoint, count: Int) {
        let mineralThrowNode = self.getCounterNode(counterNode: mineralType, buttonType: CounterNodes.ThrowButtonNode)
        let mineralCounterNode = self.getCounterNode(counterNode: mineralType, buttonType: CounterNodes.CounterNode)
        let mineralCounterLabel = self.getCounterNode(counterNode: mineralType, buttonType: CounterNodes.Label) as? SKLabelNode
        
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
}
