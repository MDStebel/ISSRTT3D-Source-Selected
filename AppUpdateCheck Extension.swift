//
//  AppUpdateCheck Extension.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 8/6/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


extension TrackingViewController {

    /// Save current version.
    /// Stores current app version data in the user's default database.
    func saveAppCurrentVersionNumber() {
        
        /// An instance of UserDefaults to save user settings
        let defaults            = UserDefaults.standard
        
        let currentAppVersion   = Globals.versionNumber
        let currentBuild        = Globals.buildNumber
        
        defaults.setValue(currentAppVersion, forKey: "App Version")
        defaults.setValue(currentBuild, forKey: "App Build")
        
    }
    
    
    /// Checks if app has been updated.
    /// Requires that "App Version" and "App Build" keys were saved in the defaults instance of UserDefaults. If not, these are saved and method returns false.
    /// - Returns : True if app was already installed AND then updated.
    func hasAppBeenUpdated() -> Bool {
        
        /// An instance of UserDefaults to save and access user settings
        let defaults            = UserDefaults.standard
        
        var wasUpdated          = false
        
        let currentAppVersion   = Globals.versionNumber
        let currentBuild        = Globals.buildNumber
        
        let previousAppVersion  = defaults.object(forKey: "App Version") as? String ?? ""           // Get stored version and build, if they exist
        let previousAppBuild    = defaults.object(forKey: "App Build") as? String ?? ""
        
        if previousAppVersion != currentAppVersion || previousAppBuild != currentBuild {            // App versions are different, thus the app has been updated
            wasUpdated = true
        }
        
        saveAppCurrentVersionNumber()
        
        return wasUpdated
        
    }
    
}
