//
//  NegateMineralsProtocols.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/26/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation

/**
 Protocol for any object which negates gravity
 */
protocol NegateGravityProtocol { }

class NegateGravityGround: Ground, NegateGravityProtocol { }
