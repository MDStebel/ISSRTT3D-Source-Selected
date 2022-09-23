//
//  LaunchAnimationViewController.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/31/16.
//  Copyright © 2016-2022 ISS Real-Time Tracker. All rights reserved.
//

import UIKit

/// Animated launchscreen
///
/// This is the entry view controller for the app. Animates then segues to tracking view controller.
class LaunchAnimationViewController: UIViewController {
    
    // MARK: - Properties
    
    private let iconAnimationDuration                                 = 5.0
    private let iconAnimationRotationAngle: CGFloat                   = -CGFloat.pi / 6.0    // In radians
    private let iconAnimationScaleFactor: CGFloat                     = 0.5
    private let segueToMainViewController                             = "mainViewControllerSegue"
    private let threeDScaleFactor: CGFloat                            = 0.05
    private let titleAnimationDuration                                = 5.0                  // In seconds
    private let titleScaleFactor: CGFloat                             = 0.33
    
    private var iconScaleFactor: CGFloat                              = 0
    private var scaleFactorFor3DTextImageForLaunchAnimation: CGFloat  = 0
    private var scaleFactorForAppNameTitleForLaunchAnimation: CGFloat = 0
    private var trans1                                                = CGAffineTransform.identity
    private var trans2                                                = CGAffineTransform.identity
    private var trans3                                                = CGAffineTransform.identity
    private var xTrans: CGFloat                                       = 0
    private var yTrans: CGFloat                                       = 0
    
    
    // Hide the status bar for this VC
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet private var curves: UIImageView!
    @IBOutlet private var ISSImage: UIImageView!
    @IBOutlet private var appNameTitleForLaunchAnimation: UILabel! {
        didSet {
            // Initially shrink title label, which will zoom in later
            scaleFactorForAppNameTitleForLaunchAnimation = titleScaleFactor
            trans2                                       = trans2.scaledBy(x: scaleFactorForAppNameTitleForLaunchAnimation, y: scaleFactorForAppNameTitleForLaunchAnimation)
            appNameTitleForLaunchAnimation.transform     = trans2
            appNameTitleForLaunchAnimation.alpha         = 0.0
            appNameTitleForLaunchAnimation.isHidden      = true
        }
    }
    @IBOutlet weak var threeDTextImage: UIImageView! {
        didSet {
            // Initially shrink the image, which will zoom in later
            scaleFactorFor3DTextImageForLaunchAnimation = threeDScaleFactor
            trans3                                      = trans3.scaledBy(x: scaleFactorFor3DTextImageForLaunchAnimation, y: scaleFactorFor3DTextImageForLaunchAnimation)
            threeDTextImage.transform                   = trans3
            threeDTextImage.alpha                       = 0.0
            threeDTextImage.isHidden                    = true
        }
    }
    
    
    // MARK: - Methods
    
    /// Create the transformations for ISS graphic
    private func createTransformationsForISSIcon() {
        
        if #available(iOS 13, *) {                  // If iOS 13 or greater
            
            xTrans          = view.bounds.size.width + 20
            yTrans          = view.bounds.size.height + 20
            iconScaleFactor = iconAnimationScaleFactor
            trans1          = trans1.translatedBy(x: xTrans, y: -yTrans)
            trans1          = trans1.scaledBy(x: iconScaleFactor, y: iconScaleFactor)
            trans1          = trans1.rotated(by: iconAnimationRotationAngle)
        
        } else {                                    // If earlier than iOS 13
            
            xTrans          = view.bounds.size.width - ISSImage.bounds.size.width / 2.0 - 15
            yTrans          = view.bounds.size.height - ISSImage.bounds.size.height / 2.0 + 10
            iconScaleFactor = 0.20
            trans1          = trans1.translatedBy(x: xTrans, y: -yTrans)
            trans1          = trans1.scaledBy(x: iconScaleFactor, y: iconScaleFactor)
            trans1          = trans1.rotated(by: iconAnimationRotationAngle)
        
        }
        
    }
    
    
    /// Create the transformations for the title
    private func createTransformationsForTitle() {

        scaleFactorForAppNameTitleForLaunchAnimation = 4.0
        trans2 = trans2.scaledBy(x: scaleFactorForAppNameTitleForLaunchAnimation, y: scaleFactorForAppNameTitleForLaunchAnimation)
        
    }
    
    
    /// Create the transformations for the '3D' label
    private func createTransformationsFor3D() {
        
        // Create a stack of transformations for the 3D text image
        if Globals.isIPad {
            scaleFactorFor3DTextImageForLaunchAnimation = 22
            yTrans = threeDTextImage.bounds.size.height + 850
            trans3 = trans3.translatedBy(x: 0, y: yTrans)
        } else {
            scaleFactorFor3DTextImageForLaunchAnimation = 12
            yTrans = threeDTextImage.bounds.size.height + 10
            trans3 = trans3.translatedBy(x: 0, y: yTrans)
        }
        
        trans3 = trans3.scaledBy(x: scaleFactorFor3DTextImageForLaunchAnimation, y: scaleFactorFor3DTextImageForLaunchAnimation)
        
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        createTransformationsForISSIcon()
        createTransformationsForTitle()
        createTransformationsFor3D()
        getVersionAndCopyrightData()
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // Animate ISS graphic using the stack of transforms we created above. At completion, segue to the tracking VC
        UIView.animate(withDuration: iconAnimationDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: { [self] in
            
            // Animate the ISS graphic
            ISSImage.transform                       = trans1
            ISSImage.alpha                           = 0.0
            curves.alpha                             = 0.0
            
            // Animate the title
            appNameTitleForLaunchAnimation.isHidden  = false
            appNameTitleForLaunchAnimation.alpha     = 1.0
            appNameTitleForLaunchAnimation.transform = trans2
            
            // Animate the 3D text image
            threeDTextImage.isHidden                 = false
            threeDTextImage.alpha                    = 1.0
            threeDTextImage.transform                = trans3
            
        },
        completion: { [self] (completedOK) in
            performSegue(withIdentifier: segueToMainViewController, sender: self)           // Now, segue to the Tracking view controller
        })
        
    }
    
    
    /// Get current version and copyright information and update the variables
    private func getVersionAndCopyrightData() {
        
        if let (versionNumber, buildNumber, copyright) = getAppCurrentVersion() {
            Globals.copyrightString = copyright
            Globals.versionNumber   = versionNumber
            Globals.buildNumber     = buildNumber
        }
        
    }
    
    
    // Trick to get iPhone to stop animating launch by rotating phone (doesn't work on iPad)
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        // If we're using an iPhone and rotated during animation, a crash may occur. This prevents that from happening.
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
