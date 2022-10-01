//
//  DiaryPiece.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/25/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import SpriteKit

/**
 An object that can be retrieved within the game.
 
 An example of a RetrievableObject would be a DiaryPieceNode. A DiaryPieceNode is an item that can be collected, or that when hit performs a specific action such as displays the diary information on the screen
 */
protocol RetrievableObject: SKSpriteNode {
    
    /** What happens when this object is retrieved */
    func execute ()
    
}

/**
 A snippet of information that is related to the story that is shown to the user
 */
class DiaryPieceNode:SKSpriteNode, RetrievableObject {
            
    var message:Message?
        
    init() {
        super.init(texture: Textures.DiaryPiece, color: .clear, size: CGSize(width: 100, height: 100))
        self.physicsBody = PhysicsHandler.getPhysicsBodyForRetrievableObject(size: self.size)
        
        let action = SKAction.scale(by: 1.25, duration: 1.0)
        let actionSequence = SKAction.sequence([ action, action.reversed() ])
        self.run(SKAction.repeatForever(actionSequence))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.message = Message(text: "", leftImage: nil, rightImage: nil)
        super.init(coder: aDecoder)
    }
    
    func execute() {
        guard let message = self.message else { return }
        NotificationCenter.default.post(name: .TRMessageCreated, object: nil, userInfo: [Message.Name:message])
        self.removeFromParent()
        self.run(SKAction.playSoundFileNamed(SoundFiles.FX.MineralGrab, waitForCompletion: false))
    }
    
}
