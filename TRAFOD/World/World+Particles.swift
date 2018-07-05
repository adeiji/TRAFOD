//
//  World+Particles.swift
//  TRAFOD
//
//  Created by adeiji on 6/25/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import SpriteKit
import GameKit

extension World {
    
    @objc func showDoorParticles () {
        self.enumerateChildNodes(withName: "door") { (door, pointer) in
            if let fireFliesParticlesPath = Bundle.main.path(forResource: "Doors", ofType: "sks") {
                if let fireFliesParticles = NSKeyedUnarchiver.unarchiveObject(withFile: fireFliesParticlesPath) as? SKEmitterNode {
                    fireFliesParticles.zPosition = 0
                    fireFliesParticles.position = door.position
                    self.addChild(fireFliesParticles)
                }
            }
        }
    }
    
    func showNoWarpParticles () {
        for child in self.children {
            if let fireFliesParticlesPath = Bundle.main.path(forResource: "NoWarp", ofType: "sks") {
                if let fireFliesParticles = NSKeyedUnarchiver.unarchiveObject(withFile: fireFliesParticlesPath) as? SKEmitterNode {
                    if let child = child as? SKSpriteNode, let name = child.name {
                        if name.contains("nowarp") {
                            fireFliesParticles.zPosition = 0
                            fireFliesParticles.particlePositionRange.dx = child.size.width + 20
                            fireFliesParticles.particlePositionRange.dy = 50
                            fireFliesParticles.position = child.position
                            fireFliesParticles.position.y = child.position.y + (child.size.height) - 40
                            let constraint = SKConstraint.distance(SKRange(constantValue: 0), to: child)
                            fireFliesParticles.constraints = [constraint]
                            self.addChild(fireFliesParticles)
                        }
                    }
                }
            }
        }
    }
    
