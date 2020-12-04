//
//  Delay Function.swift
//
//  Created by Michael Stebel on 12/4/15.
//  Copyright © 2015-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


extension UIViewController {
    
    /// Method to wait before executing a closure
    /// - Parameters:
    ///   - delay: Delay
    ///   - closure: Closure as ()->() type. The closure is allowed to execute after the method returns
    /// - Returns: Returns immediately after delay. Closure is executed asynchronously
    func delay(_ delay: Double, closure: @escaping () -> () ) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
        
    }
    
}
