//
//  PassesTableViewController.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 3/16/16.
//  Copyright © 2016-2024 ISS Real-Time Tracker. All rights reserved.
//

import UIKit
import EventKit
import CoreLocation

class PassesTableViewController: UITableViewController, CLLocationManagerDelegate, TableAnimatable {

    // MARK: - Rating System Enum
    
    private enum RatingSystem: Double, CaseIterable {
        case unknown = 100000.0
        case poor    = 100.0
        case fair    = -0.5
        case good    = -1.0
        case better  = -1.5
        case best    = -2.0
        
        var numberOfStars: Int {
            switch self {
            case .unknown: return 0
            case .poor:    return 0
            case .fair:    return 1
            case .good:    return 2
            case .better:  return 3
            case .best:    return 4
            }
        }
    }

    // MARK: - Properties
    
    private typealias completionHandler = (Data) -> ()

    private struct Constants {
        static let altitude                             = 0
        static let apiKey                               = ApiKeys.passesApiKey
        static let customCellIdentifier                 = "OverheadTimesCell"
        static let deg                                  = "°"
        static let endpointForPassesAPI                 = ApiEndpoints.passesAPIEndpoint
        static let fontForTitle                         = Theme.nasa
        static let minObservationTime                   = 300
        static let newLine                              = Globals.newLine
        static let noRatingStar                         = #imageLiteral(resourceName: "star-unfilled")
        static let ratingStar                           = #imageLiteral(resourceName: "star")
        static let segueToHelpFromPasses                = "segueToHelpFromPasses"
        static let unknownRatingStar                    = #imageLiteral(resourceName: "unknownRatingStar")
    }

    private var ISSlocationManager: CLLocationManager!
    private var dateFormatterForDate = DateFormatter()
    private var dateFormatterForTime = DateFormatter()
    private var helpTitle = "Passes Help"
    private var numberOfDays = 1
    private var numberOfOverheadTimesActuallyReported = 0
    private var overheadTimesList = [Passes.Pass]()
    private var rating = 0
    private var station: StationsAndSatellites = .iss {
        didSet {
            getStationID(for: station)
        }
    }
    private var stationID = ""
    private var stationImage: UIImage? = nil
    private var stationName = ""
    private var userCurrentCoordinatesString = ""
    private var userLatitude = 0.0
    private var userLongitude = 0.0
    private var stationSelectionButton: UIImage {
        UIImage(systemName: "target")!
    }

    // Change status bar to light color for this VC
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - Outlets
    
    @IBOutlet private var overheadTimes: UITableView!
    @IBOutlet private var promptLabel: UILabel! {
        didSet {
            promptLabel.text = "Getting your location..."
            promptLabel.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            promptLabel.layer.cornerRadius = Theme.cornerRadius
            promptLabel.layer.masksToBounds = true
        }
    }
    @IBOutlet private var spinner: UIActivityIndicatorView! {
        didSet {
            spinner.hidesWhenStopped = true
        }
    }
    @IBOutlet private weak var selectTarget: UIBarButtonItem! {
        didSet {
            selectTarget.image = stationSelectionButton
        }
    }
    @IBOutlet private weak var changeNumberOfDaysButton: UIBarButtonItem!

    // MARK: - Methods
    
    private func getStationID(for station: StationsAndSatellites) {
        selectTarget.image = stationSelectionButton
        stationID = station.satelliteNORADCode
        stationImage = station.satelliteImage
        stationName = station.satelliteName
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
        super.viewWillAppear(animated)
        setNavigationBarAppearance()
    }

    private func setNavigationBarAppearance() {
        let titleFontSize = Theme.navigationBarTitleFontSize
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = UIColor(named: Theme.tint)
        barAppearance.titleTextAttributes = [
            .font: UIFont(name: Constants.fontForTitle, size: titleFontSize) as Any,
            .foregroundColor: UIColor.white
        ]
        navigationItem.standardAppearance = barAppearance
        navigationItem.scrollEdgeAppearance = barAppearance
    }