    func showResetParticles (nodeName: String = "resetObjects", toNode: SKSpriteNode? = nil) {
        if let node = toNode {
            if let fireFliesParticlesPath = Bundle.main.path(forResource: "Doors", ofType: "sks") {
                if let fireFliesParticles = NSKeyedUnarchiver.unarchiveObject(withFile: fireFliesParticlesPath) as? SKEmitterNode {
                    fireFliesParticles.zPosition = 0
                    fireFliesParticles.particleBirthRate = fireFliesParticles.particleBirthRate / 5.0
                    fireFliesParticles.particleLifetime = fireFliesParticles.particleLifetime / 2.0
                    fireFliesParticles.particlePositionRange.dx = node.size.width
                    fireFliesParticles.particlePositionRange.dy = node.size.height
                    node.addChild(fireFliesParticles)
                }
            }
            
            return 
        }
        
        if let node = self.childNode(withName: nodeName) {
            for child in node.children  {
                if let child = child as? SKSpriteNode {
                    if let fireFliesParticlesPath = Bundle.main.path(forResource: "Doors", ofType: "sks") {
                        if let fireFliesParticles = NSKeyedUnarchiver.unarchiveObject(withFile: fireFliesParticlesPath) as? SKEmitterNode {
                            fireFliesParticles.zPosition = 0
                            fireFliesParticles.particleBirthRate = fireFliesParticles.particleBirthRate / 5.0
                            fireFliesParticles.particleLifetime = fireFliesParticles.particleLifetime / 2.0
                            fireFliesParticles.particlePositionRange.dx = child.size.width
                            fireFliesParticles.particlePositionRange.dy = child.size.height
                            
                            if child.children.count == 0 {
                                fireFliesParticles.particleColor = UIColor(red: 89.0/255.0, green: 229/225.0, blue: 250/255.0, alpha: 1.0)
                                child.addChild(fireFliesParticles)
                            } else {
                                if child.children[0].name!.contains("white") {
                                    fireFliesParticles.particleColor = .white
                                } else if child.children[0].name!.contains("purple") {
                                    fireFliesParticles.particleColor = .purple
                                }
                                
                                child.addChild(fireFliesParticles)
                                child.children[0].addChild(fireFliesParticles.copy() as! SKNode)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func showBackgroundParticles (color: UIColor? = nil) {
        if let backgroundParticlesPath = Bundle.main.path(forResource: "Background", ofType: "sks") {
            if let backgroundParticles = NSKeyedUnarchiver.unarchiveObject(withFile: backgroundParticlesPath) as? SKEmitterNode {
                backgroundParticles.particleColor = UIColor(red: 22.0/255.0, green: 43.0/255.0, blue: 87.0/255.0, alpha: 1.0)
                if let color = color {
                    backgroundParticles.particleColor = color
                }
                backgroundParticles.particlePositionRange.dx = self.scene!.size.width
                backgroundParticles.particlePositionRange.dy = self.scene!.size.height
                backgroundParticles.zPosition = -35
                self.camera?.addChild(backgroundParticles)
            }
        }
    }
    
    func showDoubleGravParticles (color: UIColor? = nil) {
        self.enumerateChildNodes(withName: "doubleGravField") { (field, pointer) in
            if let backgroundParticlesPath = Bundle.main.path(forResource: "Background", ofType: "sks") {
                if let backgroundParticles = NSKeyedUnarchiver.unarchiveObject(withFile: backgroundParticlesPath) as? SKEmitterNode {
                    backgroundParticles.particleColor = UIColor(red: 22.0/255.0, green: 43.0/255.0, blue: 87.0/255.0, alpha: 1.0)
                    if let color = color {
                        backgroundParticles.particleColor = color
                    }
                    
                    if let field = field as? SKSpriteNode {
                        backgroundParticles.particlePositionRange.dx = field.size.width
                        backgroundParticles.particlePositionRange.dy = field.size.height
                        backgroundParticles.particleBirthRate = backgroundParticles.particleBirthRate / 4.0
                        backgroundParticles.position = field.position
                        backgroundParticles.zPosition = -35
                        self.addChild(backgroundParticles)
                    }
                    
                }
            }
        }
    }
    
    func showFireFlies (color: UIColor? = nil) {
        if let fireFliesParticlesPath = Bundle.main.path(forResource: "FireFlies", ofType: "sks") {
            if let fireFliesParticles = NSKeyedUnarchiver.unarchiveObject(withFile: fireFliesParticlesPath) as? SKEmitterNode {
                fireFliesParticles.particlePositionRange.dx = self.scene!.size.width
                fireFliesParticles.particlePositionRange.dy = self.scene!.size.height
                fireFliesParticles.zPosition = 0
                if let color = color {
                    fireFliesParticles.particleColor = color
                }
                self.camera?.addChild(fireFliesParticles)
            }
        }
    }
    
    func showRain () {
        if let rainPath = Bundle.main.path(forResource: "Rain", ofType: "sks") {
            if let rain = NSKeyedUnarchiver.unarchiveObject(withFile: rainPath) as? SKEmitterNode {
                rain.particlePositionRange.dx = self.scene!.size.width
                rain.position = CGPoint(x: 0, y: (self.scene!.size.height / 2.0) + 100)
                self.camera?.addChild(rain)
                self.rain = rain
            }
        }
    }
    
    func showMineralParticles () {
        for child in self.children {
            if child.name == "getAntiGrav" || child.name == "getImpulse" {
                if let magicPath = Bundle.main.path(forResource: "Magic", ofType: "sks") {
                    if let magic = NSKeyedUnarchiver.unarchiveObject(withFile: magicPath) as? SKEmitterNode {
                        if child.name == "getAntiGrav" {
                            magic.particleColor = UIColor.Style.ANTIGRAVMINERAL
                        } else {
                            magic.particleColor = UIColor.Style.IMPULSEMINERAL
                        }
                        magic.position = CGPoint(x: 0, y: 0)
                        child.addChild(magic)
                    }
                }
                
            }
        }
    }
    
    func showGroundParticles () {
        for child in self.children {
            if child.name == "ground" {
                if let magicPath = Bundle.main.path(forResource: "RainPatter", ofType: "sks") {
                    if let magic = NSKeyedUnarchiver.unarchiveObject(withFile: magicPath) as? SKEmitterNode {
                        magic.position = CGPoint(x: 0, y: 0)
                        child.addChild(magic)
                    }
                }
            }
        }
    }
    
    func showParticle (atPosition position: CGPoint, duration: TimeInterval) {
        if let path = Bundle.main.path(forResource: "Spark", ofType: "sks") {
            if let particle = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? SKEmitterNode {

                particle.position = position
                self.addChild(particle)
                
                self.run(SKAction.wait(forDuration: duration)) {
                    particle.removeFromParent()
                }
            }
        }
    }
}
