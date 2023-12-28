//
//  Version Extension.swift
//
//  Created by Michael Stebel on 10/5/15.
//  Copyright © 2016-2024 ISS Real-Time Tracker. All rights reserved.
//

import UIKit

extension UIViewController {
  
    /// Get the version and build numbers, and the copyright for the app.
    /// - Returns: Tuple containing the version, build, and copyright as strings
    func getAppCurrentVersion() -> (version: String, build: String, copyright: String)? {
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let currentBuild   = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        let copyright      = Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as! String

        return (currentVersion, currentBuild, copyright)
        
    }
    
}
