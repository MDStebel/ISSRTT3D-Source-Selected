//
//  LaunchAnimationViewController.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 10/31/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


/// Animate the launchscreen
///
/// This is the entry view controller for the app. Animates then segues to tracking view controller.
class LaunchAnimationViewController: UIViewController {

    
    // MARK: - Properties
    
    
    private let segueToMainViewController = "mainViewControllerSegue"
    
    private let iconAnimationDuration = 5.0
    private let titleAnimationDuration = 5.0
    private let iconAnimationRotationAngle: CGFloat = -CGFloat.pi / 6.0    // In Radians
    private let iconAnimationScaleFactor: CGFloat = 0.5
    private let titleScaleFactor: CGFloat = 0.33
    
    private var xTrans: CGFloat = 0.0
    private var yTrans: CGFloat = 0.0
    private var iconScaleFactor: CGFloat = 0.0
    private var scaleFactorForAppNameTitleForLaunchAnimation: CGFloat = 0.0
    private var trans1 = CGAffineTransform.identity
    private var trans2 = CGAffineTransform.identity
    
    
    // Hide the status bar for this VC
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // MARK: - Outlets
    

    @IBOutlet private var ISSImage: UIImageView!
    
    @IBOutlet private var appNameTitleForLaunchAnimation: UILabel! {
        didSet {
            // initially shrink title label, which will zoom in later
            scaleFactorForAppNameTitleForLaunchAnimation = titleScaleFactor
            trans2 = trans2.scaledBy(x: scaleFactorForAppNameTitleForLaunchAnimation, y: scaleFactorForAppNameTitleForLaunchAnimation)
            appNameTitleForLaunchAnimation.transform = trans2
            appNameTitleForLaunchAnimation.alpha = 0.0
            appNameTitleForLaunchAnimation.isHidden = true
        }
    }
    
    @IBOutlet private var launchScreenVersionLabel: UILabel!
    
    @IBOutlet private var curves: UIImageView!
    
    
    // MARK: - Methods
    
    
    private func createTransformationsForISSIcon() {
        
        // Create a stack of transformations for the ISS graphic
        if #available(iOS 13, *) {
            
            xTrans = view.bounds.size.width + 20
            yTrans = view.bounds.size.height + 20
            iconScaleFactor = iconAnimationScaleFactor
            trans1 = trans1.translatedBy(x: xTrans, y: -yTrans)
            trans1 = trans1.scaledBy(x: iconScaleFactor, y: iconScaleFactor)
            trans1 = trans1.rotated(by: iconAnimationRotationAngle)
        
        } else {
            
            xTrans = view.bounds.size.width - ISSImage.bounds.size.width / 2.0 - 15
            yTrans = view.bounds.size.height - ISSImage.bounds.size.height / 2.0 + 10
            iconScaleFactor = 0.20
            trans1 = trans1.translatedBy(x: xTrans, y: -yTrans)
            trans1 = trans1.scaledBy(x: iconScaleFactor, y: iconScaleFactor)
            trans1 = trans1.rotated(by: iconAnimationRotationAngle)
        
        }
    }
    
    
    private func createTransformationsForTitle() {
        // Create a stack of transformations for the title
        scaleFactorForAppNameTitleForLaunchAnimation = 4.0
        trans2 = trans2.scaledBy(x: scaleFactorForAppNameTitleForLaunchAnimation, y: scaleFactorForAppNameTitleForLaunchAnimation)
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        createTransformationsForISSIcon()
        createTransformationsForTitle()
        getVersionAndCopyrightData()
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // Animate ISS graphic using the stack of transforms we created above. At completion, segue to the tracking VC
        UIView.animate(withDuration: iconAnimationDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: { [self] in
            launchScreenVersionLabel.text = "Version: \(Globals.versionNumber)  Build: \(Globals.buildNumber)  \(Globals.copyrightString)"
            ISSImage.transform = trans1
            ISSImage.alpha = 0.0
            curves.alpha = 0.0
            appNameTitleForLaunchAnimation.isHidden = false
            appNameTitleForLaunchAnimation.alpha = 1.0
            appNameTitleForLaunchAnimation.transform = trans2
        },
        completion: { [self] (completedOK) in
            performSegue(withIdentifier: segueToMainViewController, sender: self)
        })
        
    }
    
    
    /// Get current version and copyright information and update globals
    private func getVersionAndCopyrightData() {
        
        if let (versionNumber, buildNumber, copyright) = getAppCurrentVersion() {
            Globals.copyrightString = copyright
            Globals.versionNumber = versionNumber
            Globals.buildNumber = buildNumber
        }
        
    }
    
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        // If we're using an iPhone and rotated during animation, a crash will occur. This prevents that from happening.
        let currentDevice: UIDevice = UIDevice.current
        currentDevice.beginGeneratingDeviceOrientationNotifications()
        
        if currentDevice.model.hasPrefix("iPhone")  {
            performSegue(withIdentifier: segueToMainViewController, sender: self)
        }
        
    }

    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let segueInProcess = segue.identifier, segueInProcess == segueToMainViewController else { return }  // Prevents crash if a segue is unnamed

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
