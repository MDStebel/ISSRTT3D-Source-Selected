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
        let shortestTime: UInt32    = 45                                    // In seconds
        let longestTime: UInt32     = 300                                   // In seconds
        guard let timeInterval      = TimeInterval(exactly: arc4random_uniform(longestTime - shortestTime) + shortestTime) else { return true }
        Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(AppDelegate.requestReview), userInfo: nil, repeats: false)

        return true
        
    }
    
    @objc func requestReview() {
        SKStoreReviewController.requestReview()
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        // Invalidate the timers and save user's settings when moving to inactive state
        referenceToViewController.stopAction()
        SettingsDataModel.saveUserSettings()
        
        if referenceToGlobeFullViewController.isViewLoaded {                // Only stop the globe if the view is loaded to avoid nil error
            referenceToGlobeFullViewController.stopUpdatingGlobe()
        }
        
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // Invalidate the timers and save user's settings when moving to inactive state
        referenceToViewController.stopAction()
        SettingsDataModel.saveUserSettings()
        
        if referenceToGlobeFullViewController.isViewLoaded {                // Only stop the globe if the view is loaded to avoid nil error
            referenceToGlobeFullViewController.stopUpdatingGlobe()
        }
        
    }
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        SettingsDataModel.restoreUserSettings()
        
        if referenceToGlobeFullViewController.isViewLoaded {                // Only start-up the globe if the view is loaded to avoid nil error
            referenceToGlobeFullViewController.startUpdatingGlobe()
        }
        
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground.
        
        // Invalidate the timers and save user's settings when moving to inactive state
        referenceToViewController.stopAction()
        SettingsDataModel.saveUserSettings()
        
        if referenceToGlobeFullViewController.isViewLoaded {                // Only stop the globe if the view is loaded to avoid nil error
            referenceToGlobeFullViewController.stopUpdatingGlobe()
        }
        
    }
    
}
