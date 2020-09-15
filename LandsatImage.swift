//
//  LandsatImage.swift
//  ISS Tracker
//
//  Created by Michael Stebel on 7/19/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import Foundation


/// Model encapsulating a Landsat image as returned from the NASA API
struct LandsatImage {
    
    
    // MARK: - Properties
    
    
    let imageURL: String
    let captureDate: String
    let cloudScore: Double
    
} // end LandsatImage type


extension LandsatImage: CustomStringConvertible {
    
    var description: String {
        
        return "\(imageURL) \(captureDate) \(cloudScore)"
        
    }
    
}
