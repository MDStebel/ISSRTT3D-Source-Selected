//
//  CrewMembersTableViewController.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 2/22/16.
//  Copyright © 2016-2023 ISS Real-Time Tracker. All rights reserved.
//

import UIKit

class CrewMembersTableViewController: UITableViewController, TableAnimatable {
    
    // MARK: - Properties
    
    /// Constants
    private struct Constants {
        static let bioBackupURLString           = ApiEndpoints.crewBioBackupURL   // Backup URL is used if a bio URL is not returned in the JSON file
        static let crewAPIEndpointURLString     = ApiEndpoints.crewAPIEndpoint    // API endpoint
        static let customCellIdentifier         = "crewMemberCell"
        static let fontForTitle                 = Theme.nasa
        static let newLine                      = Globals.newLine
        static let segueToFullBio               = "segueToFullBio"
        static let segueToHelpFromCrew          = "segueToHelpFromCrew"
        static let tableRowSize: CGFloat        = 180
        static let tapAnyCrewMemberPromptText   = "Tap a crew member for bios & tweets"
        static let updatingDataPromptText       = "Updating crew data..."
    }
    
    private var currentCrew: [Astronaut]?       = []
    private var currentCrewSize                 = 0
    private var getCurrentCrewMembersAlreadyRun = false
    private var helpTitle                       = "Crew Help"
    private var index                           = 0
    private var lastIndex                       = 0
    private var station: StationsAndSatellites  = .iss {
        didSet{
            getStationID(for: station)
        }
    }
    private var stationID                               = ""
    private var stationImage: UIImage?                  = nil
    private var stationName                             = ""
    private var stationSelectionButton: UIImage {
        UIImage(systemName: "target")!
    }
    
    /// Placeholder image to use if there's no image for an astronaut returned by the API call
    private let placeholderImage                = #imageLiteral(resourceName: "astronaut_filled_Grey")
    
    // Change status bar to light color for this VC
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet private var crewTable: UITableView!
    @IBOutlet var helpButton: UIBarButtonItem!
    @IBOutlet private var spinner: UIActivityIndicatorView! {
        didSet {
            spinner.hidesWhenStopped = true
        }
    }
    @IBOutlet var crewMemberDetailView: CrewMemberDetailView!
    @IBOutlet var promptLabel: UILabel! {
        didSet {
            promptLabel.text = Constants.updatingDataPromptText
            promptLabel.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            promptLabel.layer.cornerRadius = 27
            promptLabel.layer.masksToBounds = true
        }
    }
    @IBOutlet private weak var selectTarget: UIBarButtonItem!{
        didSet {
            selectTarget.image = stationSelectionButton
        }
    }
    
    
    // MARK: - Methods
    
