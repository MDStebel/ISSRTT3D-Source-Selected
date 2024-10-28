//
//  TrackingViewController.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 2/23/2024
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import AVFoundation
import Combine
import MapKit
import SceneKit
import UIKit

class TrackingViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, AVAudioPlayerDelegate, EarthGlobeProtocol {
    
    // MARK: - Types
    
    
    /// Zoom factor ranges and their maximum values
    private enum ZoomFactorRanges: Double {
        typealias RawValue = Double
        
        case fine                             = 3.0
        case small                            = 10.0
        case medium                           = 30.0
        case large                            = 90.0
    }
    
    /// Segue names
    private struct Segues {
        static let crewSeque                  = "segueToCurrentCrew"
        static let globeSegue                 = "segueToFullGlobe"
        static let helpSegue                  = "helpViewSegue"
        static let passesSegue                = "segueToPassTimes"
        static let segueToFullGlobeFromTabBar = "segueToFullGlobeFromTabBar"
        static let settingsSegue              = "segueToSettings"
    }
    
    /// Local constants
    struct Constants {
        static let animationOffsetY: CGFloat  = 90.0
        static let apiKey                     = ApiKeys.issLocationKey
        static let defaultTimerInterval       = 3.0
        static let fontForTitle               = Theme.nasa
        static let generalAPIKey              = ApiKeys.generalLocationKey
        static let generalEndpointString      = ApiEndpoints.generalTrackerAPIEndpoint    // General endpoint
        static let helpTitle                  = "User Guide"
        static let linefeed                   = Globals.newLine
        static let numberFormatter            = NumberFormatter()
        static let numberOfZoomIntervals      = 6
        static let zoomFactorStringFormat     = "Zoom: %2.2f°"
        static let zoomScaleFactor            = 30.0
    }
    
    private struct TrackingButtonImages {
        static let pause                      = "Track-Pause"
        static let play                       = "Track-Play"
    }
    
