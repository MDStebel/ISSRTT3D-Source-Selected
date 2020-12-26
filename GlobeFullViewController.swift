//
//  GlobeFullViewController.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/27/20.
//  Copyright © 2020-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit
import SceneKit
import MapKit


/// Full-screen 3D interactive globe VC
class GlobeFullViewController: UIViewController, EarthGlobeProtocol {
    
    // MARK: - Properties
    
    struct Constants {
        static let apiEndpointAString       = "https://api.wheretheiss.at/v1/satellites/25544"
        static let fontForTitle             = Theme.nasa
        static let segueToHelpFromGlobe     = "segueToHelpFromGlobe"
        static let segueToSettings          = "segueToSettings"
        static let timerValue               = 3.0                           // Number of seconds between position updates
    }
    

    var fullGlobe                           = EarthGlobe()
    var globeBackgroundImageName            = ""
    var lastLat: Float                      = 0                             // To conform with the EarthGlobeProtocol, will save the last latitude
    var latitude                            = ""
    var longitude                           = ""
    var timer                               = Timer()
    
    private var helpTitle                   = "3D Globe Help"
    
    
    // MARK: - Outlets
    
    
    @IBOutlet var fullScreenGlobeView: SCNView!
    @IBOutlet var spaceBackgroundImage: UIImageView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var isRunningLabel: UILabel! {
        didSet {
            isRunningLabel.text = "Starting Up"
        }
    }
    @IBOutlet var controlsBackground: UIView! {
        didSet {
            controlsBackground.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            controlsBackground.layer.cornerRadius  = 27
            controlsBackground.layer.masksToBounds = true
        }
    }
    
    
    // MARK: - Methods
    
    
    /// Set the space image to use for the background
    /// - Parameter selection: Integer corresponding to the selected image index (based on slider control value, for example)
    func setGlobeBackgroundImage() {
        
        switch Globals.globeBackgroundImageSelection {
        case 0 :
            globeBackgroundImageName = Globals.hubbleDeepField
        case 1 :
            globeBackgroundImageName = Globals.milkyWay
        case 2 :
            globeBackgroundImageName = Globals.orionNebula
        case 3 :
            globeBackgroundImageName = Globals.tarantulaNebula
        default :
            globeBackgroundImageName = Globals.hubbleDeepField
        }
        
        spaceBackgroundImage?.image = UIImage(named: globeBackgroundImageName)
        
    }
    
    
    /// Set up a reference to this view controller. This allows AppDelegate to do stuff on it when it enters background.
    private func setUpAppDelegate() {
        
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        appDelegate.referenceToGlobeFullViewController = self
        
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUpAppDelegate()

    }
    

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Set font and attributes for navigation bar
        let titleFontSize = Theme.navigationBarTitleFontSize
        if let titleFont = UIFont(name: Constants.fontForTitle, size: titleFontSize) {
            let attributes = [NSAttributedString.Key.font: titleFont, .foregroundColor: UIColor.white]
            navigationController?.navigationBar.titleTextAttributes = attributes
            navigationController?.navigationBar.barTintColor = UIColor(named: Theme.tint)
        }
        
        setUpEarthGlobeScene(for: fullGlobe, in: fullScreenGlobeView, hasTintedBackground: false)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        Globals.globeBackgroundWasChanged = true
        startUpdatingGlobe()

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        stopUpdatingGlobe()
        
    }
    
    
    func startUpdatingGlobe() {
        
        Globals.globeBackgroundWasChanged = true
        earthGlobeLocateISS()       // Call once to update the globe before the timer starts in order to immediately show the ISS location, etc.
        timerStartup()
        
    }
    
    
    private func timerStartup() {

        timer = Timer.scheduledTimer(timeInterval: Constants.timerValue, target: self, selector: #selector(earthGlobeLocateISS), userInfo: nil, repeats: true)
        
    }
    
    
    func stopUpdatingGlobe() {
        
        timer.invalidate()
        
        isRunningLabel?.text = "Not Running"
        
    }
    
    
    /// Prepare for seque
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier != nil else { return }   // Prevents crash if a segue is unnamed
        
        switch segue.identifier {
        
        case Constants.segueToHelpFromGlobe :
            let navigationController                          = segue.destination as! UINavigationController
            let destinationVC                                 = navigationController.topViewController as! HelpViewController
            destinationVC.helpContentHTML                     = UserGuide.fullGlobe
            destinationVC.helpButtonInCallingVCSourceView     = navigationController.navigationBar
            destinationVC.title                               = helpTitle
            
        
        case Constants.segueToSettings :                                 // Keep tracking, set popover arrow to point to middle, below settings button
            let navigationController                          = segue.destination as! UINavigationController
            let destinationVC                                 = navigationController.topViewController as! SettingsTableViewController
            destinationVC.settingsButtonInCallingVCSourceView = navigationController.navigationBar
        
        default :
            break
            
        }
        
    }
    
    
    /// Unwind segue
    @IBAction func unwindFromOtherVCs(unwindSegue: UIStoryboardSegue) {

    }
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
        stopUpdatingGlobe()
        delay(0.5) {
            self.startUpdatingGlobe()
        }
        
    }

    
}
