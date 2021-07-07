//
//  PassesTableViewController.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 3/16/16.
//  Copyright © 2016-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit
import EventKit
import CoreLocation


class PassesTableViewController: UITableViewController, CLLocationManagerDelegate, TableAnimatable {
    
    // MARK: - Rating System Enum
    
    /// Defines the passes rating system
    ///
    /// This enum holds the max (i.e., lowest magnitude) values for the respective ratings and returns number of stars for each. Call: var nStars = RatingSystem.good.numberOfStars
    private enum RatingSystem: Double, CaseIterable {
        
        case unknown = 100000.0         // A magnitude of this value reported by the API indicates that it is unknown
        case poor    = 100.0            // Let's just consider anything this dim to be the 'poor' limit
        case fair    = -0.5
        case good    = -1.0
        case better  = -1.5
        case best    = -2.0
        
        var numberOfStars: Int {
            switch self {
            case .unknown :
                return 0
            case .poor   :
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
    
    // MARK: - Stations and/or other satellites that we can get pass predictions for
    
    /// Enum holds the NORAD codes for the stations and their corresponding names and images
    private enum StationsAndSatellites: String, CaseIterable {
        
        case ISS    = "25544"
        case TSS    = "48274"
        
        var stationName: String {
            switch self {
            case .ISS :
                return "ISS"
            case .TSS :
                return "TSS"
            }
        }
        
        var selectionButton: UIImage {
            switch self {
            case .ISS :
                return Constants.selectISSButton
            case .TSS :
                return Constants.selectTSSButton
            }
        }
        
        var stationImage: UIImage {
            switch self {
            case .ISS :
                return UIImage(named: Globals.ISSIconFor3DGlobeView)!
            case .TSS :
                return UIImage(named: Globals.TSSIconFor3DGlobeView)!
            }
        }
    }
    
    
    // MARK: - Properties
    
    /// Defines type for completion handler function
    private typealias completionHandler = (Data) -> ()
    
    private struct Constants {
        static let altitude                             = 0
        static let apiKey                               = "BZQB9N-9FTL47-ZXK7MZ-3TLE"                                     // API key
        static let customCellIdentifier                 = "OverheadTimesCell"
        static let deg                                  = "°"
        static let endpointForPassesAPI                 = "https://api.n2yo.com/rest/v1/satellite/visualpasses"           // API endpoint
        static let fontForTitle                         = Theme.nasa
        static let minObservationTime                   = 300                                                             // In seconds
        static let newLine                              = "\n"
        static let noRatingStar                         = #imageLiteral(resourceName: "star-unfilled")
        static let ratingStar                           = #imageLiteral(resourceName: "star")
        static let segueToHelpFromPasses                = "segueToHelpFromPasses"
        static let selectISSButton                      = #imageLiteral(resourceName: "ISS-Selected-3")
        static let selectTSSButton                      = #imageLiteral(resourceName: "TSS-Selected-3")
        static let unknownRatingStar                    = #imageLiteral(resourceName: "unknownRatingStar")
    }
    
    private var ISSlocationManager: CLLocationManager!
    private var dateFormatterForDate                    = DateFormatter()
    private var dateFormatterForTime                    = DateFormatter()
    private var helpTitle                               = "Passes Help"
    private var numberOfDays                            = 1
    private var numberOfOverheadTimesActuallyReported   = 0
    private var overheadTimesList                       = [Passes.Pass]()
    private var rating                                  = 0
    private var station: StationsAndSatellites             = .ISS {
        didSet{
            getStationID(for: station)
        }
    }
    private var stationID                               = ""
    private var stationImage: UIImage?                  = nil
    private var stationName                             = ""
    private var stationSelectionButton                  = Constants.selectISSButton
    private var userCurrentCoordinatesString            = ""
    private var userLatitude                            = 0.0
    private var userLongitude                           = 0.0
    
    // Change status bar to light color for this VC
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet private var overheadTimes: UITableView!
    @IBOutlet private var promptLabel: UILabel! {
        didSet {
            promptLabel.text                = "Getting your location..."
            promptLabel.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            promptLabel.layer.cornerRadius  = Theme.cornerRadius
            promptLabel.layer.masksToBounds = true
        }
    }
    @IBOutlet private var spinner: UIActivityIndicatorView! {
        didSet {
            spinner.hidesWhenStopped = true
        }
    }
    @IBOutlet private weak var selectTarget: UIBarButtonItem!{
        didSet {
            selectTarget.image = stationSelectionButton
        }
    }
    @IBOutlet private weak var changeNumberOfDaysButton: UIBarButtonItem!

    
    // MARK: - Methods
    
    /// Get  NORAD ID, name, and icon to use in background for selected target satellite/space station
    /// - Parameter station: Station selector value.
    private func getStationID(for station: StationsAndSatellites) {
        stationImage           = station.stationImage
        stationName            = station.stationName
        stationID              = station.rawValue
        stationSelectionButton = station.selectionButton
        selectTarget.image     = stationSelectionButton
    }
    
    
    private func setUpDateFormatter() {
        dateFormatterForDate.dateFormat = Globals.outputDateOnlyFormatString
        dateFormatterForTime.dateFormat = Globals.outputTimeOnlyFormatString
    }
    
    private func getNumberOfDaysOfPassesToReturn() {
        numberOfDays = Int(Passes.numberOfDaysDictionary[Globals.numberOfDaysOfPassesSelectedSegment] ?? String(Globals.numberOfDaysOfPassesDefaultSelectionSegment))!
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        getStationID(for: station)
        setUpDateFormatter()
        getNumberOfDaysOfPassesToReturn()
        setUpRefreshControl()
        setUpLocationManager()
        
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

    }
    
    
    /// Set up refresh contol to allow pull-to-refresh in table view
    private func setUpRefreshControl() {
        
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
        
        ISSlocationManager                 = CLLocationManager()                // Create a CLLocationManager instance to get user's location
        ISSlocationManager.delegate        = self
        ISSlocationManager.desiredAccuracy = kCLLocationAccuracyBest
        ISSlocationManager.requestWhenInUseAuthorization()
        
    }
    
    
    /// Start getting locations
    private func startGettingLocations() {

        ISSlocationManager.startUpdatingLocation()                              // Now, we can  get locations
        
    }
    
    
    private func restartGettingUserLocation() {
        
        startGettingLocations()
        
    }

    
    @IBAction func changeNumberOfDaysThisTimeOnlyAndRefreshPasses(_ sender: UIBarButtonItem) {
        
        noPasesPopup(withTitle: "Change Number of Days", withStyleToUse: .actionSheet)
        
    }
    
    
    /// Give user opportunity to change number of days (this run only!) and try again
    /// - Parameters:
    ///   - title: Pop-up title
    ///   - usingStyle: The alert style
    private func noPasesPopup(withTitle title: String, withStyleToUse usingStyle : UIAlertController.Style) {
        
        let alertController = UIAlertController(title: title, message: "Change number of days for this time only by selecting below, or change for next time in Settings", preferredStyle: usingStyle)
        
        alertController.addAction(UIAlertAction(title: "Back", style: .cancel) { (dontShow) in
            self.dismiss(animated: true, completion: nil)
        }
        )
        
        // Add number-of-days selections from the dictionary in the Passes model
        for i in 0..<Int(Passes.numberOfDaysDictionary.count) {
            alertController.addAction(UIAlertAction(title: "\(Passes.numberOfDaysDictionary[i]!) days", style: .default) { (choice) in
                self.numberOfDays = Int(Passes.numberOfDaysDictionary[i]!)!
                self.restartGettingUserLocation()
            }
            )
        }
        
        alertController.addAction(UIAlertAction(title: "Switch stations", style: .default) { (choice) in
            self.switchStationPopup(withTitle: "Change Space Station", withStyleToUse: .actionSheet)
        }
        )
        
        if usingStyle == .actionSheet {
            alertController.popoverPresentationController?.barButtonItem = changeNumberOfDaysButton
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func changeStation(_ sender: UIBarButtonItem) {
        
        switchStationPopup(withTitle: "Change Space Station", withStyleToUse: .actionSheet)
        
    }
    
    
    /// Switch to a different station to get pass predictions for
    /// - Parameters:
    ///   - title: Pop-up title
    ///   - usingStyle: The alert style
    private func switchStationPopup(withTitle title: String, withStyleToUse usingStyle : UIAlertController.Style) {
        
        let alertController = UIAlertController(title: title, message: "Switch to a different space station for pass predictions", preferredStyle: usingStyle)
        
        alertController.addAction(UIAlertAction(title: "Back", style: .cancel) { (dontShow) in
            self.dismiss(animated: true, completion: nil)
        }
        )
        
        // Add selection for each of the stations/satellites for which we can get pass predictions
        for target in StationsAndSatellites.allCases {
            alertController.addAction(UIAlertAction(title: "\(target.stationName)", style: .default) { (choice) in
                self.station = target
                self.restartGettingUserLocation()
            }
            )
        }
        
        if usingStyle == .actionSheet {
            alertController.popoverPresentationController?.barButtonItem = selectTarget
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    /// Decode the raw passes in the JSON data
    /// - Parameter data: JSON passes data
    private func decodeJSONPasses(withData data: Data) {
        let decoder = JSONDecoder()

        do {
            let passesDataSet = try decoder.decode(Passes.self, from: data)

            numberOfOverheadTimesActuallyReported = passesDataSet.info.passescount
            if numberOfOverheadTimesActuallyReported > 0 {
                // Success! So, here's our array of passes
                overheadTimesList = passesDataSet.passes

                DispatchQueue.main.async { [self] in
                    spinner.stopAnimating()
                    refreshControl?.endRefreshing()
                    animate(table: overheadTimes)
                    userCurrentCoordinatesString = CoordinateConversions.decimalCoordinatesToDegMinSec(latitude: userLatitude, longitude: userLongitude, format: Globals.coordinatesStringFormat)
                    promptLabel.text = "\(numberOfOverheadTimesActuallyReported) \(numberOfOverheadTimesActuallyReported > 1 ? "\(station.stationName) passes" : "\(station.stationName) pass") during next \(numberOfDays) days from your location:\n\(userCurrentCoordinatesString)\nTap a pass to add a reminder to your calendar"
                }
            } else {
                DispatchQueue.main.async { [self] in
                    spinner.stopAnimating()
                    refreshControl?.endRefreshing()
                    promptLabel.text = "No visible passes for the next \(numberOfDays) days"
                    noPasesPopup(withTitle: "No \(station.stationName) Passes Found", withStyleToUse: .alert)
                }
            }
        } catch {
            DispatchQueue.main.async { [self] in
                spinner.stopAnimating()
                refreshControl?.endRefreshing()
                promptLabel.text = "No visible passes for the next \(numberOfDays) days"
                noPasesPopup(withTitle: "No \(station.stationName) Passes Found", withStyleToUse: .alert)
            }
        }
    }
    
    
    /// Get the ISS passes as JSON from the REST API
    /// - Parameter completionHandler: The function to handle to process the raw data returned
    private func getISSOverheadtimes(for station: StationsAndSatellites, then completionHandler: @escaping completionHandler ) {
        
        DispatchQueue.main.async { [self] in
            spinner.startAnimating()
            promptLabel.text = "Computing \(station.stationName) passes for next \(numberOfDays) days"
        }
        
        // Create the API URL request from endpoint. If not succesful, then return
        let URLrequestString = Constants.endpointForPassesAPI + "/\(stationID)/\(userLatitude)/\(userLongitude)/\(Constants.altitude)/\(numberOfDays)/\(Constants.minObservationTime)/&apiKey=\(Constants.apiKey)"
        
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
    /// - Parameter passEvent: The pass to add to the calendar
    private func addEvent(_ passEvent: Passes.Pass) {
        
        let eventStore = EKEventStore()
        if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event) { [self] (granted, error) -> Void in
                if granted {
                    createEvent(eventStore, passEvent: passEvent)
                } else {
                    DispatchQueue.main.async {
                        alert(for: "Can't create reminder", message: "Access to your calendar was previously denied. Please update your device Settings to change this")
                    }
                }
            }
        } else {
            createEvent(eventStore, passEvent: passEvent)
        }
        
    }
    
    /// Create the calendar event
    /// - Parameters:
    ///   - eventStore: EventStore to use
    ///   - passEvent: The pass to add to the calendar
    private func createEvent(_ eventStore: EKEventStore, passEvent: Passes.Pass) {
        
        // Create an event
        let event       = EKEvent(eventStore: eventStore)
        event.title     = "\(station.stationName) Pass Starts"
        event.calendar  = eventStore.defaultCalendarForNewEvents
        event.startDate = Date(timeIntervalSince1970: Double(passEvent.startUTC))
        event.endDate   = Date(timeIntervalSince1970: Double(passEvent.endUTC))
        
        // Set two alarms: one at 15 mins and the other at 60 mins before the pass
        event.alarms    = [EKAlarm(relativeOffset: -900.0), EKAlarm(relativeOffset: -3600.0)]      // In seconds
        
        // Create entries for event location
        event.location  = "Your Location: \(userCurrentCoordinatesString)"
        
        // Add notes with viewing details
        let mag         = passEvent.mag
        let startAz     = String(format: Globals.azimuthFormat, passEvent.startAz) + Constants.deg
        let startEl     = String(format: Globals.elevationFormat, passEvent.startEl) + Constants.deg
        let maxAz       = String(format: Globals.azimuthFormat, passEvent.maxAz) + Constants.deg
        let maxEl       = String(format: Globals.elevationFormat, passEvent.maxEl) + Constants.deg
        let endAz       = String(format: Globals.azimuthFormat, passEvent.endAz) + Constants.deg
        let endEl       = String(format: Globals.elevationFormat, passEvent.endEl) + Constants.deg
        event.notes     = "Max Magnitude: \(mag)\nStarting azimuth: \(startAz) \(passEvent.startAzCompass)\nStarting elevation: \(startEl)\nMax azimuth: \(maxAz) \(passEvent.maxAzCompass)\nMax elevation: \(maxEl)\nEnding azimuth: \(endAz) \(passEvent.endAzCompass)\nEnding elevation: \(endEl)"
        
        let whichEvent  = EKSpan.thisEvent
        do {
            try eventStore.save(event, span: whichEvent)
            DispatchQueue.main.async {
                self.alert(for: "Pass Reminded Saved!", message: "A \(self.station.stationName) pass reminder was added to your calendar. You'll be alerted 1 hour in advance, and again 15 minutes before it begins.")
            }
        } catch {
            DispatchQueue.main.async {
                self.alert(for: "Failed", message: "Could not add the \(self.station.stationName) pass reminder to your calendar")
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
            
            let navigationController                        = segue.destination as! UINavigationController
            let destinationVC                               = navigationController.topViewController as! HelpViewController
            destinationVC.helpContentHTML                   = UserGuide.passesHelp
            destinationVC.helpButtonInCallingVCSourceView   = navigationController.navigationBar
            destinationVC.title                             = helpTitle
            
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


//  MARK: - Tableview delegate methods
extension PassesTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return numberOfOverheadTimesActuallyReported
        
    }
    
    
    /// Populate the cell with a card for each pass
    /// - Parameters:
    ///   - tableView: The table view we're using
    ///   - indexPath: Index of the cell
    /// - Returns: Populated cell
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
        func numberOfRatingStars(for thisMagnitude: Double) -> Int {
            // Determine the rating based on the magnitude of this pass
            switch thisMagnitude { // Now determine number of stars to show
            case _ where thisMagnitude <= RatingSystem.best.rawValue   : rating = RatingSystem.best.numberOfStars
            case _ where thisMagnitude <= RatingSystem.better.rawValue : rating = RatingSystem.better.numberOfStars
            case _ where thisMagnitude <= RatingSystem.good.rawValue   : rating = RatingSystem.good.numberOfStars
            case _ where thisMagnitude <= RatingSystem.fair.rawValue   : rating = RatingSystem.fair.numberOfStars
            case _ where thisMagnitude == RatingSystem.unknown.rawValue: rating = RatingSystem.unknown.numberOfStars
            default                                                    : rating = RatingSystem.poor.numberOfStars
            }
            
            return rating
        }
        
        /// Helper function to clear data displayed in cell
        func clearDataIn(thisCell cell: PassesTableViewCell) {
            cell.passDate.text            = ""
            cell.durationLabel.text       = ""
            cell.magnitudeLabel.text      = ""
            cell.startTime.text           = ""
            cell.startAz.text             = ""
            cell.startEl.text             = ""
            cell.startComp.text           = ""
            cell.maxTime.text             = ""
            cell.maxAz.text               = ""
            cell.maxEl.text               = ""
            cell.maxComp.text             = ""
            cell.endTime.text             = ""
            cell.endAz.text               = ""
            cell.endEl.text               = ""
            cell.endComp.text             = ""
            cell.backgroundColor          = UIColor(named: Theme.popupBgd)
            cell.tintColor                = UIColor(named: Theme.popupBgd)
            cell.passDate.backgroundColor = UIColor(named: Theme.popupBgd)
        }
        
        // Set up the cell
        let cell                          = tableView.dequeueReusableCell(withIdentifier: Constants.customCellIdentifier, for: indexPath) as! PassesTableViewCell
        let row                           = indexPath.row
        
        if numberOfOverheadTimesActuallyReported > 0 {
            let mag                       = overheadTimesList[row].mag    // Get the magnitude of this pass, as we'll use it later.
            
            // Set date of pass & set date label background color
            cell.passDate.backgroundColor = UIColor(named: Theme.lblBgd)    // Set the date label background color
            cell.passDate.text            = dateFormatterForDate.string(from: Date(timeIntervalSince1970: overheadTimesList[row].startUTC))
            cell.passDate.text? += "\(Constants.newLine)\(Constants.newLine)"
            
            // Set the image for the cell background watermark
            cell.stationIcon.image        = stationImage
            
            // Duration & max magnitude
            cell.durationLabel.text       = "DUR: \(minsAndSecs(from: overheadTimesList[row].duration))"
            cell.magnitudeLabel.text      = mag != RatingSystem.unknown.rawValue ? "MAG: \(mag)" : "MAG: N/A"
            
            // Start of pass data
            cell.startTime.text           = dateFormatterForTime.string(from: Date(timeIntervalSince1970: overheadTimesList[row].startUTC))
            cell.startAz.text             = String(format: Globals.azimuthFormat, overheadTimesList[row].startAz) + Constants.deg
            cell.startEl.text             = String(format: Globals.elevationFormat, overheadTimesList[row].startEl) + Constants.deg
            cell.startComp.text           = String(overheadTimesList[row].startAzCompass)
            
            // Maximum elevation data
            cell.maxTime.text             = dateFormatterForTime.string(from: Date(timeIntervalSince1970: overheadTimesList[row].maxUTC))
            cell.maxAz.text               = String(format: Globals.azimuthFormat, overheadTimesList[row].maxAz) + Constants.deg
            cell.maxEl.text               = String(format: Globals.elevationFormat, overheadTimesList[row].maxEl) + Constants.deg
            cell.maxComp.text             = String(overheadTimesList[row].maxAzCompass)
            
            // End-of-pass data
            cell.endTime.text             = dateFormatterForTime.string(from: Date(timeIntervalSince1970: overheadTimesList[row].endUTC))
            cell.endAz.text               = String(format: Globals.azimuthFormat, overheadTimesList[row].endAz) + Constants.deg
            cell.endEl.text               = String(format: Globals.elevationFormat, overheadTimesList[row].endEl) + Constants.deg
            cell.endComp.text             = String(overheadTimesList[row].endAzCompass)
            
            // Show the correct number of rating stars based on the magnitude of the pass according the rating system enum
            // If the magnitude is unknown (.unknown) then show the greyed-out stars only
            let totalStarsInRatingSystem = RatingSystem.allCases.count - 2         // Subtract 1 because there are less stars than values in the enum
            if mag != RatingSystem.unknown.rawValue {                              // Only show stars if the rating is NOT unknown
                let rating = numberOfRatingStars(for: mag)
                for star in 0...(totalStarsInRatingSystem - 1) {                   // Less 1 since the index range of stars is from 0...3
                    cell.ratingStarView[star].image = star < rating ? Constants.ratingStar : Constants.noRatingStar
                    cell.ratingStarView[star].alpha = 1.0
                }
            } else {                                                               // Rating is unknown, so show the greyed-out stars
                for star in 0...(totalStarsInRatingSystem - 1) {                   // Less 1 since the index range of stars is from 0...3
                    cell.ratingStarView[star].image = Constants.unknownRatingStar
                    cell.ratingStarView[star].alpha = 0.15
                }
            }
            
        } else {
            // If there there's no passes data show alert and clear cells, as any data in the table is invalid
            alert(for: "No Visible Passes", message: "No visible \(station.stationName) passes found during the next \(numberOfDays) days")
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


// MARK: - Location Manager delegate methods
extension PassesTableViewController {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        let authStatus = ISSlocationManager.authorizationStatus
        let canGetLocation = authStatus != .denied
        if canGetLocation {
            
            ISSlocationManager.startUpdatingLocation()                              // Now, we can get locations
            
        } else {
            
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
                    self.dismiss(animated: true, completion: nil)                   // Return to main screen if user cancels
                }
            }
            
            alert.addAction(goToSettingAction)
            alert.addAction(cancelAction)
            alert.preferredAction = goToSettingAction
            
            present(alert, animated: true)
            
        }
        
    }
    
    
    /// Location manager did update locations delegate
    func locationManager(_ ISSLocationManager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations.first!
        userLatitude     = userLocation.coordinate.latitude
        userLongitude    = userLocation.coordinate.longitude
        
        getISSOverheadtimes(for: station, then: decodeJSONPasses)                   // Get passes from API, then run callback to decode/parse JSON
        
        ISSLocationManager.stopUpdatingLocation()                                   // Now that we have user's location, we don't need it again, so stop updating location
        
    }
    
}
