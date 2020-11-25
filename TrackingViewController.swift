//
//  TrackingViewController.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 1/28/2016
//  Copyright © 2016-2020 Michael Stebel Consulting. All rights reserved.
//

import AVFoundation
import MapKit
import SceneKit
import UIKit


class TrackingViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, AVAudioPlayerDelegate, EarthGlobeProtocol {
    
    // MARK: - Types
    
    
    /// Zoom factor ranges and their maximum values
    private enum ZoomFactorRanges: Double {
        
        typealias RawValue = Double
        
        case fine                               = 3.0
        case small                              = 10.0
        case medium                             = 30.0
        case large                              = 90.0
        
    }
    
    /// Segue names
    private struct Segues {
        
        static let NASATVSegue                  = "segueToNasaTV"
        static let crewSeque                    = "segueToCurrentCrew"
        static let earthViewSegue               = "segueToStreamingVideo"
        static let globeSegue                   = "segueToFullGlobe"
        static let helpSegue                    = "helpViewSegue"
        static let passesSegue                  = "segueToPassTimes"
        static let segueToFullGlobeFromTabBar   = "segueToFullGlobeFromTabBar"
        static let settingsSegue                = "segueToSettings"
        
    }
    
    /// Local constants
    struct Constants {
        static let animationOffsetY: CGFloat    = 90.0
        static let apiEndpointAString           = "https://api.wheretheiss.at/v1/satellites/25544"
        static let apiEndpointBString           = "http://api.open-notify.org/iss-now.json"
        static let defaultTimerInterval         = 3.0
        static let fontForTitle                 = Theme.nasa
        static let kilometersToMiles            = 0.621371192
        static let linefeed                     = "\n"
        static let numberFormatter              = NumberFormatter()
        static let numberOfZoomIntervals        = 6
        static let zoomFactorStringFormat       = "Zoom: %2.2f°"
        static let zoomScaleFactor              = 30.0
    }
    
    private struct TrackingButtonImages {
        static let play                         = "icons8-play_filled"
        static let pause                        = "icons8-pause_filled"
    }
    
    private struct SoundtrackButtonImages {
        static let on                           = "music on"
        static let off                          = "music off"
    }
    
    
    // MARK: - Properties
    
    
    
    // Change status bar to light color for this VC
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Soundtrack
    var soundtrackMusicPlayer: AVAudioPlayer?
    let soundtrackFilePathString = Theme.soundTrack
    var soundtrackButtonOn: Bool = false {
        didSet {
            if soundtrackButtonOn {
                soundtrackMusicButton.setImage(UIImage(named: SoundtrackButtonImages.on), for: .normal)
            } else {
                soundtrackMusicButton.setImage(UIImage(named: SoundtrackButtonImages.off), for: .normal)
            }
        }
    }
    
    /// This computed property returns the max value for the zoom slider
    private var zoomSliderMaxValue: Double {
        switch Globals.zoomRangeFactorSelection {
        case 0 :
            zoomRangeFactorLabel = "Fine"
            return ZoomFactorRanges.fine.rawValue
        case 1:
            zoomRangeFactorLabel = "Small"
            return ZoomFactorRanges.small.rawValue
        case 2 :
            zoomRangeFactorLabel = "Medium"
            return ZoomFactorRanges.medium.rawValue
        case 3 :
            zoomRangeFactorLabel = "Large"
            return ZoomFactorRanges.large.rawValue
        default :
            zoomRangeFactorLabel = "Medium"
            return ZoomFactorRanges.medium.rawValue
        }
    }
    
    
    /// This computed property returns the minimum zoom value for the slider based on the max value divided by a scaling factor
    private var zoomSliderMinValue: Double {
        return max(zoomSliderMaxValue / Constants.zoomScaleFactor, zoomSliderMinFloor)     // Keep minimum value >= to zoomSliderMinFloor
    }
    
    /// This computed property returns the value used for both the lat and long in the map span and the default value of the zoom slider
    var zoomFactorDefaultValue: Float {
        let zf = Float(zoomSliderMaxValue / 2.0)
        Globals.zoomFactorDefaultValue = zf
        
        return zf
    }
    
    /// This computed property returns the allowed minimum zoom slider setting based on the device, for better performance on iPad
    private var zoomSliderMinFloor: Double {
        if Globals.isIPad {
            return 0.15
        } else {
            return 0.05
        }
    }
     
