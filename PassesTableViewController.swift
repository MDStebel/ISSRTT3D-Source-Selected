//
//  PassesTableViewController.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 3/16/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit
import EventKit
import CoreLocation


class PassesTableViewController: UITableViewController, CLLocationManagerDelegate, TableAnimatable {
    
    
    // MARK: - Rating System Enum
    
    
    /// Defines the passes rating system
    ///
    /// This enum holds the max (i.e., lowest magnitude) values for the respective ratings and returns number of stars for each. Call: var nStars = RatingSystem.good.numberOfStars
    enum RatingSystem: Double, CaseIterable {
        
        case poor   =  100.0
        case fair   = -0.5
        case good   = -1.0
        case better = -1.5
        case best   = -2.0
        
        var numberOfStars: Int {
            switch self {
            case .poor :
                return 0
            case .fair   :
                return 1
            case .good   :
                return 2
            case .better :
                return 3
            case .best   :
                return 4
            }
        }

    }
    
    
    // MARK: - Properties
    
    
    private struct Constants {
        static let segueToHelpFromPasses                = "segueToHelpFromPasses"
        static let fontForTitle                         = Theme.nasa
    }
    
    private let altitude                                = 0
    private let apiKey                                  = "---"                                     // API key
    private let baseURLForOverheadTimes                 = "---"     // API endpoint (new as of Nov 1, 2020)
    private let customCellIdentifier                    = "OverheadTimesCell"
    private let deg                                     = "°"
    private let minObservationTime                      = 300                                                             // In seconds
    private let newLine                                 = "\n"
    private let noRatingStar                            = #imageLiteral(resourceName: "star-unfilled")
    private let ratingStar                              = #imageLiteral(resourceName: "star")
    
    private var dateFormatterForDate                    = DateFormatter()
    private var dateFormatterForTime                    = DateFormatter()
    private var numberOfDays                            = 1
    private var numberOfOverheadTimesActuallyReported   = 0
    private var overheadTimesList                       = [Passes.Pass]()
    private var rating                                  = 0
    private var userCurrentCoordinatesString            = ""
    private var userLatitude                            = 0.0
    private var userLongitude                           = 0.0
    
    private var ISSlocationManager: CLLocationManager!
    
    /// Defines type for completion handler function
    typealias completionHandler = (Data) -> ()
    
    // Change status bar to light color for this VC
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: - Outlets
    
    
    @IBOutlet private var overheadTimes: UITableView!
    @IBOutlet private var promptLabel: UILabel! {
        didSet {
            promptLabel.text = "Getting your location..."
            promptLabel.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            promptLabel.layer.cornerRadius = 27
            promptLabel.layer.masksToBounds = true
        }
    }
    @IBOutlet private var spinner: UIActivityIndicatorView!
    @IBOutlet private var changeNumberOfDaysButton: UIBarButtonItem!
    
    
    // MARK: - Methods
    
    
    private func setupDateFormatter() {
        dateFormatterForDate.dateFormat = Globals.outputDateOnlyFormatString
        dateFormatterForTime.dateFormat = Globals.outputTimeOnlyFormatString
    }
    
    private func getNumberOfDaysOfPassesToReturn() {
        numberOfDays = Int(Passes.numberOfDaysDictionary[Globals.numberOfDaysOfPassesSelectedSegment] ?? String(Globals.numberOfDaysOfPassesDefaultSelectionSegment))!
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        spinner.hidesWhenStopped = true
        setupDateFormatter()
        getNumberOfDaysOfPassesToReturn()
        setupRefreshControl()
        setUpLocationManager()
        checkCLAccess()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        // Set font and attributes for navigation bar
        let titleFontSize = Theme.navigationBarTitleFontSize
        if let titleFont = UIFont(name: Constants.fontForTitle, size: titleFontSize) {
            let attributes = [NSAttributedString.Key.font: titleFont, .foregroundColor: UIColor.white]
            navigationController?.navigationBar.titleTextAttributes = attributes
            navigationController?.navigationBar.barTintColor = UIColor(named: Theme.tint)
        }
        
//        // Use appropriate background color for light or dark mode
//        if traitCollection.userInterfaceStyle == .light {
//            overheadTimes.backgroundColor = UIColor(named: "Alternate Background")
//        } else {
//            overheadTimes.backgroundColor = UIColor(named: "Flipside View Background Color")
//        }
        
    }
    
    
    /// Set up refresh contol to allow pull-to-refresh in table view
    private func setupRefreshControl() {
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor(named: Theme.tint)
        
        if let refreshingFont = UIFont(name: Constants.fontForTitle, size: 12.0) {
            let attributes = [NSAttributedString.Key.font: refreshingFont, .foregroundColor: UIColor.white]
            refreshControl?.attributedTitle = NSAttributedString(string: "Updating passes...", attributes: attributes )
        }
        
        // Configure refresh control
        refreshControl?.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
    
    }
    
