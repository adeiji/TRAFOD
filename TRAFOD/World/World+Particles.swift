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
    
    func showBackgroundParticles () {
        if let backgroundParticlesPath = Bundle.main.path(forResource: "Background", ofType: "sks") {
            if let backgroundParticles = NSKeyedUnarchiver.unarchiveObject(withFile: backgroundParticlesPath) as? SKEmitterNode {
                backgroundParticles.particleColor = UIColor(red: 22.0/255.0, green: 43.0/255.0, blue: 87.0/255.0, alpha: 1.0)
                backgroundParticles.particlePositionRange.dx = self.scene!.size.width
                backgroundParticles.particlePositionRange.dy = self.scene!.size.height
                backgroundParticles.zPosition = -35
                self.camera?.addChild(backgroundParticles)
            }
        }
    }
    
    func showFireFlies () {
        if let fireFliesParticlesPath = Bundle.main.path(forResource: "FireFlies", ofType: "sks") {
            if let fireFliesParticles = NSKeyedUnarchiver.unarchiveObject(withFile: fireFliesParticlesPath) as? SKEmitterNode {
                fireFliesParticles.particlePositionRange.dx = self.scene!.size.width
                fireFliesParticles.particlePositionRange.dy = self.scene!.size.height
                fireFliesParticles.zPosition = 0
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
}
