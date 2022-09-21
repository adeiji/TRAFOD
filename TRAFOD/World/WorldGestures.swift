//
//  TouchInteractions.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/19/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

class WorldGestures: NSObject, UIGestureRecognizerDelegate {
    
    let world:World
    let player:Player
    
    let rightHandSwipeUp:UISwipeGestureRecognizer
    let rightHandPressGesture:UILongPressGestureRecognizer
    let rightHandTapGesture:UITapGestureRecognizer
    
    init (world: World, player: Player) {
        self.world = world
        self.player = player
                
        let swipeUpGesture = UISwipeGestureRecognizer()
        swipeUpGesture.direction = .up
        self.rightHandSwipeUp = swipeUpGesture
                
        let rightHandPressGesture = UILongPressGestureRecognizer()
        rightHandPressGesture.minimumPressDuration = 0.2
        rightHandPressGesture.allowableMovement = 100
        self.rightHandPressGesture = rightHandPressGesture
        
        self.rightHandTapGesture = UITapGestureRecognizer()
        self.rightHandTapGesture.numberOfTapsRequired = 1
                                                
        super.init()
        
        swipeUpGesture.addTarget(self, action: #selector(swipedVertically(gestureRecognizer:)))
        rightHandPressGesture.addTarget(self, action: #selector(rightHandPress(gestureRecognizer:)))
        self.rightHandTapGesture.addTarget(self, action: #selector(rightHandTapped(gestureRecognizer:)))
        
        self.rightHandTapGesture.view?.isUserInteractionEnabled = true
        self.rightHandSwipeUp.view?.isUserInteractionEnabled = true
        self.rightHandPressGesture.view?.isUserInteractionEnabled = true
        
        self.rightHandSwipeUp.delegate = self
        self.rightHandPressGesture.delegate = self
        
        self.world.rightHandView?.addGestureRecognizer(rightHandPressGesture)
        self.world.rightHandView?.addGestureRecognizer(swipeUpGesture)
        self.world.rightHandView?.addGestureRecognizer(self.rightHandTapGesture)
        
        
        self.rightHandPressGesture.cancelsTouchesInView = false
        
        
        
    }
    
    @objc func rightHandPress (gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began {
            if self.player.canGrabObject() {
                self.player.grabObject()
            }
        } else if gestureRecognizer.state == .ended {
            if self.player.isGrabbingObject() {
                self.player.stopGrabbingObject()
            }
        }
    }
    
    @objc func rightHandTapped (gestureRecognizer: UISwipeGestureRecognizer) {

        if self.player.isInContactWithFence() {
            self.player.startClimbing()
            return
        }
        
        // If the player is in contact with a rope then grab the rope
        self.player.handleRopeGrabInteraction()
    }
    
    @objc func swipedVertically (gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.direction == .up {
            if self.player.canJump() {
                self.world.handleJump()
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.rightHandSwipeUp && otherGestureRecognizer == self.rightHandPressGesture {
            return true
        }
        
        return false
    }
    
}
