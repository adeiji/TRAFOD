//
//  GameSwitchProtocol.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/22/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation

protocol GameSwitchProtocol {
    var isOn:Bool { get set }
    
    func flipSwitchAndMovePlatform () -> Bool
}
