//
//  LaunchAnimationViewController.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/31/16.
//  Copyright © 2016-2024 ISS Real-Time Tracker. All rights reserved.
//

import UIKit

/// Animated launch screen
///
/// This is the entry view controller for the app. Animates then segues to the tracking view controller.
class LaunchAnimationViewController: UIViewController {
    
    // MARK: - Properties
    
    private let iconAnimationDuration: TimeInterval = 5.0
    private let iconAnimationRotationAngle: CGFloat = -CGFloat.pi / 6.0 // In radians
    private let iconAnimationScaleFactor: CGFloat = 0.5
    private let segueToMainViewController = "mainViewControllerSegue"
    private let threeDScaleFactor: CGFloat = 0.05
    private let titleAnimationDuration: TimeInterval = 5.0 // In seconds
    private let titleScaleFactor: CGFloat = 0.33
    
    private var iconScaleFactor: CGFloat = 0
    private var scaleFactorFor3DTextImageForLaunchAnimation: CGFloat = 0
    private var scaleFactorForAppNameTitleForLaunchAnimation: CGFloat = 0
    private var trans1 = CGAffineTransform.identity
    private var trans2 = CGAffineTransform.identity
    private var trans3 = CGAffineTransform.identity
    private var xTrans: CGFloat = 0
    private var yTrans: CGFloat = 0
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    // MARK: - Outlets
    
    @IBOutlet private var curves: UIImageView!
    @IBOutlet private var ISSImage: UIImageView!
    @IBOutlet private var appNameTitleForLaunchAnimation: UILabel! {
        didSet {
            scaleFactorForAppNameTitleForLaunchAnimation = titleScaleFactor
            trans2 = trans2.scaledBy(x: scaleFactorForAppNameTitleForLaunchAnimation, y: scaleFactorForAppNameTitleForLaunchAnimation)
            appNameTitleForLaunchAnimation.transform = trans2
            appNameTitleForLaunchAnimation.alpha = 0.0
            appNameTitleForLaunchAnimation.isHidden = true
        }
    }
    @IBOutlet weak var threeDTextImage: UIImageView! {
        didSet {
            scaleFactorFor3DTextImageForLaunchAnimation = threeDScaleFactor
            trans3 = trans3.scaledBy(x: scaleFactorFor3DTextImageForLaunchAnimation, y: scaleFactorFor3DTextImageForLaunchAnimation)
            threeDTextImage.transform = trans3
            threeDTextImage.alpha = 0.0
            threeDTextImage.isHidden = true
        }
    }
    
    // MARK: - Methods
    
    private func createTransformationsForISSIcon() {
        xTrans = view.bounds.size.width + 20
        yTrans = view.bounds.size.height + 20
        iconScaleFactor = iconAnimationScaleFactor
        trans1 = trans1.translatedBy(x: xTrans, y: -yTrans)
        trans1 = trans1.scaledBy(x: iconScaleFactor, y: iconScaleFactor)
        trans1 = trans1.rotated(by: iconAnimationRotationAngle)
    }
    
    private func createTransformationsForTitle() {
        scaleFactorForAppNameTitleForLaunchAnimation = 4.0
        trans2 = trans2.scaledBy(x: scaleFactorForAppNameTitleForLaunchAnimation, y: scaleFactorForAppNameTitleForLaunchAnimation)
    }
    
    private func createTransformationsFor3D() {
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
        animateLaunchScreen()
    }
    
    private func animateLaunchScreen() {
        UIView.animate(
            withDuration: iconAnimationDuration,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.2,
            options: .curveEaseInOut,
            animations: { [self] in
                ISSImage.transform = trans1
                ISSImage.alpha = 0.0
                curves.alpha = 0.0
                appNameTitleForLaunchAnimation.isHidden = false
                appNameTitleForLaunchAnimation.alpha = 1.0
                appNameTitleForLaunchAnimation.transform = trans2
                threeDTextImage.isHidden = false
                threeDTextImage.alpha = 1.0
                threeDTextImage.transform = trans3
            },
            completion: { [self] _ in
                performSegue(withIdentifier: segueToMainViewController, sender: self)
            }
        )
    }
    
    private func getVersionAndCopyrightData() {
        if let (versionNumber, buildNumber, copyright) = getAppCurrentVersion() {
            Globals.copyrightString = copyright
            Globals.versionNumber = versionNumber
            Globals.buildNumber = buildNumber
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if UIDevice.current.model.hasPrefix("iPhone") {
            performSegue(withIdentifier: segueToMainViewController, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == segueToMainViewController else { return }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
