//
//  GlobeFullViewController.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 10/27/20.
//  Copyright © 2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit
import SceneKit
import MapKit


/// Full-screen 3D interactive globe
class GlobeFullViewController: UIViewController {
    
    
    // MARK: - Properties
    
    struct Constants {
        static let apiEndpointAString       = "---"
        static let fontForTitle             = Theme.nasa
        static let segueToHelpFromGlobe     = "segueToHelpFromGlobe"
        static let segueToSettings          = "segueToSettings"
        static let timerValue               = 3.0                           // Seconds between position updates
    }
    

    var fullGlobe                           = EarthGlobe()
    var lastLat: Float                      = 0
    var latitude                            = ""
    var longitude                           = ""
    var timer                               = Timer()
    
    
    // MARK: - Outlets
    
    
    @IBOutlet weak var fullScreenGlobeView: SCNView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var isRunningLabel: UILabel! {
        didSet {
            isRunningLabel.text = ""
        }
    }
    @IBOutlet var controlsBackground: UIView! {
        didSet {
            controlsBackground.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            controlsBackground.layer.cornerRadius = 27
            controlsBackground.layer.masksToBounds = true
        }
    }
    
    
    // MARK: - Methods
    
    
    /// Set up a reference to this view controller. This allows AppDelegate to do stuff on it when it enters background.
    private func setupAppDelegate() {
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        appDelegate.referenceToGlobeFullViewController = self
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupAppDelegate()
        setupGlobeScene()

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
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        startUpdatingGlobe()

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        stopUpdatingGlobe()
        
    }
    
    
    func startUpdatingGlobe() {
        
        earthGlobeLocateISS()       // Call once to update the globe before the timer starts in order to immediately show the ISS location, etc.
        timerStartup()
        
    }
    
    
    private func timerStartup() {
        
        timer = Timer.scheduledTimer(timeInterval: Constants.timerValue, target: self, selector: #selector(earthGlobeLocateISS), userInfo: nil, repeats: true)
        
    }
    
    
    func stopUpdatingGlobe() {
        
        timer.invalidate()
        
    }
    
    
    /// Set up the scene
    func setupGlobeScene() {
        
        fullGlobe.setupInSceneView(fullScreenGlobeView, pinchGestureIsEnabled: false)
        
        fullScreenGlobeView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)      // Transparent background
        fullScreenGlobeView.layer.cornerRadius = 15
        fullScreenGlobeView.layer.masksToBounds = true

    }
    
    
    /// Add the ISS position marker, orbital track, and current Sun position to the globe
    func updateFullEarthGlobeScene() {
        
        var headingFactor: Float = 1
        var showOrbit = false
        
        fullGlobe.removeLastNode()                      // Remove the last marker node, so we don't smear them together
        fullGlobe.removeLastNode()                      // Remove the last orbit track, so we don't smear them together as they precess
        fullGlobe.removeLastNode()                      // Remove the viewing circle
        
        let lat = Float(latitude) ?? 0.0
        let lon = Float(longitude) ?? 0.0
        
        if lastLat != 0 {
            showOrbit = true
            headingFactor = lat - lastLat < 0 ? -1 : 1
        }
        
        lastLat = lat                                   // Save last latitude to use in calculating north or south heading vector after the second track update
        
        // Get the latitude of the Sun at the current time
        let latitudeOfSunAtCurrentTime = CoordinateCalculations.getLatitudeOfSunAtCurrentTime()
        
        // Get the longitude of Sun at current time
        let subSolarLon = CoordinateCalculations.SubSolarLongitudeOfSunAtCurrentTime()
        
        fullGlobe.setUpTheSun(lat: latitudeOfSunAtCurrentTime, lon: subSolarLon)
        if showOrbit {
            fullGlobe.addOrbitTrackAroundTheGlobe(lat: lat, lon: lon, headingFactor: headingFactor)
        }
        fullGlobe.addISSMarker(lat: lat, lon: lon)
        fullGlobe.addViewingCircle(lat: lat, lon: lon)
        fullGlobe.autoSpinGlobeRun(run: Globals.autoRotateGlobeEnabled)
        
        fullGlobe.camera.fieldOfView = 60
        
    }
    
    
    /// Prepare for seque
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier != nil else { return }   // Prevents crash if a segue is unnamed
        
        switch segue.identifier {
        
        case Constants.segueToHelpFromGlobe :
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.topViewController as! HelpViewController
            destinationVC.helpContentHTML = UserGuide.fullGlobe
            destinationVC.helpButtonInCallingVCSourceView = navigationController.navigationBar
            
        
        case Constants.segueToSettings :                                 // Keep tracking, set popover arrow to point to middle, below settings button
            
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.topViewController as! SettingsTableViewController
            destinationVC.settingsButtonInCallingVCSourceView = navigationController.navigationBar
        
        default :
            break
        }
        
    }
    
    
    /// Unwind segue
    @IBAction func unwindFromOtherVCs(unwindSegue: UIStoryboardSegue) {

    }
    
    
}