    private struct SoundtrackButtonImage {
        static let off                        = "music.quarternote.3"
        static let on                         = "music.quarternote.3"
    }
    
    
    // MARK: - Properties
    
    
    // Change status bar to light color for this VC
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // Soundtrack
    let soundtrackFilePathString = Theme.soundTrack
    var soundtrackMusicPlayer: AVAudioPlayer?
    var soundtrackButtonOn: Bool = false {
        didSet {
            if soundtrackButtonOn {
                soundtrackMusicButton.setImage(UIImage(systemName: SoundtrackButtonImage.on), for: .normal)
                soundtrackMusicButton.tintColor = .white
                soundtrackMusicButton.alpha = 1.0
            } else {
                soundtrackMusicButton.setImage(UIImage(systemName: SoundtrackButtonImage.off), for: .normal)
                soundtrackMusicButton.tintColor = .white
                soundtrackMusicButton.alpha = 0.60
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
        max(zoomSliderMaxValue / Constants.zoomScaleFactor, zoomSliderMinFloor)     // Keep minimum value >= to zoomSliderMinFloor
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
     
    var location = CLLocationCoordinate2D()
    var span     = MKCoordinateSpan()
    var region   = MKCoordinateRegion()
    var latDelta: CLLocationDegrees {
        Double(zoomSlider.value)
    }
    var lonDelta: CLLocationDegrees {
        latDelta
    }
       
    private var alreadyAnimatedStartPrompt = false
    private var altitudeInMiles            = ""
    private var justStartedUp              = false
    private var targetID                   = ""
    private var targetImageMap: UIImage?   = StationsAndSatellites.iss.satelliteImageSmall        // Default map marker image
    private var targetImageGlobe: UIImage? = StationsAndSatellites.iss.satelliteImage             // Default globe marker image
    private var targetName                 = ""
    private var velocityInKmH              = ""
    private var velocityInMPH              = ""
    private var zoomInterval               = [Float]()
    private var zoomRangeFactorLabel       = ""
    private var zoomValueWasChanged        = false
    
    var aPolyLine                          = MKPolyline()
    var altString                          = ""
    var atDateAndTime                      = ""
    var coordinates                        = [SatelliteOrbitPosition.Positions]()
    var dateFormatter: DateFormatter?      = DateFormatter()     // String format for zoom factor label. Declared as an optional so we can test for nil in save settings in case it wasn't set before being called
    var globe                              = EarthGlobe()
    var hLat                               = ""
    var hLon                               = ""
    var hubbleLastLat: Float               = 0
    var hubbleLatitude                     = 0.0
    var hubbleLongitude                    = 0.0
    var iLat                               = ""
    var iLon                               = ""
    var issLastLat: Float                  = 0
    var issLatitude                        = 0.0
    var issLongitude                       = 0.0
    var latitude                           = ""
    var listOfCoordinates                  = [CLLocationCoordinate2D]()
    var longitude                          = ""
    var positionString                     = ""
    var ranAtLeastOnce                     = false
    var tLat                               = ""
    var tLon                               = ""
    var tssLastLat: Float                  = 0
    var tssLatitude                        = 0.0
    var tssLongitude                       = 0.0
    var target: StationsAndSatellites      = .iss {
        didSet{
            getTargetID(for: target)
        }
    }
    var running: Bool?                     = false {
        didSet {
            if let isRunning               = running {
                globeStatusLabel?.text     = isRunning ? "Running" : "Not running"
            }
        }
    }
    var timer: AnyCancellable? 
    var timerValue: TimeInterval           = 2.0
    var satelliteCode                      = StationsAndSatellites.iss.satelliteNORADCode   // Get the NORAD code for the default target
    var velString                          = ""
    var altitude               = "" {
        didSet{
            altitudeInMiles    = Constants.numberFormatter.string(from: NSNumber(value: Double(altitude)! * Globals.kilometersToMiles))!
            altitudeInKm       = Constants.numberFormatter.string(from: NSNumber(value: Double(altitude)!))!
            altString          = "    Altitude: \(altitudeInKm) km  (\(altitudeInMiles) mi)"
        }
    }
    var velocity               = "" {
        didSet {
            velocityInMPH      = Constants.numberFormatter.string(from: NSNumber(value: Double(velocity)! * Globals.kilometersToMiles))!
            velocityInKmH      = Constants.numberFormatter.string(from: NSNumber(value: Double(velocity)!))!
            velString          = "    Velocity: \(velocityInKmH) km/h  (\(velocityInMPH) mph)"
        }
    }
    private var altitudeInKm   = "" {
        willSet {
            if let lat         = Double(latitude), let lon = Double(longitude) {
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
    @IBOutlet var altitudeLabel: UILabel!
    @IBOutlet var coordinatesLabel: UILabel!
    @IBOutlet var velocityLabel: UILabel!
    @IBOutlet var copyButton: UIButton!
    @IBOutlet var globeScene: SCNView!
    @IBOutlet var globeExpandButton: UIButton!
    @IBOutlet var globeStatusLabel: UILabel! {
        didSet {
            globeStatusLabel.text = "Not running"
        }
    }
    @IBOutlet var selectTargetButton: UIButton!
    
    
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
        Constants.numberFormatter.numberStyle = NumberFormatter.Style.decimal
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
        SettingsDataModel.restoreUserSettings()                                                     // Restore user settings
        displayInfoBox(false)                                                                       // Start up with map overlay info box and buttons off
        
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
    
    
//    /// Present What's New if app was updated or if the switch is enabled in Settings
//    private func showWhatsNewIfNeeded() {
//        
//        if hasAppBeenUpdated() || Globals.showWhatsNewUponNextStartup {
//            self.present(whatsNewViewController, animated: true)
//            Globals.showWhatsNewUponNextStartup = false
//        }
//        
//    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        animateStartPrompt()
//        showWhatsNewIfNeeded()
        
        map.isZoomEnabled   = Globals.mapScrollingAndZoomIsEnabled
        map.isScrollEnabled = Globals.mapScrollingAndZoomIsEnabled
    }
    
    
    @IBAction func resetGlobe(_ sender: UIButton) {
        
        resetGlobeAction()
    }
    
    
    /// Reset the globe only
    func resetGlobeAction() {
        
        globe = EarthGlobe()
        setUpEarthGlobeScene(for: globe, in: globeScene, hasTintedBackground: true)
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
        
        delay(1.0) {                                        // Delay a bit to make sure we don't violate the API's 1 second rate limit if moving the slider too fast
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
        playButton.image = UIImage(named: TrackingButtonImages.pause, in: nil, compatibleWith: nil)     // While running, change play to pause
    }
    
    
    /// This method is also called as a delegate method when the app goes into background or is closed
    func stopAction() {
        
        timer?.cancel()
        
        if running != nil {
            running = false
        }
        
        soundtrackMusicPlayer?.pause()
        playButton?.image = UIImage(named: TrackingButtonImages.play, in: nil, compatibleWith: nil)     // While paused, change pause icon to play icon
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
                } 
                
                Globals.showWhatsNewUponNextStartup = false
                justStartedUp = false                       // To keep this code from runing each time the view reappears
            }
            
            locateSatellite(for: target)                    // Call once to update screen quickly to current ISS position with current settings
            timerStartup()                                  // Call method to set up a timer
        }
    }
    
    
    /// Get  NORAD ID, name, and icon to use in background for selected target
    /// - Parameter station: Target satellite selector value.
    private func getTargetID(for target: StationsAndSatellites) {
        
        targetID         = target.satelliteNORADCode
        targetName       = target.satelliteName
        targetImageGlobe = target.satelliteImage
        targetImageMap   = target.satelliteImageSmall
    }
    
    
    /// Method to set up the map refresh timer.
    ///
    /// Calls locateSatellites selector at the current timerValue setting.
    private func timerStartup() {
        
        timer = Timer
            .publish(every: timerValue, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.locateSatellite(for: self.target)
            }
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
            
            timer?.cancel()
            
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
    /// - Parameter timerInterval: Time in seconds as a TimeInterval
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
        configureMapType()
        configureLabelsAndButtons()
        configureCursor()
    }

    private func configureMapType() {
        switch Globals.mapTypeSelection {
        case 0:
            map.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic, emphasisStyle: .default)
        case 1:
            map.preferredConfiguration = MKImageryMapConfiguration()
        case 2:
            map.preferredConfiguration = MKHybridMapConfiguration()
        default:
            map.preferredConfiguration = MKImageryMapConfiguration()
        }
    }

    private func configureLabelsAndButtons() {
        let commonTextColor = UIColor.white
        let commonAlpha: CGFloat = 1.0
        zoomFactorLabel.textColor = commonTextColor
        coordinatesLabel.textColor = commonTextColor
        altitudeLabel.textColor = commonTextColor
        velocityLabel.textColor = commonTextColor
        cursor.alpha = commonAlpha
        zoomFactorLabel.alpha = Globals.mapTypeSelection == 0 ? commonAlpha : 0.90
        copyButton.tintColor = commonTextColor
        cursor.tintColor = (Globals.mapTypeSelection == 0 && traitCollection.userInterfaceStyle == .light) ? .black : .white
    }

    private func configureCursor() {
        let imageName: String
        switch Globals.markerType {
        case 0:
            cursor.image = targetImageMap
        case 1:
            imageName = Globals.mapTypeSelection == 0 ? "center_direction" : "center_direction"
            cursor.image = UIImage(named: imageName)
        case 2:
            imageName = Globals.mapTypeSelection == 0 ? "Plus Math White" : "Plus Math White"
            cursor.image = UIImage(named: imageName)
        default:
            cursor.image = targetImageMap
        }
    }
      
    
    /// Show map overlay info box and buttons if isOn parameter is true
    func displayInfoBox(_ isOn: Bool) {
        
        if isOn {
            altitudeLabel.isHidden    = false
            coordinatesLabel.isHidden = false
            velocityLabel.isHidden    = false
        } else {
            altitudeLabel.isHidden    = true
            coordinatesLabel.isHidden = true
            velocityLabel.isHidden    = true
        }
    }

    
    /// Prepare for seque
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else { return }

        switch segueIdentifier {
        case Segues.globeSegue, Segues.segueToFullGlobeFromTabBar, Segues.passesSegue, Segues.crewSeque:
            stopAction()

        case Segues.settingsSegue:
            if let navigationController = segue.destination as? UINavigationController,
               let destinationVC = navigationController.topViewController as? SettingsTableViewController {
                destinationVC.settingsButtonInCallingVCSourceView = settingsButton
            }

        case Segues.helpSegue:
            if let navigationController = segue.destination as? UINavigationController,
               let destinationVC = navigationController.topViewController as? HelpViewController {
                destinationVC.helpContentHTML = UserGuide.helpContentHTML
                destinationVC.helpButtonInCallingVCSourceView = helpButton
                destinationVC.title = Constants.helpTitle
            }

        default:
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
        
        soundtrackButtonOn = false
        soundtrackMusicPlayer?.numberOfLoops = -1       // Loop indefinitely
    }
    
    
    /// Toggle soundtrack on and off
    @IBAction func toggleMusicSoundtrack(_ sender: UIButton) {
        
        if running! {
            if soundtrackButtonOn {
                soundtrackMusicPlayer?.pause()
            } else {
                soundtrackMusicPlayer?.play()
            }
        }
        
        soundtrackButtonOn.toggle()
    }
    
    
    /// Clear the ground track plot line
    @IBAction func clearOrbitGroundTrack(_ sender: UIButton) {
        let alertController = UIAlertController(
            title: "Clear Ground Track",
            message: """
                     Are you sure you wish to
                     clear the ground track?

                     Note: You can turn off the
                     ground track line in Settings.
                     """,
            preferredStyle: .alert
        )
        
        let clearAction = UIAlertAction(title: "Clear", style: .destructive) { _ in
            self.map.removeOverlays(self.map.overlays)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(clearAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
  
    
    @IBAction func switchTarget(_ sender: UIButton) {
        switchStationPopup(withTitle: "Select a Target", usingStyle: .actionSheet)
    }
    
    
    /// Switch to a different station to get pass predictions for
    /// - Parameters:
    ///   - title: Pop-up title
    ///   - usingStyle: The alert style
    private func switchStationPopup(withTitle title: String, usingStyle: UIAlertController.Style) {
        let alertController = UIAlertController(
            title: title,
            message: "Select a satellite target for tracking",
            preferredStyle: usingStyle
        )

        alertController.addAction(UIAlertAction(title: "Back", style: .cancel))

        let targets: [StationsAndSatellites] = [.iss, .tss, .hst]
        for target in targets {
            alertController.addAction(UIAlertAction(title: target.satelliteName, style: .default) { _ in
                self.handleTargetSelection(target)
            })
        }

        if usingStyle == .actionSheet {
            configurePopover(for: alertController)
        }
        
        present(alertController, animated: true)
    }

    
    private func handleTargetSelection(_ selectedTarget: StationsAndSatellites) {
        DispatchQueue.main.async {
            self.stopAction()
            self.delay(1.0) {
                self.zoomValueWasChanged = true
                self.timerValue = self.getTimerInterval()
                self.target = selectedTarget
                self.satelliteCode = selectedTarget.satelliteNORADCode
                self.listOfCoordinates.removeAll()
                self.map.removeOverlays(self.map.overlays)
                self.resetGlobeAction()
                self.startAction()
            }
        }
    }
    

    private func configurePopover(for alertController: UIAlertController) {
        guard let popoverController = alertController.popoverPresentationController else { return }
        popoverController.permittedArrowDirections = .up
        popoverController.sourceView = selectTargetButton
        popoverController.sourceRect = CGRect(
            x: 1.0,
            y: 3.0,
            width: selectTargetButton.bounds.width,
            height: selectTargetButton.bounds.height
        )
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        stopAction()
    }
}
