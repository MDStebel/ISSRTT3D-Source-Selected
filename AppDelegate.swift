//
//  AppDelegate.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 1/28/16.
//  Copyright © 2016-2024 ISS Real-Time Tracker. All rights reserved.
//

import UIKit
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties

    var window: UIWindow?
    var referenceToViewController = TrackingViewController()
    var referenceToGlobeFullViewController = GlobeFullViewController()

    // MARK: - Methods

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureGlobalSettings()
        scheduleReviewRequest()
        return true
    }

    private func configureGlobalSettings() {
        window?.tintColor = UIColor(named: Theme.tint)
        Globals.thisDevice = UIDevice.current.model
        Globals.isIPad = Globals.thisDevice.hasPrefix("iPad")
    }

    private func scheduleReviewRequest() {
        let shortestTime: UInt32 = 50
        let longestTime: UInt32 = 200
        let timeInterval = TimeInterval(arc4random_uniform(longestTime - shortestTime) + shortestTime)
        Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(requestReview), userInfo: nil, repeats: false)
    }

    @objc private func requestReview() {
        if let windowScene = window?.windowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        handleAppStateChange()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        handleAppStateChange()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        SettingsDataModel.restoreUserSettings()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        SettingsDataModel.restoreUserSettings()
        if referenceToGlobeFullViewController.isViewLoaded {
            referenceToGlobeFullViewController.startUpdatingGlobe()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        handleAppStateChange()
    }

    private func handleAppStateChange() {
        referenceToViewController.stopAction()
        SettingsDataModel.saveUserSettings()
        if referenceToGlobeFullViewController.isViewLoaded {
            referenceToGlobeFullViewController.stopUpdatingGlobe()
        }
    }
}
