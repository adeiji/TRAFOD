//
//  World+LevelTransfers.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/18/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

extension World {
    
    func gotoNextLevel<T: World> (fileName: String, levelType: T.Type, loadingScreen: Loading) {
        if let level = self.transitionToNextScreen(filename: fileName, loadingScreen: loadingScreen) as? T {
            level.collectedElements = self.collectedElements
            level.previousWorldPlayerPosition = self.player.position
            level.previousWorldCameraPosition = self.camera?.position
            return
        }
    }
    
    @discardableResult
    func transitionToNextScreen (filename: String, player: Player? = nil, loadingScreen: Loading) -> World {
        self.player.removeFromParent()
        if let player = player {
            loadingScreen.player = player
        } else {
            loadingScreen.player = self.player
        }
        loadingScreen.nextSceneName = filename
        let transition = SKTransition.moveIn(with: .right, duration: 1)
        loadingScreen.scaleMode = SKSceneScaleMode.aspectFit
        self.view?.presentScene(loadingScreen, transition: transition)
        return loadingScreen
    }
}