    private func setUpRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor(named: Theme.tint)
        if let refreshingFont = UIFont(name: Constants.fontForTitle, size: 12.0) {
            let attributes = [
                NSAttributedString.Key.font: refreshingFont,
                .foregroundColor: UIColor.white
            ]
            refreshControl?.attributedTitle = NSAttributedString(string: "Updating passes...", attributes: attributes)
        }
        refreshControl?.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
    }

    @objc private func refreshTable(_ sender: Any) {
        restartGettingUserLocation()
    }

    private func setUpLocationManager() {
        ISSlocationManager = CLLocationManager()
        ISSlocationManager.delegate = self
        ISSlocationManager.desiredAccuracy = kCLLocationAccuracyBest
        ISSlocationManager.requestWhenInUseAuthorization()
    }

    private func startGettingLocations() {
        ISSlocationManager.startUpdatingLocation()
    }

    private func restartGettingUserLocation() {
        startGettingLocations()
    }

    @IBAction private func changeNumberOfDaysThisTimeOnlyAndRefreshPasses(_ sender: UIBarButtonItem) {
        noPasesPopup(withTitle: "Change Number of Days", withStyleToUse: .actionSheet)
    }

    private func noPasesPopup(withTitle title: String, withStyleToUse usingStyle: UIAlertController.Style) {
        let alertController = UIAlertController(
            title: title,
            message: "Change number of days for this time only by selecting below, or change for next time in Settings",
            preferredStyle: usingStyle
        )

        alertController.addAction(UIAlertAction(title: "Back", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        })

        for i in 0..<Int(Passes.numberOfDaysDictionary.count) {
            alertController.addAction(UIAlertAction(title: "\(Passes.numberOfDaysDictionary[i]!) days", style: .default) { _ in
                self.numberOfDays = Int(Passes.numberOfDaysDictionary[i]!)!
                self.restartGettingUserLocation()
            })
        }

        alertController.addAction(UIAlertAction(title: "Select a Target", style: .default) { _ in
            self.switchStationPopup(withTitle: "Select a Target", withStyleToUse: .actionSheet)
        })

        if usingStyle == .actionSheet {
            alertController.popoverPresentationController?.barButtonItem = changeNumberOfDaysButton
        }

        present(alertController, animated: true, completion: nil)
    }

    @IBAction private func changeStation(_ sender: UIBarButtonItem) {
        switchStationPopup(withTitle: "Select a Target", withStyleToUse: .actionSheet)
    }

    private func switchStationPopup(withTitle title: String, withStyleToUse usingStyle: UIAlertController.Style) {
        let alertController = UIAlertController(
            title: title,
            message: "Select a satellite target for pass predictions",
            preferredStyle: usingStyle
        )

        alertController.addAction(UIAlertAction(title: "Back", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        })

        for target in [StationsAndSatellites.iss, StationsAndSatellites.tss, StationsAndSatellites.hst] {
            alertController.addAction(UIAlertAction(title: "\(target.satelliteName)", style: .default) { _ in
                self.station = target
                self.restartGettingUserLocation()
            })
        }

        if usingStyle == .actionSheet {
            alertController.popoverPresentationController?.barButtonItem = selectTarget
        }

        present(alertController, animated: true, completion: nil)
    }

    private func decodeJSONPasses(withData data: Data) {
        let decoder = JSONDecoder()
        do {
            let passesDataSet = try decoder.decode(Passes.self, from: data)
            handlePassesDataSet(passesDataSet)
        } catch {
            handleDecodingError()
        }
    }

    private func handlePassesDataSet(_ passesDataSet: Passes) {
        numberOfOverheadTimesActuallyReported = passesDataSet.info.passescount
        if numberOfOverheadTimesActuallyReported > 0 {
            overheadTimesList = passesDataSet.passes
            updateUIForSuccessfulFetch()
        } else {
            updateUIForNoPasses()
        }
    }

    private func updateUIForSuccessfulFetch() {
        DispatchQueue.main.async { [weak self] in
            self?.spinner.stopAnimating()
            self?.refreshControl?.endRefreshing()
            self?.animate(table: self!.overheadTimes)
            self?.userCurrentCoordinatesString = CoordinateConversions.decimalCoordinatesToDegMinSec(
                latitude: self?.userLatitude ?? 0,
                longitude: self?.userLongitude ?? 0,
                format: Globals.coordinatesStringFormat
            )
            self?.promptLabel.text = "\(self?.numberOfOverheadTimesActuallyReported ?? 0) \(self?.numberOfOverheadTimesActuallyReported ?? 0 > 1 ? "\(self?.station.satelliteName ?? "") passes" : "\(self?.station.satelliteName ?? "") pass") found over next \(self?.numberOfDays ?? 0) days\nYour location: \(self?.userCurrentCoordinatesString ?? "")\nTap a pass to add alert to your calendar"
        }
    }

    private func updateUIForNoPasses() {
        DispatchQueue.main.async { [weak self] in
            self?.spinner.stopAnimating()
            self?.refreshControl?.endRefreshing()
            self?.promptLabel.text = "No visible passes for the next \(self?.numberOfDays ?? 0) days"
            self?.noPasesPopup(withTitle: "No \(self?.station.satelliteName ?? "") Passes Found", withStyleToUse: .alert)
        }
    }

    private func handleDecodingError() {
        DispatchQueue.main.async { [weak self] in
            self?.spinner.stopAnimating()
            self?.refreshControl?.endRefreshing()
            self?.promptLabel.text = "No visible passes for the next \(self?.numberOfDays ?? 0) days"
            self?.noPasesPopup(withTitle: "No \(self?.station.satelliteName ?? "") Passes Found", withStyleToUse: .alert)
        }
    }

    private func getISSOverheadtimes(for station: StationsAndSatellites, then completionHandler: @escaping completionHandler) {
        updateUIForFetchingData(for: station)

        guard let URLRequest = createAPIRequestURL(for: station) else { return }

        fetchData(from: URLRequest, completionHandler: completionHandler)
    }

    private func updateUIForFetchingData(for station: StationsAndSatellites) {
        DispatchQueue.main.async { [weak self] in
            self?.spinner.startAnimating()
            self?.promptLabel.text = "Computing \(station.satelliteName) passes for next \(self?.numberOfDays ?? 0) days"
        }
    }

    private func createAPIRequestURL(for station: StationsAndSatellites) -> URL? {
        let URLrequestString = "\(Constants.endpointForPassesAPI)\(stationID)/\(userLatitude)/\(userLongitude)/\(Constants.altitude)/\(numberOfDays)/\(Constants.minObservationTime)/&apiKey=\(Constants.apiKey)"
        return URL(string: URLrequestString)
    }

    private func fetchData(from URLRequest: URL, completionHandler: @escaping completionHandler) {
        let getPassesDataFromAPI = URLSession.shared.dataTask(with: URLRequest) { [weak self] (data, response, error) in
            if let dataReturned = data {
                completionHandler(dataReturned)
            } else {
                self?.handleConnectionError()
            }
        }
        getPassesDataFromAPI.resume()
    }

    private func handleConnectionError() {
        DispatchQueue.main.async { [weak self] in
            self?.spinner.stopAnimating()
            self?.refreshControl?.endRefreshing()
            self?.cannotConnectToInternetAlert()
            self?.promptLabel.text = "Connection Error"
        }
    }

    private func addEvent(_ passEvent: Passes.Pass) {
        let eventStore = EKEventStore()
        if EKEventStore.authorizationStatus(for: .event) != .fullAccess {
            eventStore.requestFullAccessToEvents { [weak self] (granted, error) in
                if granted {
                    self?.createEvent(eventStore, passEvent: passEvent)
                } else {
                    self?.showCalendarAccessDeniedAlert()
                }
            }
        } else {
            createEvent(eventStore, passEvent: passEvent)
        }
    }

    private func showCalendarAccessDeniedAlert() {
        DispatchQueue.main.async {
            self.alert(for: "Can't create reminder", message: "Access to your calendar was previously denied. Please update your device Settings to change this")
        }
    }

    private func createEvent(_ eventStore: EKEventStore, passEvent: Passes.Pass) {
        let event = EKEvent(eventStore: eventStore)
        event.title = "\(station.satelliteName) Pass Starts"
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.startDate = Date(timeIntervalSince1970: Double(passEvent.startUTC))
        event.endDate = Date(timeIntervalSince1970: Double(passEvent.endUTC))
        event.alarms = [EKAlarm(relativeOffset: -900.0), EKAlarm(relativeOffset: -3600.0)]
        event.location = "Your Location: \(userCurrentCoordinatesString)"
        event.notes = createEventNotes(from: passEvent)
        
        do {
            try eventStore.save(event, span: .thisEvent)
            showEventSavedAlert()
        } catch {
            showEventSaveFailedAlert()
        }
    }

    private func createEventNotes(from passEvent: Passes.Pass) -> String {
        let mag = passEvent.mag
        let startAz = formattedAzimuth(passEvent.startAz)
        let startEl = formattedElevation(passEvent.startEl)
        let maxAz = formattedAzimuth(passEvent.maxAz)
        let maxEl = formattedElevation(passEvent.maxEl)
        let endAz = formattedAzimuth(passEvent.endAz)
        let endEl = formattedElevation(passEvent.endEl)

        return """
        Max Magnitude: \(mag)
        Starting azimuth: \(startAz) \(passEvent.startAzCompass)
        Starting elevation: \(startEl)
        Max azimuth: \(maxAz) \(passEvent.maxAzCompass)
        Max elevation: \(maxEl)
        Ending azimuth: \(endAz) \(passEvent.endAzCompass)
        Ending elevation: \(endEl)
        """
    }

    private func formattedAzimuth(_ azimuth: Double) -> String {
        return String(format: Globals.azimuthFormat, azimuth) + Constants.deg
    }

    private func formattedElevation(_ elevation: Double) -> String {
        return String(format: Globals.elevationFormat, elevation) + Constants.deg
    }

    private func showEventSavedAlert() {
        DispatchQueue.main.async {
            self.alert(for: "Pass Reminded Saved!", message: "A \(self.station.satelliteName) pass reminder was added to your calendar. You'll be alerted 1 hour in advance, and again 15 minutes before it begins.")
        }
    }

    private func showEventSaveFailedAlert() {
        DispatchQueue.main.async {
            self.alert(for: "Failed", message: "Could not add the \(self.station.satelliteName) pass reminder to your calendar")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Constants.segueToHelpFromPasses:
            showHelpViewController(segue)
        default:
            break
        }
    }

    private func showHelpViewController(_ segue: UIStoryboardSegue) {
        DispatchQueue.main.async {
            self.spinner.startAnimating()
        }
        
        let navigationController = segue.destination as! UINavigationController
        let destinationVC = navigationController.topViewController as! HelpViewController
        destinationVC.helpContentHTML = UserGuide.passesHelp
        destinationVC.helpButtonInCallingVCSourceView = navigationController.navigationBar
        destinationVC.title = helpTitle
        
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
        }
    }

    @IBAction func unwindFromOtherVCs(unwindSegue: UIStoryboardSegue) {}

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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.customCellIdentifier, for: indexPath) as! PassesTableViewCell
        let row = indexPath.row

        if numberOfOverheadTimesActuallyReported > 0 {
            configureCell(cell, with: overheadTimesList[row])
        } else {
            showAlertForNoVisiblePasses()
            clearData(in: cell)
        }

        return cell
    }

    private func configureCell(_ cell: PassesTableViewCell, with pass: Passes.Pass) {
        let mag = pass.mag
        
        cell.passDate.backgroundColor = UIColor(named: Theme.lblBgd)
        cell.passDate.text = dateFormatterForDate.string(from: Date(timeIntervalSince1970: pass.startUTC)) + "\(Constants.newLine)\(Constants.newLine)"
        cell.stationIcon.image = stationImage
        cell.durationLabel.text = "DUR: \(minsAndSecs(from: pass.duration))"
        cell.magnitudeLabel.text = mag != RatingSystem.unknown.rawValue ? "MAG: \(mag)" : "MAG: N/A"
        cell.startTime.text = dateFormatterForTime.string(from: Date(timeIntervalSince1970: pass.startUTC))
        cell.startAz.text = formattedAzimuth(pass.startAz)
        cell.startEl.text = formattedElevation(pass.startEl)
        cell.startComp.text = pass.startAzCompass
        cell.maxTime.text = dateFormatterForTime.string(from: Date(timeIntervalSince1970: pass.maxUTC))
        cell.maxAz.text = formattedAzimuth(pass.maxAz)
        cell.maxEl.text = formattedElevation(pass.maxEl)
        cell.maxComp.text = pass.maxAzCompass
        cell.endTime.text = dateFormatterForTime.string(from: Date(timeIntervalSince1970: pass.endUTC))
        cell.endAz.text = formattedAzimuth(pass.endAz)
        cell.endEl.text = formattedElevation(pass.endEl)
        cell.endComp.text = pass.endAzCompass

        configureRatingStars(for: cell, with: mag)
    }

    private func minsAndSecs(from numberOfSeconds: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .brief
        return formatter.string(from: Double(numberOfSeconds)) ?? " "
    }

    private func configureRatingStars(for cell: PassesTableViewCell, with magnitude: Double) {
        let totalStars = RatingSystem.allCases.count - 2
        if magnitude != RatingSystem.unknown.rawValue {
            let rating = numberOfRatingStars(for: magnitude)
            for star in 0..<totalStars {
                cell.ratingStarView[star].image = star < rating ? Constants.ratingStar : Constants.noRatingStar
                cell.ratingStarView[star].alpha = 1.0
            }
        } else {
            for star in 0..<totalStars {
                cell.ratingStarView[star].image = Constants.unknownRatingStar
                cell.ratingStarView[star].alpha = 0.15
            }
        }
    }

    private func numberOfRatingStars(for magnitude: Double) -> Int {
        switch magnitude {
        case _ where magnitude <= RatingSystem.best.rawValue:
            return RatingSystem.best.numberOfStars
        case _ where magnitude <= RatingSystem.better.rawValue:
            return RatingSystem.better.numberOfStars
        case _ where magnitude <= RatingSystem.good.rawValue:
            return RatingSystem.good.numberOfStars
        case _ where magnitude <= RatingSystem.fair.rawValue:
            return RatingSystem.fair.numberOfStars
        case _ where magnitude == RatingSystem.unknown.rawValue:
            return RatingSystem.unknown.numberOfStars
        default:
            return RatingSystem.poor.numberOfStars
        }
    }

    private func clearData(in cell: PassesTableViewCell) {
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

    private func showAlertForNoVisiblePasses() {
        alert(for: "No Visible Passes", message: "No visible \(station.satelliteName) passes found during the next \(numberOfDays) days")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let passToSave = overheadTimesList[indexPath.row]
        addEvent(passToSave)
    }
}

// MARK: - Location Manager delegate methods
extension PassesTableViewController {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let authStatus = ISSlocationManager.authorizationStatus
        if authStatus != .denied {
            ISSlocationManager.startUpdatingLocation()
        } else {
            handleLocationAccessDenied()
        }
    }

    private func handleLocationAccessDenied() {
        spinner.stopAnimating()
        promptLabel.text = "Access to your location was not granted"

        let alert = UIAlertController(
            title: "Location Access Denied",
            message: "Access to your location was previously denied. Please update your iOS Settings to change this.",
            preferredStyle: .alert
        )

        let goToSettingAction = UIAlertAction(title: "Go to Settings", style: .default) { _ in
            self.openAppSettings()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }

        alert.addAction(goToSettingAction)
        alert.addAction(cancelAction)
        alert.preferredAction = goToSettingAction

        present(alert, animated: true)
    }

    private func openAppSettings() {
        DispatchQueue.main.async {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.first!
        userLatitude = userLocation.coordinate.latitude
        userLongitude = userLocation.coordinate.longitude

        getISSOverheadtimes(for: station, then: decodeJSONPasses)
        ISSlocationManager.stopUpdatingLocation()
    }
}
