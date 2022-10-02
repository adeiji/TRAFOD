//
//  GameViewController.swift
//  TRAFOD
//
//  Created by adeiji on 6/7/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var leftHandView:UIView?
    var rightHandView:UIView?
    
    /** Responsible for presenting a scene */
    func presentScene (_ scene: World, previousScene: World) {
        let transition = SKTransition.moveIn(with: .right, duration: 0)
        scene.scaleMode = SKSceneScaleMode.aspectFit
        scene.rightHandView = self.rightHandView
        scene.leftHandView = self.leftHandView
        (self.view as? SKView)?.presentScene(scene, transition: transition)
    }
    
    /**
     The game has a view on the right to handle hand gestures on the right hand side and one on the left to handle gestures on the left hand side
     
     - Parameters:
        - view: The view to add the gesture views to
     */
    private func addGestureViews () {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: GameLevels.DawudVillage.rawValue) {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as? DawudVillageLevel
            {
                // Copy gameplay related content over to the scene
//                sceneNode.entities = scene.entities
//                sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFit
                
                let leftHandView = UIView()
                leftHandView.frame = CGRect(x: 0, y: 0, width: view.frame.width / 2.0, height: view.frame.height)
                self.view?.addSubview(leftHandView)
                let world = sceneNode as World
                
                world.leftHandView = leftHandView
                self.leftHandView = leftHandView
                
                let rightHandView = UIView()
                rightHandView.frame = CGRect(x: self.view.frame.width / 2.0, y: 0, width: view.frame.width / 2.0, height: view.frame.height)
                self.view?.addSubview(rightHandView)
                
                world.view?.showsPhysics = true
                world.rightHandView = rightHandView
                world.controller = self
                
                self.rightHandView = rightHandView
                
                self.view?.isMultipleTouchEnabled = true
                self.view?.isUserInteractionEnabled = true
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .landscapeLeft
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
