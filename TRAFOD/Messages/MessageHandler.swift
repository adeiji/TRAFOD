//
//  MessageHandler.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/24/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

extension Notification.Name {
    static let TRMessageCreated = Notification.Name("TRMessageCreated")
    static let TRStopShowingMessage = Notification.Name("TRStopShowingMessage")
}

struct Message {
    
    static let Name:String = "Message"
    
    let message:String
    let leftImage:UIImage?
    let rightImage:UIImage?
}

class MessageHandler {

    let world:World
    
    /** The message node that is currently being displayed on the screen. If this value is not nil then that means a message is currently being displayed. */
    var messageNode:SKSpriteNode? = nil
    
    init(world: World) {
        self.world = world
        
        NotificationCenter.default.addObserver(self, selector: #selector(showMessage(notification: )), name: .TRMessageCreated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeMessage), name: .TRStopShowingMessage, object: nil)
        
    }
    
    @objc func removeMessage () {
        self.messageNode?.removeFromParent()
        self.messageNode = nil
    }
    
    @objc func showMessage (notification: Notification) {
        if messageNode != nil { return }
        guard let message = notification.userInfo?[Message.Name] as? Message else {
            assertionFailure("The 'Message' key of notification object should be set to a value.")
            return
        }
        
        let brownColor = UIColor(red: 171/255, green: 147/255, blue: 94/255, alpha: 0.5)
        let messageNode = SKSpriteNode(color: brownColor, size: CGSize(width: 985, height: 385))
        let speechNode = SKLabelNode(text: "\"It's too heavy!\"")
        speechNode.fontName = "Herculanum"
        speechNode.fontSize = 75
        speechNode.preferredMaxLayoutWidth = 900
        speechNode.lineBreakMode = .byWordWrapping
        speechNode.verticalAlignmentMode = .center
        speechNode.numberOfLines = 0
        
        messageNode.addChild(speechNode)
        self.world.addChild(messageNode)
        self.messageNode = messageNode
    }
}