//
//  World+KeyboardControls.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/8/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

extension World {
    
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: .command, action: "")
        ]
    }
    
    
}
