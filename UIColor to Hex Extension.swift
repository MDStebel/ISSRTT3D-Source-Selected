//
//  UIColor to Hex Extension.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 4/17/19.
//  Copyright © 2019-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


extension UIColor {
    
    /// Property computed using default setting for alpha
    ///
    /// Returns optional string
    var toHex: String? {
        toHex()
    }
    
    /// Method to convert from UIColor to hex string
    ///
    /// Returns optional string
    /// - Parameter alpha: Value for alpha
    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
        
    }
    
}
