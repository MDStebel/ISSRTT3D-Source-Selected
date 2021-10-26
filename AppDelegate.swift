//
//  AppDelegate.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 1/28/16.
//  Copyright © 2016-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties
    
    
    var window: UIWindow?
    
    /// This property holds a reference to the tracking view controller
    var referenceToViewController          = TrackingViewController()
    
    /// This property holds a reference to the Earth globe full view controller
    var referenceToGlobeFullViewController = GlobeFullViewController()
    
    
    // MARK: - Methods
    
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window?.tintColor           = UIColor(named: Theme.tint)            // Set the global tint color
        
        Globals.thisDevice          = UIDevice.current.model                // Get device model name
        Globals.isIPad              = Globals.thisDevice.hasPrefix("iPad")  // Determine if device is an iPad and set this constant to true if so

        // Request user review between shortestTime & longestTime of use
        let shortestTime: UInt32    = 70                                    // In seconds
        let longestTime: UInt32     = 240                                   // In seconds
        guard let timeInterval      = TimeInterval(exactly: arc4random_uniform(longestTime - shortestTime) + shortestTime) else { return true }
        Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(AppDelegate.requestReview), userInfo: nil, repeats: false)

        return true
        
    }
    
    /// Selector called by timer for App Store reviews
    @objc func requestReview() {
        
        if let windowScene = window?.windowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
        
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        // Invalidate the timers and save user's settings when moving to inactive state
        referenceToViewController.stopAction()
        SettingsDataModel.saveUserSettings()
        
        if referenceToGlobeFullViewController.isViewLoaded {                // Only stop the globe if the view is loaded to avoid nil error
            referenceToGlobeFullViewController.stopUpdatingGlobe()
        }
        
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        // Invalidate the timers and save user's settings when moving to inactive state
        referenceToViewController.stopAction()
        SettingsDataModel.saveUserSettings()
        
        if referenceToGlobeFullViewController.isViewLoaded {                // Only stop the globe if the view is loaded to avoid nil error
            referenceToGlobeFullViewController.stopUpdatingGlobe()
        }
        
    }
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        SettingsDataModel.restoreUserSettings()
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {

        SettingsDataModel.restoreUserSettings()
        
        if referenceToGlobeFullViewController.isViewLoaded {                // Only start-up the globe if the view is loaded to avoid nil error
            referenceToGlobeFullViewController.startUpdatingGlobe()
        }
        
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        // Invalidate the timers and save user's settings when moving to inactive state
        referenceToViewController.stopAction()
        SettingsDataModel.saveUserSettings()
        
        if referenceToGlobeFullViewController.isViewLoaded {                // Only stop the globe if the view is loaded to avoid nil error
            referenceToGlobeFullViewController.stopUpdatingGlobe()
        }
        
    }
    
}
