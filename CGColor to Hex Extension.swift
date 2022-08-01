//
//  CGColor to Hex Extension.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 4/17/19.
//  Copyright © 2019-2022 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit

// Extension to CGColor that converts a CGColor to a hex string representation with or without alpha
extension CGColor {

    /// Computed property using default setting for alpha. Returns optional string containing the hex value without alpha.
    var toHex: String? {
        toHex()
    }
    
    /// Method to convert from CGColor to hex string.
    /// - Parameter alpha: True if alpha component is provided.
    /// - Returns: Optional string containing the hex value with alpha.
    func toHex(alpha: Bool = false) -> String? {
        
        guard let components = components, numberOfComponents >= 3 else { return nil }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)              // Default alpha value
        
        if components.count >= 4 {
            a = Float(components[3])    // Actual alpha value, if provided
        }
        
        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
        
    }
    
}
