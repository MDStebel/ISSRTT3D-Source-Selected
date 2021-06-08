//
//  CrewMembersTableViewController.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 2/22/16.
//  Copyright © 2016-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


class CrewMembersTableViewController: UITableViewController, TableAnimatable {
    
    // MARK: - Launch spacecraft enum
    
    private enum LaunchVehicles: String {
        
        case soyuz      = "Soyuz"
        case crewDragon = "Crew Dragon"
        case starliner  = "Starliner"
        
        var spacecraftImages: UIImage {
            switch self {
            case .soyuz      :
                return #imageLiteral(resourceName: "Soyuz-2")
            case .crewDragon :
                return #imageLiteral(resourceName: "spacex-dragon-spacecraft-1")
            case .starliner  :
                return #imageLiteral(resourceName: "astronaut_filled_Grey")
            }
        }
    }
    
    // MARK: - Properties
    
    /// Constants
    private struct Constants {
        static let bioBackupURLString           = "https://www.issrtt.com/issrtt-astronaut-bio-not-found"   // Backup URL is used if a bio URL is not returned in the JSON file
        static let crewAPIEndpointURLString     = "https://issrttapi.com/crew.json"                         // API endpoint
        static let customCellIdentifier         = "crewMemberCell"
        static let fontForTitle                 = Theme.nasa
        static let newLine                      = "\n"
        static let segueToFullBio               = "segueToFullBio"
        static let segueToHelpFromCrew          = "segueToHelpFromCrew"
        static let spacecraftID                 = "International Space Station"
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
       
    // MARK: - Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setUpRefreshControl()
        
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
        
//        // Use appropriate background color for light or dark mode
//        if traitCollection.userInterfaceStyle == .light {
//            crewTable.backgroundColor = UIColor(named: "Alternate Background")
//        } else {
//            crewTable.backgroundColor = UIColor(named: "Flipside View Background Color")
//        }
        
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
            
            if let urlContent = data {
                
                // Parse data and if successful (not nil) copy crew member names to currentCrew string array and fill the table
                if let parsedCrewMembers = Astronaut.parseCurrentCrew(from: urlContent) {
                    
                    weakSelf?.currentCrew = parsedCrewMembers
                    
                    // Remove non-ISS people
                    let ISSCrewOnly = weakSelf?.currentCrew?.filter { $0.spaceCraft == Constants.spacecraftID }
                    
                    // Sort by name and then by title
                    weakSelf?.currentCrew = ISSCrewOnly?.sorted {$0.name < $1.name}
                    weakSelf?.currentCrew?.sort() {$0.title < $1.title}
                    
                    weakSelf?.currentCrewSize = (weakSelf?.currentCrew!.count)!
                    
                    DispatchQueue.main.async {
                        weakSelf?.spinner.stopAnimating()
                        weakSelf?.refreshControl?.endRefreshing()
                        weakSelf?.animate(table: self.crewTable)
                        self.promptLabel.text = "\(self.currentCrewSize) current crew members\n\(Constants.tapAnyCrewMemberPromptText)"
                    }
                    
                    self.getCurrentCrewMembersAlreadyRun = true
                    
                } else {
                    
                    DispatchQueue.main.async {
                        weakSelf?.spinner.stopAnimating()
                        weakSelf?.refreshControl?.endRefreshing()
                        weakSelf?.alert(for: "Can't get ISS crew info", message: "Tap Done, wait a few minutes, then try again")
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
        
        alert(for: "\(currentCrewSize) ISS Crew Members\nCopied to Your Clipboard", message: crewListString)
        
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
            
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.topViewController as! HelpViewController
            destinationVC.helpContentHTML = UserGuide.crewHelp 
            destinationVC.helpButtonInCallingVCSourceView = navigationController.navigationBar
            destinationVC.title = helpTitle
            
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
    
    
    // Get astronaut's image, if available
    private func getAstronautImage(forCell index: Int) -> UIImage? {
        
        var imageToReturn: UIImage? = nil
        
        if let imageURL = URL(string: currentCrew![index].image), let astonautImageData = try? Data(contentsOf: imageURL) {
            imageToReturn = UIImage(data: astonautImageData)
        }
        
        return imageToReturn
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> AstronautTableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.customCellIdentifier, for: indexPath) as! AstronautTableViewCell   // Custom cell class
        cell.backgroundColor = UIColor.lightGray.withAlphaComponent(Theme.cellBackgroundColorAlpha)
        
        if currentCrewSize > 0 {
            
            let row                        = indexPath.row
            
            cell.astronautImage.image      = getAstronautImage(forCell: row) ?? placeholderImage
            
            let name                       = currentCrew![row].name
            let flag                       = currentCrew![row].flag
            let title                      = currentCrew![row].title
            let mission                    = currentCrew![row].mission
            let launchDate                 = currentCrew![row].launchDateFormatted
            let vehicle                    = currentCrew![row].launchVehicle
            let daysInSpace                = currentCrew![row].numberOfDaysInSpace()
            
            cell.astronautName.text        = name + Globals.spacer + flag
            
            // Get launch spacecraft watermark image using vehicle name
            let spacecraft                 = LaunchVehicles(rawValue: vehicle) ?? .crewDragon
            cell.spacecraftWatermark.image = spacecraft.spacecraftImages
            
            // Build string containing the basic crew member data
            cell.astronautInfo.text        = "\(title)\n\(mission)\n\(launchDate)\n\(vehicle)\n\(daysInSpace)"
            
        }
        
        return cell
        
    }
    
    
    //  If user scrolls the table and the short bio is presented, recenter the pop-up to keep the pop-up centered.
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
    
    
    // This delegate will display the detail view if the cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        centerPopover()
        
        let row                                         = indexPath.row
        let startOfLabelText                            = currentCrew![row].name + Globals.spacer
        let flagImageURLString                          = currentCrew![row].flag 
        
        crewMemberDetailView.shortBioName?.text         = startOfLabelText + flagImageURLString
        crewMemberDetailView.shortBioInforomation?.text = currentCrew?[row].shortBioBlurb ?? "No brief bio is available."
        crewMemberDetailView.twitterHandleURL           = currentCrew?[row].twitter
        
        view.addSubview(crewMemberDetailView)
        
    }
    
    
    // Return the cell height for the cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return Constants.tableRowSize
        
    }
    
}
