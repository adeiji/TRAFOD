//
//  Level4.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/10/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class Level4 : Level {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.playBackgroundMusic(fileName: "level2")
    }
}
