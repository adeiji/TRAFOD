//
//  CGPoint+Offset.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/15/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
    func offset (_ point: CGPoint) -> CGPoint {
        return CGPoint(x: self.x + point.x, y: self.y + point.y)
    }
}
