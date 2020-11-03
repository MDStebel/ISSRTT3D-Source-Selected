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
        static let segueToHelpFromGlobe     = "segueToHelpFromGlobe"
        static let segueToSettings          = "segueToSettings"
        static let fontForTitle             = Theme.nasa
        static let timerValue               = 3.0                           // Seconds between position updates
        static let apiEndpointAString       = "https://api.wheretheiss.at/v1/satellites/25544"
    }
    

    var globe                               = EarthGlobe()
    var timer                               = Timer()
    var longitude                           = ""
    var latitude                            = ""
    var lastLat: Float                      = 0
    
    
    @IBOutlet weak var fullScreenGlobeView: SCNView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var isRunningLabel: UILabel! {
        didSet {
            isRunningLabel.text = "Running"
        }
    }
    
    
    // MARK: - Methods
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
        
        earthGlobeLocateISS()       // Call once to update the globe before the timer starts in order to immediately show the ISS location, etc.
        timerStartup()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)

        timer.invalidate()
        
    }
    
    
    private func timerStartup() {
        
        timer = Timer.scheduledTimer(timeInterval: Constants.timerValue, target: self, selector: #selector(earthGlobeLocateISS), userInfo: nil, repeats: true)
        
    }
    
    
    /// Set up our scene
    func setupGlobeScene() {
        
        globe.setupInSceneView(fullScreenGlobeView, forARKit: false)
        
        fullScreenGlobeView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)      // Transparent background
        fullScreenGlobeView.layer.cornerRadius = 15
        fullScreenGlobeView.layer.masksToBounds = true

    }
    
    
    /// Add the ISS position marker, orbital track, and current Sun position to the globe
    func updateEarthGlobeScene() {
        
        var headingFactor: Float = 1
        var showOrbit = false
        
        globe.removeLastNode()                      // Remove the last marker node, so we don't smear them together
        globe.removeLastNode()                      // Remove the last orbit track, so we don't smear them together as they precess
        globe.removeLastNode()                      // Remove the viewing circle
        
        let lat = Float(latitude) ?? 0.0
        let lon = Float(longitude) ?? 0.0
        
        if lastLat != 0 {
            showOrbit = true
            headingFactor = lat - lastLat < 0 ? -1 : 1
        }
        
        lastLat = lat                           // Save last latitude to use in calculating north or south heading vector after the second track update
        
        // Get the latitude of the Sun at the current time
        let latitudeOfSunAtCurrentTime = CoordinateCalculations.getLatitudeOfSunAtCurrentTime()
        
        // Get the longitude of Sun at current time
        let subSolarLon = CoordinateCalculations.SubSolarLongitudeOfSunAtCurrentTime()
        
        globe.setUpTheSun(lat: latitudeOfSunAtCurrentTime, lon: subSolarLon)
        if showOrbit {
            globe.addOrbitTrackAroundTheGlobe(lat: lat, lon: lon, headingFactor: headingFactor)
        }
        globe.addISSMarker(lat: lat, lon: lon)
        globe.addViewingCircle(lat: lat, lon: lon)
        globe.autoSpinGlobeRun(run: Globals.autoRotateGlobeEnabled)
        
    }
    
    
    /// Prepare for seque
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier != nil else { return }                                     // Prevents crash if a segue is unnamed
        
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