    var location: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(CLLocationDegrees(latitude)!, CLLocationDegrees(longitude)!)
    }
    
    private var span: MKCoordinateSpan {
        return MKCoordinateSpan.init(latitudeDelta: latDelta, longitudeDelta: lonDelta)
    }
    
    private var latDelta: CLLocationDegrees {
        return Double(zoomSlider.value)
    }
    
    private var lonDelta: CLLocationDegrees {
        return latDelta
    }
    
    var region: MKCoordinateRegion {
        return MKCoordinateRegion.init(center: location, span: span)
    }
    
   
    /// String format for zoom factor label
    var dateFormatter: DateFormatter?       = DateFormatter()         // This is declared as an optional so that we can test it for nil in save settings in case it wasn't set before being called
       
    private var alreadyAnimatedStartPrompt  = false
    private var altitudeInMiles             = ""
    private var justStartedUp               = false
    private var velocityInKmH               = ""
    private var velocityInMPH               = ""
    private var zoomInterval                = [Float]()
    private var zoomRangeFactorLabel        = ""
    private var zoomValueWasChanged         = false
    
    var aPolyLine                           = MKPolyline()
    var altString                           = ""
    var atDateAndTime                       = ""
    var globe                               = EarthGlobe()
    var lastLat: Float                      = 0
    var latitude                            = ""
    var listOfCoordinates                   = [CLLocationCoordinate2D]()
    var longitude                           = ""
    var positionString                      = ""
    var ranAtLeastOnce                      = false
    var running: Bool?                      = false
    var timer                               = Timer()
    var timerValue: TimeInterval            = 2.0
    var velString                           = ""
    
    var altitude                            = "" {
        didSet{
            altitudeInMiles = Constants.numberFormatter.string(from: NSNumber(value: Double(altitude)! * Constants.kilometersToMiles))!
            altitudeInKm    = Constants.numberFormatter.string(from: NSNumber(value: Double(altitude)!))!
            altString       = "    Altitude: \(altitudeInKm) km  (\(altitudeInMiles) miles)"
        }
    }
    var velocity = "" {
        didSet {
            velocityInMPH = Constants.numberFormatter.string(from: NSNumber(value: Double(velocity)! * Constants.kilometersToMiles))!
            velocityInKmH = Constants.numberFormatter.string(from: NSNumber(value: Double(velocity)!))!
            velString     = "    Velocity: \(velocityInKmH) km/h  (\(velocityInMPH) mph)"
        }
    }
    private var altitudeInKm = "" {
        willSet {
            if let lat = Double(latitude), let lon = Double(longitude) {
                positionString = "    Position: \(CoordinateConversions.decimalCoordinatesToDegMinSec(latitude: lat, longitude: lon, format: Globals.coordinatesStringFormat))"
            } else {
                positionString = Globals.spacer
            }
        }
    }

    
    // MARK: - Outlets
    
    
    @IBOutlet var clearOrbitTrackButton: UIButton!
    @IBOutlet var helpButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var soundtrackMusicButton: UIButton!
    @IBOutlet private var startPrompt: UIButton! {
        didSet {
            startPrompt.setTitle("Tap here to track", for: UIControl.State())
            startPrompt.alpha = 0.0
            startPrompt.center.y -= Constants.animationOffsetY        // hide it and start from this offset when animating its unhiding so it moves down into place
        }
    }
    @IBOutlet var cursor: UIImageView! {
        didSet {
            cursor.isHidden = true
        }
    }
    @IBOutlet var map: MKMapView!
    @IBOutlet private var playButton: UIBarButtonItem!
    @IBOutlet var zoomSliderBackground: UIView! {
        didSet {
            zoomSliderBackground.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            zoomSliderBackground.layer.cornerRadius = 27
            zoomSliderBackground.layer.masksToBounds = true
        }
    }
    @IBOutlet var zoomSlider: UISlider! {
        didSet {
            zoomSlider.setThumbImage(#imageLiteral(resourceName: "GeoThumb2"), for: .normal)
            zoomSlider.setThumbImage(#imageLiteral(resourceName: "GeoThumb2"), for: .highlighted)
        }
    }
    @IBOutlet var zoomFactorLabel: UILabel! {
        didSet {
            zoomFactorLabel.isHidden = true
        }
    }
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!

    @IBOutlet weak var globeScene: SCNView!
    @IBOutlet weak var globeExpandButton: UIButton!
    
    // MARK: - Methods
    
    
    /// Set up rounded top corners for the coordinates label box
    /// - Parameter withTopCorners: True if we want the top to have rounded corners
    func setUpCoordinatesLabel(withTopCorners: Bool) {
        if withTopCorners {
        coordinatesLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        coordinatesLabel.layer.cornerRadius = 10
        coordinatesLabel.layer.masksToBounds = true
        } else {
            coordinatesLabel.layer.cornerRadius = 0
        }
    }
    
    
    private func setUpMap() {
        map.delegate        = self
        map.isPitchEnabled  = true
        map.isRotateEnabled = false
        map.isZoomEnabled   = true
        map.showsScale      = true
    }
    
    
    private func setUpNumberFormatter() {
        Constants.numberFormatter.numberStyle           = NumberFormatter.Style.decimal
        Constants.numberFormatter.maximumFractionDigits = 0
    }
    
    
    private func setUpDateFormatter() {
        dateFormatter?.dateFormat = Globals.outputDateFormatString
    }
    
    
    /// Set up a reference to this view controller. This allows AppDelegate to do stuff on it when it enters background.
    private func setUpAppDelegate() {
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        appDelegate.referenceToViewController = self
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUpAppDelegate()
        setUpDateFormatter()
        setUpNumberFormatter()
        setUpMap()
        setUpEarthGlobeScene(for: globe, in: globeScene, hasTintedBackground: true)                 // Set up Earth model scene
        setUpCoordinatesLabel(withTopCorners: true)                                                 // Set up the coordinates info box
        setUpZoomSlider(usingSavedZoomFactor: true)                                                 // Set up zoom factor using saved zoom factor, rather than default
        setUpDisplayConfiguration()                                                                 // Set up display with map in last-used map type and other display parameters
        setUpSoundTrackMusicPlayer()                                                                // Set up the player for the soundtrack
        SettingsDataModel.restoreUserSettings()                                                                       // Restore user settings
        displayInfoBoxAndLandsatButton(false)                                                       // Start up with map overlay info box and buttons off
        
        justStartedUp = true
        
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
    
    
    /// If app has just started up, then show the start prompt, create the zoom slider ranges and reset the start up flag
    private func animateStartPrompt() {
        
        if justStartedUp && !alreadyAnimatedStartPrompt {
            
            // Animate the startup prompt
            UIView.animate(withDuration: 2.0) {
                self.startPrompt.alpha = 1.00
                self.startPrompt.center.y += Constants.animationOffsetY
            }
            
            createZoomSliderRanges()
            alreadyAnimatedStartPrompt = true
            
        }
        
    }
    
    
    /// Present What's New if app was updated or if the switch is enabled in Settings
    private func showWhatsNewIfNeeded() {
        
        if hasAppBeenUpdated() || Globals.showWhatsNewUponNextStartup {
            self.present(whatsNewViewController, animated: true)
            Globals.showWhatsNewUponNextStartup = false
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        animateStartPrompt()
        showWhatsNewIfNeeded()
        
        map.isZoomEnabled   = Globals.mapScrollingAndZoomIsEnabled
        map.isScrollEnabled = Globals.mapScrollingAndZoomIsEnabled
        
    }
    
    
    /// Copy position information to clipboard
    @IBAction func copyCoordinatesToClipboard(_ sender: Any) {
        guard !positionString.isEmpty else { return }
        
        // Build the string
        let dateAndTime             = (dateFormatter?.string(from: Date(timeIntervalSince1970: Double(atDateAndTime)!)))!
        let part1                   = positionString + Constants.linefeed + altString + Constants.linefeed
        let part2                   = velString + Constants.linefeed + "  Time: " + dateAndTime
        let dataToBeCopiedString    = part1 + part2
        
        UIPasteboard.general.string = dataToBeCopiedString  // Copy to general pasteboard
        
        alert(for: "Current ISS Position" + Constants.linefeed + "Copied to Your Clipboard", message: dataToBeCopiedString)
    }
    
    
    @IBAction func zoomValueChanged(_ sender: UISlider) {

        stopAction()
        
        delay(1.0) {   // Delay 1 sec to make sure we don't violate the API's 1 second rate limit if moving the slider too fast
            Globals.zoomFactorLastValue = sender.value
            self.zoomValueWasChanged = true
            self.timerValue = self.getTimerInterval()
            self.playAction()
        }
        
    }
    
    
    private func playAction() {
        
        if !running! {
            startAction()
        } else {
            stopAction()
        }
        
    }
    
    
    private func startAction() {
        
        timerValue = getTimerInterval()
        startRealTimeTracking()
        
        if !(soundtrackMusicPlayer?.isPlaying)! && soundtrackButtonOn {
            soundtrackMusicPlayer?.play()
        } else {
            soundtrackMusicPlayer?.pause()
        }
        
        running = true
        playButton.image = UIImage(named: TrackingButtonImages.pause, in: nil, compatibleWith: nil)    // While running, change play to pause
        
    }
    
    
    /// This method is also called as a delegate method when the app goes into background or is closed
    func stopAction() {
        
        timer.invalidate()
        
        if running != nil {
            running = false
        }
        
        soundtrackMusicPlayer?.pause()
        playButton?.image = UIImage(named: TrackingButtonImages.play, in: nil, compatibleWith: nil)     // While paused, change pause to play
        
    }
    
    
    /// User tapped the start prompt
    @IBAction private func startPromptButton(_ sender: UIButton) {
        
        playAction()

    }
    
    
    /// User tapped the play button
    @IBAction private func play(_ sender: UIBarButtonItem) {
        
        playAction()
        
    }
    
    
    /// Method to set up and start the tracking process
    private func startRealTimeTracking() {
        
        // Don't leave without doing this!
        defer {
            map.isScrollEnabled = Globals.mapScrollingAndZoomIsEnabled
            map.isZoomEnabled   = Globals.mapScrollingAndZoomIsEnabled
        }
        
        if !running! {
            
            if justStartedUp {                              // If we're just starting up after loading the app
                // Animate prompt hiding by animating alpha going from 1.0 to 0.0
                UIView.animate(withDuration: 1.0) {
                    self.startPrompt.alpha = 0.0
                } // end of animation closure
                
                Globals.showWhatsNewUponNextStartup = false
                justStartedUp = false                       // To keep this code from runing each time the view reappears
            }
            
            locateISS()                                     // Call locateISS once to update screen quickly to current ISS position with current settings
            timerStartup()                                  // Call method to set up a timer

        }
        
    }
    
    
    /// Method to set up the map refresh timer.
    ///
    /// Calls locateISS (selector) at the current timerValue setting.
    private func timerStartup() {
        
        timer = Timer.scheduledTimer(timeInterval: timerValue, target: self, selector: #selector(locateISS), userInfo: nil, repeats: true)
        
    }
    
    
    /// Set timer interval.
    /// Computes timer interval based on the zoom interval.
    /// - Returns: TimeInterval
    private func getTimerInterval() -> TimeInterval {
        
        var timerIntervalToReturn: TimeInterval = Constants.defaultTimerInterval
        
        // We must do the following before returning at some point
        defer {
            
            zoomValueWasChanged = false
            Globals.zoomFactorWasResetInSettings = false
            if Globals.displayZoomFactorBelowMarkerIsOn {
                setupZoomFactorLabel(timerIntervalToReturn)
            }
            
        } // end of deferred code
        
        if (zoomValueWasChanged || Globals.zoomFactorWasResetInSettings) && running! {
            
            timer.invalidate()
            
            if running != nil {
                running = false
            }
            
        }
        
        if Globals.zoomFactorWasResetInSettings {
            createZoomSliderRanges()
            setUpZoomSlider(usingSavedZoomFactor: false)
        }
        
        // Calculate the update interval in seconds, based on the zoom scale and zoom expansion multiplier
        switch zoomSlider.value {
        case zoomInterval[0]..<zoomInterval[1] : timerIntervalToReturn = 1.0
        case zoomInterval[1]..<zoomInterval[2] : timerIntervalToReturn = 2.0
        case zoomInterval[2]..<zoomInterval[3] : timerIntervalToReturn = 3.0
        case zoomInterval[3]..<zoomInterval[4] : timerIntervalToReturn = 4.0
        case zoomInterval[4]..<zoomInterval[5] : timerIntervalToReturn = 5.0
        case zoomInterval[5]...zoomInterval[6] : timerIntervalToReturn = 6.0 
        default : timerIntervalToReturn = Constants.defaultTimerInterval
        }
        
        return timerIntervalToReturn
        
    }
    
    
    /// Set up zoom slider.
    ///
    /// Sets up slider min and max values
    /// - Parameter usingSavedZoomFactor: If true, use the saved zoom factor. Otherwise, use the default value.
    func setUpZoomSlider(usingSavedZoomFactor useSavedZoomFactor: Bool) {

        zoomSlider.maximumValue = Float(zoomSliderMaxValue)
        zoomSlider.minimumValue = Float(zoomSliderMinValue)
        
        if useSavedZoomFactor {
            zoomSlider.value = Globals.zoomFactorLastValue
        } else {
            zoomSlider.value = Float(zoomFactorDefaultValue)
        }
        
    }
    
    
    /// Set the zoom and scale label
    func setupZoomFactorLabel(_ timerInterval: TimeInterval) {
        
        let integerTimerInterval = Int(timerInterval)
        
        zoomFactorLabel.text! = "Scale: \(zoomRangeFactorLabel) \(Constants.linefeed)" + String(format: Constants.zoomFactorStringFormat, round(zoomSlider.value * 100.0) / 100.0) + "\(Constants.linefeed)Interval: \(integerTimerInterval)" + "\(integerTimerInterval > 1 ? " secs." : " sec.")"
        
    }
    
    
    /// Set up zoom slider ranges.
    ///
    /// Sets up an array of slider ranges based on the computed scaling factor.
    private func createZoomSliderRanges() {
        
        zoomInterval = []                                           // first clear out existing intervals
        
        // Create an array of zoom intervals based on the max zoom value and the number of intervals
        zoomInterval.append(Float(zoomSliderMinValue))              // set first element (zoomInterval[0]) to minimum zoom value
        
        for i in 1...Constants.numberOfZoomIntervals {
            zoomInterval.append(Float(zoomSliderMaxValue) * Float(i) / Float(Constants.numberOfZoomIntervals))
        }
        
        if Globals.displayZoomFactorBelowMarkerIsOn {
            setupZoomFactorLabel(timerValue)
        }
        
    }
    
    
    /// Set up the map.
    ///
    /// Sets the map type and associated parameters basedon selector control in Settings. Sets cursor and zoomFactorLabel color to black or white, and coordinatesLabel to red or white depending upon map type.
    func setUpDisplayConfiguration() {
        
        switch Globals.mapTypeSelection {
        
        case 0 :
            
            map.mapType                = .standard
            zoomFactorLabel.textColor  = UIColor.black
            coordinatesLabel.textColor = UIColor.black
            altitudeLabel.textColor    = UIColor.black
            velocityLabel.textColor    = UIColor.black
            cursor.alpha               = 1.0
            zoomFactorLabel.alpha      = 1.0
            copyButton.tintColor       = UIColor.black
            
            // Use appropriate cursor color for light or dark mode when using standard map mode
            if traitCollection.userInterfaceStyle == .light {
                cursor.tintColor = .black
            } else {
                cursor.tintColor = .white
            }
            
            switch Globals.markerType {
            
            case 0 :
                
                cursor.image = UIImage(named: "ISS-New-Marker")
                
            case 1 :
                
                cursor.image = UIImage(named: "center_direction_black")
                
            case 2 :
                
                cursor.image = UIImage(named: "Plus Math Black")
                
            default :
                
                cursor.image = UIImage(named: "ISS-New-Marker")
                
            }
            
        case 1 :
            
            map.mapType                = .satellite
            zoomFactorLabel.textColor  = UIColor.white
            coordinatesLabel.textColor = UIColor.white
            altitudeLabel.textColor    = UIColor.white
            velocityLabel.textColor    = UIColor.white
            cursor.alpha               = 0.90
            zoomFactorLabel.alpha      = 0.90
            copyButton.tintColor       = UIColor.white
            cursor.tintColor           = .white
            
            switch Globals.markerType {
            
            case 0 :
                
                cursor.image = UIImage(named: "ISS-New-Marker")
                
            case 1 :
                
                cursor.image = UIImage(named: "center_direction")
                
            case 2 :
                
                cursor.image = UIImage(named: "Plus Math White")
                
            default :
                
                cursor.image = UIImage(named: "ISS-New-Marker")
                
            }
            
        case 2 :
            
            map.mapType                = .hybrid
            zoomFactorLabel.textColor  = UIColor.white
            coordinatesLabel.textColor = UIColor.white
            altitudeLabel.textColor    = UIColor.white
            velocityLabel.textColor    = UIColor.white
            cursor.alpha               = 0.90
            zoomFactorLabel.alpha      = 0.90
            copyButton.tintColor       = UIColor.white
            cursor.tintColor           = .white
            
            switch Globals.markerType {
            
            case 0 :
                
                cursor.image = UIImage(named: "ISS-New-Marker")
                
            case 1 :
                
                cursor.image = UIImage(named: "center_direction")
                
            case 2 :
                
                cursor.image = UIImage(named: "Plus Math White")
                
            default :
                
                cursor.image = UIImage(named: "ISS-New-Marker")
                
            }
            
        default :
            
            map.mapType                = .satellite
            zoomFactorLabel.textColor  = UIColor.white
            coordinatesLabel.textColor = UIColor.white
            altitudeLabel.textColor    = UIColor.white
            velocityLabel.textColor    = UIColor.white
            cursor.alpha               = 0.90
            zoomFactorLabel.alpha      = 0.90
            copyButton.tintColor       = UIColor.white
            cursor.tintColor           = .white
            
            switch Globals.markerType {
            
            case 0 :
                
                cursor.image = UIImage(named: "ISS-New-Marker")
                
            case 1 :
                
                cursor.image = UIImage(named: "center_direction")
                
            case 2 :
                
                cursor.image = UIImage(named: "Plus Math White")
                
            default :
                
                cursor.image = UIImage(named: "ISS-New-Marker")
                
            }
            
        }
        
    }
      
    
    /// Show map overlay info box and buttons if parameter is true
    func displayInfoBoxAndLandsatButton(_ isOn: Bool) {
        
        if isOn {
            
            coordinatesLabel.isHidden = false
            altitudeLabel.isHidden    = false
            velocityLabel.isHidden    = false
            
        } else {
            
            coordinatesLabel.isHidden = true
            altitudeLabel.isHidden    = true
            velocityLabel.isHidden    = true
            
        }
        
    }

    
    /// Prepare for seque
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let segueInProcess = segue.identifier else { return } // Prevents crash if a segue is unnamed
        
        switch segueInProcess {
        
        case Segues.globeSegue, Segues.segueToFullGlobeFromTabBar : // Stop tracking if Globe segue was selected from either the mini globe or tab bar button
            
            stopAction()
        
        case Segues.passesSegue :                                   // Stop tracking if Passes segue was selected
            
            stopAction()
        
        case Segues.crewSeque :                                     // Stop tracking if Crew segue was selected
            
            stopAction()
        
        case Segues.earthViewSegue :                                // Stop tracking and select live earth view channel
            
            stopAction()
            let navigationController                          = segue.destination as! UINavigationController
            let destinationVC                                 = navigationController.topViewController as! LiveVideoViewController
            destinationVC.channelSelected                     = .liveEarth
            destinationVC.title                               = destinationVC.channelSelected.rawValue
            
        case Segues.NASATVSegue :                                   // Stop tracking and select NASA TV channel
            
            stopAction()
            let navigationController                          = segue.destination as! UINavigationController
            let destinationVC                                 = navigationController.topViewController as! LiveVideoViewController
            destinationVC.channelSelected                     = .nasaTV
            destinationVC.title                               = destinationVC.channelSelected.rawValue
            
        case Segues.settingsSegue :                                 // Keep tracking, set popover arrow to point to middle, below settings button
            
            let navigationController                          = segue.destination as! UINavigationController
            let destinationVC                                 = navigationController.topViewController as! SettingsTableViewController
            destinationVC.settingsButtonInCallingVCSourceView = settingsButton
            
        case Segues.helpSegue :                                     // Keep tracking, set popover arrow to point to middle, below help button
            
            let navigationController                          = segue.destination as! UINavigationController
            let destinationVC                                 = navigationController.topViewController as! HelpViewController
            destinationVC.helpContentHTML                     = UserGuide.helpContentHTML
            destinationVC.helpButtonInCallingVCSourceView     = helpButton
            destinationVC.title                               = "User Guide"
            
        default :
            
            stopAction()
            
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
        
        soundtrackMusicPlayer?.numberOfLoops = -1       // Loop indefinitely
        
    }
    
    
    /// Toggle soundtrack on and off
    @IBAction func toggleMusicSoundtrack(_ sender: UIButton) {
        
        if running! {
            if soundtrackButtonOn {
                soundtrackMusicPlayer?.stop()
            } else {
                soundtrackMusicPlayer?.play()
            }
        }
        
        soundtrackButtonOn.toggle()
        
    }
    
    
    /// Clear the ground track plot line
    @IBAction func clearOrbitGroundTrack(_ sender: UIButton) {

        let alertController = UIAlertController(title: "Clear Ground Track", message: "Are you sure you wish to" + Constants.linefeed + "clear the ground track?" + Constants.linefeed + Constants.linefeed + "Note: You can turn off the" + Constants.linefeed + "ground track line in Settings.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Clear", style: .destructive) { (clearIt) in
            self.map.removeOverlays(self.map.overlays)  // Need to remove all MKMap overlays, as multitple polylines are overlayed on the map as location is updated
            }
        )
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
        stopAction()
        
    }

    
}