    /// Selector for refresh control
    @objc func refreshTable(_ sender: Any) {
        restartGettingUserLocation()
    }
    
        
    /// Set up location manager
    private func setUpLocationManager() {
        
        ISSlocationManager = CLLocationManager()            // Create a CLLocationManager instance to get user's location
        ISSlocationManager.delegate = self
        ISSlocationManager.desiredAccuracy = kCLLocationAccuracyBest
        ISSlocationManager.requestWhenInUseAuthorization()
        
    }
    
    
    /// Check that user has granted ISSRTT access
    private func checkCLAccess() {
        
        if !canGetLocation() {
            
            spinner.stopAnimating()
            promptLabel.text = "Access to your location was not granted"
            
            // Present alert to allow user to go to system Settings to change access tp Location Services
            let alert = UIAlertController(title: "Location Access Denied", message: "Access to your location was previously denied. Please update your iOS Settings to change this.", preferredStyle: .alert)
            
            let goToSettingAction = UIAlertAction(title: "Go to Settings", style: .default) { (action) in
                DispatchQueue.main.async {
                    let url = URL(string: UIApplication.openSettingsURLString)!
                    UIApplication.shared.open(url, options: [:])
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
            alert.addAction(goToSettingAction)
            alert.addAction(cancelAction)
            alert.preferredAction = goToSettingAction
            
            present(alert, animated: true)
            
        }
        
        ISSlocationManager.startUpdatingLocation()          // Get locations
        
    }
    
    
    /// Check authorization to access Location Services
    private func canGetLocation() -> Bool {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse : return true
        case .authorizedAlways : return true
        case .denied : return false
        case .notDetermined : return true
        case .restricted : return false
        @unknown default : return true
        }
        
    }
    
    
    private func restartGettingUserLocation() {
        
        ISSlocationManager.startUpdatingLocation()
        
    }
    
    
    @IBAction func changeNumberOfDaysThisTimeOnlyAndRefreshPasses(_ sender: UIBarButtonItem) {
        
        noPasesPopup(withTitle: "Change Number of Days", withStyleToUse: .actionSheet)
        
    }
    
    
    /// Give user opportunity to change number of days (this run only!) and try again
    private func noPasesPopup(withTitle title: String, withStyleToUse usingStyle : UIAlertController.Style) {
        
        let alertController = UIAlertController(title: title, message: "Change number of days this time only by selecting below, or change for next time in Settings", preferredStyle: usingStyle)
        
        alertController.addAction(UIAlertAction(title: "Back", style: .cancel) { (dontShow) in
            self.dismiss(animated: true, completion: nil)
            }
        )
        
        // Add number-of-days selections from the dictionary
        for i in 0..<Int(Passes.numberOfDaysDictionary.count) {
            alertController.addAction(UIAlertAction(title: "\(Passes.numberOfDaysDictionary[i]!) days", style: .default) { (choice) in
                self.numberOfDays = Int(Passes.numberOfDaysDictionary[i]!)!
                self.restartGettingUserLocation()
                }
            )
        }
        
        if usingStyle == .actionSheet {
            alertController.popoverPresentationController?.barButtonItem = changeNumberOfDaysButton
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    /// Location manager delegate
    func locationManager(_ ISSLocationManager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations.first!
        userLatitude = userLocation.coordinate.latitude
        userLongitude = userLocation.coordinate.longitude
        
        getISSOverheadtimes(then: decodeJSONPasses)
        
        ISSLocationManager.stopUpdatingLocation()   // Now that we have user's location, we don't need it again, so stop updating location
        
    }
    
    
    /// Decode the raw passes in the JSON data
    /// - Parameter data: JSON passes data
    private func decodeJSONPasses(withData data: Data) {
        
        let decoder = JSONDecoder()
        
        do {
            
            let passesDataSet = try decoder.decode(Passes.self, from: data)
            
            numberOfOverheadTimesActuallyReported = passesDataSet.info.passescount
            if numberOfOverheadTimesActuallyReported > 0 {
                // Success!
                overheadTimesList = passesDataSet.passes
                
                DispatchQueue.main.async { [self] in
                    spinner.stopAnimating()
                    refreshControl?.endRefreshing()
                    animate(table: overheadTimes)
                    userCurrentCoordinatesString = CoordinateConversions.decimalCoordinatesToDegMinSec(latitude: userLatitude, longitude: userLongitude, format: Globals.coordinatesStringFormat)
                    promptLabel.text = "\(numberOfOverheadTimesActuallyReported) \(numberOfOverheadTimesActuallyReported > 1 ? "passes" : "pass") over next \(numberOfDays) days from your location:\n\(userCurrentCoordinatesString)\nTap a pass to add a reminder to your calendar"
                }
            } else {
                DispatchQueue.main.async { [self] in
                    spinner.stopAnimating()
                    refreshControl?.endRefreshing()
                    promptLabel.text = "No visible passes for the next \(numberOfDays) days"
                    noPasesPopup(withTitle: "No Passes Found", withStyleToUse: .alert)
                    
                }
            }
        }
        catch {
            DispatchQueue.main.async { [self] in
               spinner.stopAnimating()
               refreshControl?.endRefreshing()
               promptLabel.text = "No visible passes for the next \(numberOfDays) days"
               noPasesPopup(withTitle: "No Passes Found", withStyleToUse: .alert)
            }
        }
        
    }
    
    
    /// Get the ISS passes as JSON from the REST API
    /// - Parameter completionHandler: The function to handle to process the raw data returned
    private func getISSOverheadtimes(then completionHandler: @escaping completionHandler ) {
        
        DispatchQueue.main.async { [self] in
            spinner.startAnimating()
            promptLabel.text = "Computing passes for the next \(numberOfDays) days"
        }
        
        // Create the API URL request from endpoint. If not succesful, then return
        let URLrequestString = baseURLForOverheadTimes + "/\(userLatitude)/\(userLongitude)/\(altitude)/\(numberOfDays)/\(minObservationTime)/&apiKey=\(apiKey)"
        
        guard let URLRequest = URL(string: URLrequestString) else { return }
        
        // Get the data. We need to get data or report connection error
        let getPassesDataFromAPI = URLSession.shared.dataTask(with: URLRequest) { (data, response, error) in
            
            if let dataReturned = data {
                
                completionHandler(dataReturned)
                
            } else {
                
                DispatchQueue.main.async { [self] in
                    spinner.stopAnimating()
                    refreshControl?.endRefreshing()
                    cannotConnectToInternetAlert()
                    promptLabel.text = "Connection Error"
                }
                
            }
            
        }
        
        getPassesDataFromAPI.resume()
        
    }
    
    
    /// This method adds an event to user's calendar if access is granted
    private func addEvent(_ passEvent: Passes.Pass) {
        
        let eventStore = EKEventStore()
        if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event) { [self] (granted, error) -> Void in
                if granted {
                    createEvent(eventStore, passEvent: passEvent)
                } else {
                    DispatchQueue.main.async {
                        alert(for: "Can't create event", message: "Access to your calendar was previously denied. Please update your Settings to change this")
                    }
                }
            }
        } else {
            createEvent(eventStore, passEvent: passEvent)
        }
        
    }
    
    /// Create the calendar event
    /// - Parameters:
    ///   - eventStore: <#eventStore description#>
    ///   - passEvent: <#passEvent description#>
    private func createEvent(_ eventStore: EKEventStore, passEvent: Passes.Pass) {
        
        // Create an event
        let event = EKEvent(eventStore: eventStore)
        event.title = "ISS Pass Starts"
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.startDate = Date(timeIntervalSince1970: Double(passEvent.startUTC))
        event.endDate = Date(timeIntervalSince1970: Double(passEvent.endUTC))
        
        // Set two alarms: one at 20 mins and the other at 60 mins before the pass
        event.alarms = [EKAlarm(relativeOffset: -1200.0), EKAlarm(relativeOffset: -3600.0)]
        
        // Create entries for event location and notes
        event.location = "Your Location: \(userCurrentCoordinatesString)"
        let mag = passEvent.mag
        let startAz = String(format: Globals.azimuthFormat, passEvent.startAz) + deg
        let startEl = String(format: Globals.elevationFormat, passEvent.startEl) + deg
        let maxAz = String(format: Globals.azimuthFormat, passEvent.maxAz) + deg
        let maxEl = String(format: Globals.elevationFormat, passEvent.maxEl) + deg
        let endAz = String(format: Globals.azimuthFormat, passEvent.endAz) + deg
        let endEl = String(format: Globals.elevationFormat, passEvent.endEl) + deg
        event.notes = "Max Magnitude: \(mag)\nStarting azimuth: \(startAz) \(passEvent.startAzCompass)\nStarting elevation: \(startEl)\nMax azimuth: \(maxAz) \(passEvent.maxAzCompass)\nMax elevation: \(maxEl)\nEnding azimuth: \(endAz) \(passEvent.endAzCompass)\nEnding elevation: \(endEl)"
        
        let whichEvent = EKSpan.thisEvent
        do {
            try eventStore.save(event, span: whichEvent)
            DispatchQueue.main.async {
                self.alert(for: "Event Saved!", message: "A pass was added to your calendar. You'll be alerted 1 hour before and again 20 minutes before it starts.")
            }
        } catch {
            DispatchQueue.main.async {
                self.alert(for: "Failed", message: "Could not add a pass to your calendar")
            }
        }
        
    }
    
    
    /// Prepare for seque
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier != nil else { return }                                     // Prevents crash if a segue is unnamed
        
        switch segue.identifier {
        case Constants.segueToHelpFromPasses :
            
            DispatchQueue.main.async {
                self.spinner.startAnimating()
            }
            
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.topViewController as! HelpViewController
            destinationVC.helpContentHTML = UserGuide.passesHelp
            destinationVC.helpButtonInCallingVCSourceView = navigationController.navigationBar
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
            }
            
        default :
            break
        }
        
    }
    
    
    /// Unwind segue
    @IBAction func unwindFromOtherVCs(unwindSegue: UIStoryboardSegue) {
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


//  MARK: - Table extensions
extension PassesTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return numberOfOverheadTimesActuallyReported
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /// Helper function to convert number of seconds into minutes and seconds and return in a string. Parameter numberOfSeconds: time in secondsReturns: string representation of time in minutes and seconds
        func minsAndSecs(from numberOfSeconds: Int) -> String {
            let dateComponentsFormatter = DateComponentsFormatter()
            dateComponentsFormatter.allowedUnits = [.minute, .second]
            dateComponentsFormatter.unitsStyle = .brief
            
            return dateComponentsFormatter.string(from: Double(numberOfSeconds)) ?? " "
        }
        
        
        /// Helper function to get number of stars to display for this pass
        /// - Parameter thisMagnitude: Magnitude of the pass
        /// - Returns: Integer representing the rating stars
        func numberOfRatingStarsFor(thisMagnitude: Double) -> Int {
            
            // Determine the rating based on the magnitude of this pass
            switch thisMagnitude {                                                                            // Now determine number of stars to show
            case _ where thisMagnitude <= RatingSystem.best.rawValue      : rating = RatingSystem.best.numberOfStars
            case _ where thisMagnitude <= RatingSystem.better.rawValue    : rating = RatingSystem.better.numberOfStars
            case _ where thisMagnitude <= RatingSystem.good.rawValue      : rating = RatingSystem.good.numberOfStars
            case _ where thisMagnitude <= RatingSystem.fair.rawValue      : rating = RatingSystem.fair.numberOfStars
            default                                                       : rating = RatingSystem.poor.numberOfStars
            }
            
            return rating
            
        }
        
        
        /// Helper function to clear data displayed in cell
        func clearDataIn(thisCell cell: PassesTableViewCell) {
            cell.passDate.text = ""
            cell.durationLabel.text = ""
            cell.magnitudeLabel.text = ""
            cell.startTime.text = ""
            cell.startAz.text = ""
            cell.startEl.text = ""
            cell.startComp.text = ""
            cell.maxTime.text = ""
            cell.maxAz.text = ""
            cell.maxEl.text = ""
            cell.maxComp.text = ""
            cell.endTime.text = ""
            cell.endAz.text = ""
            cell.endEl.text = ""
            cell.endComp.text = ""
            cell.backgroundColor = UIColor(named: Theme.popupBgd)
            cell.tintColor = UIColor(named: Theme.popupBgd)
            cell.passDate.backgroundColor = UIColor(named: Theme.popupBgd)
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: customCellIdentifier, for: indexPath) as! PassesTableViewCell
        
        if numberOfOverheadTimesActuallyReported > 0 {
            
            // Set date of pass & set date label background color
            cell.passDate.text = dateFormatterForDate.string(from: Date(timeIntervalSince1970: overheadTimesList[indexPath.row].startUTC))
            cell.passDate.backgroundColor = UIColor(ciColor: .green)           // Set the date label background color to green for all cells
            
            // Duration & max magnitude
            cell.durationLabel.text = "DUR: \(minsAndSecs(from: overheadTimesList[indexPath.row].duration))"
            cell.magnitudeLabel.text = "MAG: \(overheadTimesList[indexPath.row].mag)"
            
            // Start of pass data
            cell.startTime.text = dateFormatterForTime.string(from: Date(timeIntervalSince1970: overheadTimesList[indexPath.row].startUTC))
            cell.startAz.text = String(format: Globals.azimuthFormat, overheadTimesList[indexPath.row].startAz) + deg
            cell.startEl.text = String(format: Globals.elevationFormat, overheadTimesList[indexPath.row].startEl) + deg
            cell.startComp.text = String(overheadTimesList[indexPath.row].startAzCompass)
            
            // Maximum elevation data
            cell.maxTime.text = dateFormatterForTime.string(from: Date(timeIntervalSince1970: overheadTimesList[indexPath.row].maxUTC))
            cell.maxAz.text = String(format: Globals.azimuthFormat, overheadTimesList[indexPath.row].maxAz) + deg
            cell.maxEl.text = String(format: Globals.elevationFormat, overheadTimesList[indexPath.row].maxEl) + deg
            cell.maxComp.text = String(overheadTimesList[indexPath.row].maxAzCompass)
            
            // End-of-pass data
            cell.endTime.text = dateFormatterForTime.string(from: Date(timeIntervalSince1970: overheadTimesList[indexPath.row].endUTC))
            cell.endAz.text = String(format: Globals.azimuthFormat, overheadTimesList[indexPath.row].endAz) + deg
            cell.endEl.text = String(format: Globals.elevationFormat, overheadTimesList[indexPath.row].endEl) + deg
            cell.endComp.text = String(overheadTimesList[indexPath.row].endAzCompass)
            
            
            // Show the correct number of rating stars based on the magnitude of the pass
            let mag = overheadTimesList[indexPath.row].mag
            let rating = numberOfRatingStarsFor(thisMagnitude: mag)
            let totalStarsInRatingSystem = RatingSystem.allCases.count-1       // Subtract 1 because there is one less star that actually can show
            for star in 0...(totalStarsInRatingSystem-1) {
                cell.ratingStarView[star].image = star < rating ? ratingStar : noRatingStar
            }
            
        } else {
            
            // If there there's no pass data show alert and clear cells, as any data in the table is invalid
            alert(for: "No Visible Passes", message: "No visible passes were found during the next \(numberOfDays) days")
            clearDataIn(thisCell: cell)
            
        }
        
        return cell
        
    }
    
    
    /// Cell was selected, so add as event to calendar
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Make a copy of the selected pass and create a calendar event for it
        let passToSave = overheadTimesList[indexPath.row]
        addEvent(passToSave)
        
    }
    
}
