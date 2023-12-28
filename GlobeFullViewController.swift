//
//  GlobeFullViewController.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/27/20.
//  Copyright © 2020-2024 ISS Real-Time Tracker. All rights reserved.
//

import AVFoundation
import Combine
import MapKit
import SceneKit
import UIKit

/// Full-screen 3D interactive globe VC
class GlobeFullViewController: UIViewController, AVAudioPlayerDelegate, EarthGlobeProtocol {
    
    
    // MARK: - Properties
    
    
    struct Constants {
        static let ISSAPIEndpointString  = ApiEndpoints.issTrackerAPIEndpointA       // ISS API
        static let fontForTitle          = Theme.nasa
        static let generalAPIKey         = ApiKeys.generalLocationKey
        static let generalEndpointString = ApiEndpoints.generalTrackerAPIEndpoint    // General endpoint
        static let segueToHelpFromGlobe  = "segueToHelpFromGlobe"
        static let segueToSettings       = "segueToSettings"
        static let timerValue            = 3.0                                       // Number of seconds between position updates
    }
    
    private struct SoundtrackButtonImage {
        static let on                    = "music.quarternote.3"
        static let off                   = "music.quarternote.3"
    }

    var coordinates                      = [SatelliteOrbitPosition.Positions]()
    var fullGlobe                        = EarthGlobe()
    var globeBackgroundImageName         = ""
    var hLat                             = ""
    var hLon                             = ""
    var hubbleLastLat: Float             = 0.0                                       // To conform with the EarthGlobeProtocol, will save the last Hubble latitude
    var hubbleLatitude                   = 0.0
    var hubbleLongitude                  = 0.0
    var iLat                             = ""
    var iLon                             = ""
    var issLastLat: Float                = 0                                         // To conform with the EarthGlobeProtocol, will save the last ISS latitude
    var issLatitude                      = 0.0
    var issLongitude                     = 0.0
    var tLat                             = ""
    var tLon                             = ""
    var timer: AnyCancellable?
    var tssLastLat: Float                = 0                                         // To conform with the EarthGlobeProtocol, will save the last TSS latitude
    var tssLatitude                      = 0.0
    var tssLongitude                     = 0.0
    
    
    private var helpTitle                = "3D Globe Help"
    
    // Soundtrack
    let soundtrackFilePathString = Theme.soundTrack
    var soundtrackMusicPlayer: AVAudioPlayer?
    var soundtrackButtonOn = false {
        didSet {
            if soundtrackButtonOn {
                soundtrackMusicButton.image = UIImage(systemName: SoundtrackButtonImage.on)
                soundtrackMusicButton.tintColor = .white.withAlphaComponent(1.0)
            } else {
                soundtrackMusicButton.image = UIImage(systemName: SoundtrackButtonImage.off)
                soundtrackMusicButton.tintColor = .white.withAlphaComponent(0.60)
            }
        }
    }
    
    
    // Change status bar to light color for this VC
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    
    // MARK: - Outlets
    
    
    @IBOutlet var spaceBackgroundImage: UIImageView!
    @IBOutlet var fullScreenGlobeView: SCNView!
    @IBOutlet var controlsBackground: UIView! {
        didSet {
            controlsBackground.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            controlsBackground.layer.cornerRadius  = 27
            controlsBackground.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var isRunningLabel: UILabel! {
        didSet {
            isRunningLabel.text = "Starting Up"
        }
    }
    @IBOutlet weak var soundtrackMusicButton: UIBarButtonItem!
    
    
    
    // MARK: - Methods
    
    
    /// Set the space image to use for the background
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
        case 4 :
            globeBackgroundImageName = Globals.jamesWebDeepField
        case 5 :
            globeBackgroundImageName = Globals.blackBackgroundImage
        default :
            globeBackgroundImageName = Globals.jamesWebDeepField
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
        setUpSoundTrackMusicPlayer()
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set navigation and status bar font and color to our Theme
        let titleFontSize                   = Theme.navigationBarTitleFontSize
        let barAppearance                   = UINavigationBarAppearance()
        barAppearance.backgroundColor       = UIColor(named: Theme.tint)
        barAppearance.titleTextAttributes   = [.font : UIFont(name: Constants.fontForTitle, size: titleFontSize) as Any, .foregroundColor : UIColor.white]
        navigationItem.standardAppearance   = barAppearance
        navigationItem.scrollEdgeAppearance = barAppearance
        
        setUpEarthGlobeScene(for: fullGlobe, in: fullScreenGlobeView, hasTintedBackground: false)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        Globals.globeBackgroundWasChanged = true
        startUpdatingGlobe()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        soundtrackMusicPlayer?.stop()
        stopUpdatingGlobe()
        
    }
    
    
    func startUpdatingGlobe() {
        
        Globals.globeBackgroundWasChanged = true
        earthGlobeLocateSatellites()       // Call once to update the globe before the timer starts in order to immediately show the ISS location, etc.
        start()
    }
    
    
    private func start() {
        
        timer = Timer
            .publish(every: Constants.timerValue, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.earthGlobeLocateSatellites()
            }
        
    }
    
    
    @IBAction func resetGlobe(_ sender: UIButton) {
        
        reset()
        
    }
    
    
    func reset() {
        
        soundtrackMusicPlayer?.stop()
        stopUpdatingGlobe()
        fullGlobe = EarthGlobe()
        setUpEarthGlobeScene(for: fullGlobe, in: fullScreenGlobeView, hasTintedBackground: false)
        startUpdatingGlobe()
        
    }
    
    
    func stopUpdatingGlobe() {
        
        timer?.cancel()
        isRunningLabel?.text = "Not Running"
        
    }
    
    
    @IBAction func toggleAutoRotation() {
        
        Globals.autoRotateGlobeEnabled.toggle()
        
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
    
    
    /// Set up audio player to play soundtrack without stopping any audio that was playing when app launched
    private func setUpSoundTrackMusicPlayer() {
        
        if let bundlePath = Bundle.main.path(forResource: soundtrackFilePathString, ofType: nil) {
            
            let url = URL.init(fileURLWithPath: bundlePath)
            do {
                try soundtrackMusicPlayer = AVAudioPlayer(contentsOf: url)
                soundtrackMusicPlayer?.delegate = self
            } catch {
                return
            }
        } else {
            return
        }
        
        soundtrackButtonOn = false
        soundtrackMusicPlayer?.numberOfLoops = -1       // Loop indefinitely
        
    }
    
    
    /// Toggle soundtrack on and off
    @IBAction func toggleMusicSoundtrack(_ sender: UIBarButtonItem) {
        
        if soundtrackButtonOn {
            soundtrackMusicPlayer?.pause()
        } else {
            soundtrackMusicPlayer?.play()
        }
        
        soundtrackButtonOn.toggle()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
        stopUpdatingGlobe()
        delay(0.5) {
            self.startUpdatingGlobe()
        }
        
    }
    
}
