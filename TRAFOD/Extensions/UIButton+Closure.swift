//
//  UIButton+Closure.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 9/22/22.
//  Copyright © 2022 Dephyned. All rights reserved.
//

import Foundation
import UIKit

// Enable the ability to use a closure for the UIButton target
public typealias UIButtonTargetClosure = (UIButton) -> ()

public extension UIButton {
    
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }
    
    private var targetClosure: UIButtonTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? ClosureWrapper else {  return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, ClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addTargetClosure(closure: @escaping UIButtonTargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(UIButton.closureAction), for: .touchUpInside)
    }
    
    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }
}

public class ClosureWrapper: NSObject {
    let closure: UIButtonTargetClosure
    
    init(_ closure: @escaping UIButtonTargetClosure) {
        self.closure = closure
    }
    
}
