//
//  Delay Function.swift
//
//  Created by Michael Stebel on 12/4/15.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


extension UIViewController {
    
    func delay(_ delay: Double, closure: @escaping () -> () ) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
        
    }
    
}