    /// Get  NORAD ID, name, and icon to use in background for selected target satellite/space station
    /// - Parameter station: Station selector value.
    private func getStationID(for station: StationsAndSatellites) {
        
        selectTarget.image     = stationSelectionButton
        stationID              = station.satelliteNORADCode
        stationImage           = station.satelliteImage
        stationName            = station.satelliteName
        if stationName == "ISS" {
            stationName = "International Space Station"     // We're using the long name for ISS here
        }

    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        getStationID(for: station)
        setUpRefreshControl()
        
    } 
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Set navigation and status bar font and color to our Theme
        let titleFontSize                   = Theme.navigationBarTitleFontSize
        let barAppearance                   = UINavigationBarAppearance()
        barAppearance.backgroundColor       = UIColor(named: Theme.tint)
        barAppearance.titleTextAttributes   = [.font : UIFont(name: Constants.fontForTitle, size: titleFontSize) as Any, .foregroundColor : UIColor.white]
        navigationItem.standardAppearance   = barAppearance
        navigationItem.scrollEdgeAppearance = barAppearance
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // If we came here from the map view, get the crew from the API, otherwise, we're returning from the bio viewcontroller, so do nothing.
        if !getCurrentCrewMembersAlreadyRun {
            
            DispatchQueue.global(qos: .userInteractive).async {
                self.getCurrrentCrewMembers()
            }
            
        }
        
    }
    
    
    /// Set up refresh contol to allow pull-to-refresh in table view
    private func setUpRefreshControl() {
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor(named: Theme.tint)
        
        if let refreshingFont = UIFont(name: Constants.fontForTitle, size: 12.0) {
            let attributes = [NSAttributedString.Key.font: refreshingFont, .foregroundColor: UIColor.white]
            refreshControl?.attributedTitle = NSAttributedString(string: Constants.updatingDataPromptText, attributes: attributes )
        }
        
        // Configure refresh control
        refreshControl?.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
        
    }
    
    
    /// Selector for refresh control
    @objc func refreshTable(_ sender: Any) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.getCurrrentCrewMembers()
        }
        
    }
    
    
    /// Method to get current crew data from API
    private func getCurrrentCrewMembers() {
        
        DispatchQueue.main.async {
            self.spinner.startAnimating()
            self.promptLabel.text = Constants.updatingDataPromptText
        }
        
        // Create the session
        let configuration = URLSessionConfiguration.ephemeral               // Set up an ephemeral session, which uses only RAM and no persistent storage for cache, etc.
        let crewURLSession = URLSession(configuration: configuration)
        crewURLSession.configuration.urlCache = nil                         // Turn off caching
        
        let urlForCurrentCrew = URL(string: Constants.crewAPIEndpointURLString)!
        
        let crewMembersTask = crewURLSession.dataTask(with: urlForCurrentCrew) { [ weak weakSelf = self ] (data, response, error) -> Void in
            
            if let data {
                
                // Parse data and if successful (not nil) copy crew member names to currentCrew string array and fill the table
                if let parsedCrewMembers = Astronaut.parseCurrentCrew(from: data) {
                    
                    weakSelf?.currentCrew = parsedCrewMembers
                    
                    // Select only crew members from the target space station
                    let selectedTargetStationCrewOnly = weakSelf?.currentCrew?.filter { $0.spaceCraft == self.stationName }
                    
                    // Sort the list by name and then by title
                    weakSelf?.currentCrew = selectedTargetStationCrewOnly?.sorted {$0.name < $1.name}
                    weakSelf?.currentCrew?.sort() {$0.title < $1.title}
                    
                    weakSelf?.currentCrewSize = (weakSelf?.currentCrew!.count)!
                    
                    DispatchQueue.main.async {
                        weakSelf?.spinner.stopAnimating()
                        weakSelf?.refreshControl?.endRefreshing()
                        weakSelf?.animate(table: self.crewTable)
                        if weakSelf?.currentCrewSize != 0 {
                            self.promptLabel.text = "\(self.currentCrewSize) current \(self.station.satelliteName) crew members\n\(Constants.tapAnyCrewMemberPromptText)"
                        } else {
                            self.promptLabel.text = "No crew is currently onboard \(self.station.satelliteName)"
                        }
                    }
                    
                    self.getCurrentCrewMembersAlreadyRun = true
                    
                } else {
                    
                    DispatchQueue.main.async {
                        weakSelf?.spinner.stopAnimating()
                        weakSelf?.refreshControl?.endRefreshing()
                        weakSelf?.alert(for: "Can't get crew data", message: "Tap Done, wait a few minutes, then try again")
                    }
                }
                
            } else {
                
                DispatchQueue.main.async {
                    weakSelf?.spinner.stopAnimating()
                    weakSelf?.refreshControl?.endRefreshing()
                    weakSelf?.cannotConnectToInternetAlert()
                }
            }
        }
        
        // Start task
        crewMembersTask.resume()
        
    }
    
    
    /// Copy crew names to clipboard
    @IBAction private func copyCurrentCrewNamesToClipboard(_ sender: UIBarButtonItem) {
        
        guard currentCrew != nil else { return }
        
        var crewListString = ""
        for crewMember in currentCrew! {
            crewListString += crewMember.description + Constants.newLine
        }
        UIPasteboard.general.string = crewListString                                      // Copy to general pasteboard
        
        alert(for: "\(currentCrewSize) \(self.station.satelliteName) Crew Members\nCopied to Your Clipboard", message: crewListString)
        
    }
      

    /// Build a label with leading text followed by an image and return as an attributed string
    /// - Parameters:
    ///   - startOfText: String to add image to
    ///   - endingWithImageAtURL: URL of image
    /// - Returns: Label with image
    private func createStringWithRichContent(starting startOfText: String, and endingWithImageAtURL: String) -> NSMutableAttributedString {
        
        // Create an NSMutableAttributedString that we'll append the image to
        let fullString = NSMutableAttributedString(string: startOfText)
        
        // Get image at URL represented by string
        let imageURL = Foundation.URL(string: endingWithImageAtURL)
        
        if let imageData = try? Data(contentsOf: imageURL!) {
            
            let actualImage = UIImage(data: imageData, scale: 2)
            
            // Create the NSTextAttachment with the image
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = actualImage
            
            // Wrap the attachment in its own attributed string so we can append it
            let imageString = NSAttributedString(attachment: imageAttachment)
            
            // Add the NSTextAttachment wrapper at the end of the string
            fullString.append(imageString)
            
        }
        
        return fullString
        
    }
    
    
    /// Prepare for seque
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier != nil else { return }                                     // Prevents crash if a segue is unnamed
        
        switch segue.identifier {
            
        case Constants.segueToHelpFromCrew :
            
            DispatchQueue.main.async {
                self.spinner.startAnimating()
            }
            
            let navigationController                      = segue.destination as! UINavigationController
            let destinationVC                             = navigationController.topViewController as! HelpViewController
            destinationVC.helpContentHTML                 = UserGuide.crewHelp
            destinationVC.helpButtonInCallingVCSourceView = navigationController.navigationBar
            destinationVC.title                           = helpTitle
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
            }
            
        case Constants.segueToFullBio :                                                  // Full bio button was tapped, so set the URL of the bio VC property using the selected row, then segue.
            
            DispatchQueue.main.async {
                self.spinner.startAnimating()
            }
            
            if let crewMember = tableView.indexPathForSelectedRow?.row {                // Prevents crash when returning from full bio and tapping button again because index is undefined.
                index = crewMember
                lastIndex = index
            }
            else {
                index = lastIndex
            }
            
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.topViewController as! AstronautBioViewController
            
            if let bio = currentCrew?[index].bio {
                destinationVC.bioURL = bio
            } else {
                destinationVC.bioURL = Constants.bioBackupURLString
            }
            
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
        dismiss(animated: true, completion: nil)
    }
    
}


