//
//  Version Extension.swift
//
//  Created by Michael Stebel on 10/5/15.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


extension UIViewController {
    
    /// Get the version and build numbers for the app.
    ///
    /// Returns the current version, build, and copyright of the app in an optional tuple of strings.
    func getAppCurrentVersion() -> (version: String, build: String, copyright: String)? {
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        let copyright = Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as! String

        return (currentVersion, currentBuild, copyright)
        
    }
    
}