// MARK: - Table view delegates

extension CrewMembersTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return currentCrewSize
    
    }
    
    
    /// Get astronaut's image, if available
    /// - Parameter index: Cell index
    /// - Returns: A n optional image
    private func getAstronautImage(forCell index: Int) -> UIImage? {
        
        var imageToReturn: UIImage? = nil
        
        if let imageURL = URL(string: currentCrew![index].image) {
            if let astonautImageData = try? Data(contentsOf: imageURL) {
                
                imageToReturn = UIImage(data: astonautImageData)
                
            }
        }
        
        return imageToReturn
        
    }
    
    @IBAction func changeStation(_ sender: UIBarButtonItem) {
        
        switchStationPopup(withTitle: "Select a Station", withStyleToUse: .actionSheet)
        
    }
    
    
    /// Switch to a different station to get crew data for
    /// - Parameters:
    ///   - title: Pop-up title
    ///   - usingStyle: The alert style
    private func switchStationPopup(withTitle title: String, withStyleToUse usingStyle : UIAlertController.Style) {
        
        let alertController = UIAlertController(title: title, message: "Select a space station for crew data", preferredStyle: usingStyle)
        
        alertController.addAction(UIAlertAction(title: "Back", style: .cancel) { (dontShow) in
            self.dismiss(animated: true, completion: nil)
        })
        
        // Add selection for each of the stations for which we can get crew data
        for target in [StationsAndSatellites.iss, StationsAndSatellites.tss] {
            alertController.addAction(UIAlertAction(title: "\(target.satelliteName)", style: .default) { (choice) in
                self.station = target
                DispatchQueue.global(qos: .userInteractive).async {
                    self.getCurrrentCrewMembers()
                }
            })
        }
        
        if usingStyle == .actionSheet {
            alertController.popoverPresentationController?.barButtonItem = selectTarget
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> AstronautTableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.customCellIdentifier, for: indexPath) as! AstronautTableViewCell   // Custom cell class
        cell.backgroundColor = UIColor.lightGray.withAlphaComponent(Theme.cellBackgroundColorAlpha)
        
        if currentCrewSize > 0 {
            
            let row                        = indexPath.row
            
            cell.astronautImage.image      = getAstronautImage(forCell: row) ?? placeholderImage
            
            let daysInSpace                = currentCrew![row].numberOfDaysInSpace()
            let expedition                 = currentCrew![row].expedition
            let flag                       = currentCrew![row].flag
            let launchDate                 = currentCrew![row].launchDateFormatted
            let mission                    = currentCrew![row].mission
            let name                       = currentCrew![row].name
            let title                      = currentCrew![row].title
            let vehicle                    = currentCrew![row].launchVehicle
            
            cell.astronautName.text        = name + Globals.spacer + flag
            
            // Get launch spacecraft image using vehicle name
            let spacecraft                 = Spacecraft(rawValue: vehicle) ?? .crewDragon
            cell.spacecraftWatermark.image = spacecraft.spacecraftImages
            
            // Build string containing the basic crew member data
            cell.astronautInfo.text        = "\(title)\n\(expedition)\n\(mission)\n\(launchDate)\n\(vehicle)\n\(daysInSpace)"
            
        }
        
        return cell
        
    }
    
    
    /// If user scrolls the table and the short bio is presented, recenter the pop-up to keep the pop-up centered.
    /// - Parameter scrollView: scrollview fpr which this is a delegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        centerPopover()
        
    }
    
    
    private func centerPopover() {
        
        let parentBounds = view.bounds
        let shortBioViewWidth      = crewMemberDetailView.frame.width
        let shortBioViewHeight     = crewMemberDetailView.frame.height
        let xPosition              = parentBounds.midX - shortBioViewWidth / 2.0
        let yPosition              = parentBounds.midY - shortBioViewHeight / 2.0
        crewMemberDetailView.frame = CGRect(x: xPosition, y: yPosition, width: shortBioViewWidth, height: shortBioViewHeight)
        
    }
    
    
    /// This delegate will display the detail view if the cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        centerPopover()
        
        let row                                         = indexPath.row
        let startOfLabelText                            = currentCrew![row].name + Globals.spacer
        let flagImageURLString                          = currentCrew![row].flag 
        
        crewMemberDetailView.shortBioName?.text         = startOfLabelText + flagImageURLString
        crewMemberDetailView.shortBioInforomation?.text = currentCrew?[row].shortBioBlurb ?? "No short bio is available."
        crewMemberDetailView.twitterHandleURL           = currentCrew?[row].twitter
        
        view.addSubview(crewMemberDetailView)
        
    }
    
    
    /// Return the cell height for the cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return Constants.tableRowSize
        
    }
    
}
