//
//  SettingsTableViewController.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 2/21/16.
//  Copyright © 2016-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    
    private let buildNumber                 = Globals.buildNumber
    private let copyrightNotice             = Globals.copyrightString
    private let defaultMapType              = 2                           // Hybrid map type is the default
    private let defaultMarkerType           = 0                           // ISS icon marker type is the default
    private let defaultZoomFactor           = 2                           // Medium zoom is the default
    private let urlForRating                = ApiEndpoints.ratingURL
    private let versionNumber               = Globals.versionNumber
    private let websiteURL                  = ApiEndpoints.supportURL
    
    private var dateAndTimeSaved: String?   = ""
    private var helpTitle                   = "Settings Help"
    private var versionAndCopyrightFooter   = ""
    
    private struct Constants {
        static let segueToHelpFromSettings  = "segueToHelpFromSettings"
        static let fontForTitle             = Theme.nasa
    }
    
    /// During segue to this VC, this variable will contain the source view of the settings button
    var settingsButtonInCallingVCSourceView = UIView()
    
    // Change status bar to light color for this VC
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    
    // MARK: - Outlets
    
    
    @IBOutlet private weak var autoRotateGlobeSwitch: UISwitch!
    @IBOutlet private weak var backgroundSelector: UISegmentedControl!
    @IBOutlet private weak var displayGlobeSwitch: UISwitch!
    @IBOutlet private weak var displayZoomFactorBelowMarkerSwitch: UISwitch!
    @IBOutlet private weak var mapTypeSelector: UISegmentedControl!
    @IBOutlet private weak var markerTypeSelector: UISegmentedControl!
    @IBOutlet private weak var showCoordinatesSwitch: UISwitch!
    @IBOutlet private weak var showOrbitGroundTrackLine: UISwitch!
    @IBOutlet private weak var showWhatsNewSwitch: UISwitch!
    @IBOutlet private weak var userMapScrollingEnbleSwitch: UISwitch!
    @IBOutlet private weak var zoomRangeFactorSelector: UISegmentedControl!
    @IBOutlet private weak var numberOfDaysOfPasses: UISegmentedControl! {
        // Set up segment labels from dictionary
        didSet{
            for index in 0..<Passes.numberOfDaysDictionary.count {
                numberOfDaysOfPasses.setTitle(Passes.numberOfDaysDictionary[index], forSegmentAt: index)
            }
        }
    }
    
    
    // MARK: - Methods
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Set the target rect for the popover
        popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection([.up])
        popoverPresentationController?.sourceRect = CGRect(x: 1.00, y: 3.0, width: settingsButtonInCallingVCSourceView.bounds.width, height: settingsButtonInCallingVCSourceView.bounds.height)
        
        Globals.zoomFactorWasResetInSettings   = false
        Globals.globeBackgroundWasChanged = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        setUpSwitchesAndControlsFromSavedSettings()
        
        // Set navigation and status bar font and color to our Theme
        let titleFontSize                   = Theme.navigationBarTitleFontSize
        let barAppearance                   = UINavigationBarAppearance()
        barAppearance.backgroundColor       = UIColor(named: Theme.tint)
        barAppearance.titleTextAttributes   = [.font : UIFont(name: Constants.fontForTitle, size: titleFontSize) as Any, .foregroundColor : UIColor.white]
        navigationItem.standardAppearance   = barAppearance
        navigationItem.scrollEdgeAppearance = barAppearance
    }
    
    
    @IBAction private func mapTypeSelector(_ sender: UISegmentedControl) {
        
        Globals.mapTypeSelection = sender.selectedSegmentIndex
        
    }
    
    
    @IBAction private func showOrbitGroundTrack(_ sender: UISwitch) {
        
        if sender.isOn {
            Globals.orbitGroundTrackLineEnabled = true
        } else {
            Globals.orbitGroundTrackLineEnabled = false
        }
    }
    
    @IBAction private func showGlobe(_ sender: UISwitch) {
        
        if sender.isOn {
            Globals.displayGlobe = true
        } else {
            Globals.displayGlobe = false
        }
    }
    
    @IBAction private func autoRotateGlobeEnabled(_ sender: UISwitch) {
        
        if sender.isOn {
            Globals.autoRotateGlobeEnabled = true
        } else {
            Globals.autoRotateGlobeEnabled = false
        }
    }
    
    
    @IBAction private func showCoordinates(_ sender: UISwitch) {
        
        if sender.isOn {
            Globals.showCoordinatesIsOn = true
        } else {
            Globals.showCoordinatesIsOn = false
        }
    }
    
    
    @IBAction private func displayZoomFactorBelowMarker(_ sender: UISwitch) {
        
        if sender.isOn {
            Globals.displayZoomFactorBelowMarkerIsOn = true
        } else {
            Globals.displayZoomFactorBelowMarkerIsOn = false
        }
    }
    
    
    @IBAction func userMapScrollingEnbleSwitchWasSet(_ sender: UISwitch) {
        
        if sender.isOn {
            Globals.mapScrollingAndZoomIsEnabled = true
        } else {
            Globals.mapScrollingAndZoomIsEnabled = false
        }
    }
    
    
    @IBAction func markerTypeSelected(_ sender: UISegmentedControl) {
        
        Globals.markerType = sender.selectedSegmentIndex
    }
    

    
    @IBAction private func showWhatsNewSwitch(_ sender: UISwitch) {
        
        if sender.isOn {
            Globals.showWhatsNewUponNextStartup = true
        } else {
            Globals.showWhatsNewUponNextStartup = false
        }
    }
    
    
    @IBAction private func zoomRangeFactorSelected(_ sender: UISegmentedControl) {
        
        Globals.zoomRangeFactorSelection = sender.selectedSegmentIndex
        Globals.zoomFactorWasResetInSettings = true
    }
    
    
    @IBAction func backgroundImageWasSelected(_ sender: UISegmentedControl) {

        Globals.globeBackgroundImageSelection = sender.selectedSegmentIndex
        Globals.globeBackgroundWasChanged = true
    }
    
    
    @IBAction private func numberOfPassesWasSelected(_ sender: UISegmentedControl) {
        
        Globals.numberOfDaysOfPassesSelectedSegment = sender.selectedSegmentIndex
    }
    
    
    /// Go to my website for the app
    @IBAction func getSupportButton(_ sender: UIButton) {
        
        if let websiteAddress = URL(string: websiteURL), UIApplication.shared.canOpenURL(websiteAddress) {
            UIApplication.shared.open(websiteAddress, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (success) in })
        }
    }
    
    
    /// Go directly to the reviews tab in the App Store for this app
    @IBAction private func rateMeNow(_ sender: UIButton) {
        
        if let iTunesLinkForRating = URL(string: urlForRating), UIApplication.shared.canOpenURL(iTunesLinkForRating) {
            UIApplication.shared.open(iTunesLinkForRating, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (success) in })   // Replaced deprecated UIApplication.shared.openURL(iTunesLink)
        }
    }

    
    /// Reset all settings to their defaults
    @IBAction private func resetSettings(_ sender: UIBarButtonItem) {
        
        Globals.showCoordinatesIsOn                  = true
        showCoordinatesSwitch.isOn                   = true
        
        Globals.displayZoomFactorBelowMarkerIsOn     = true
        displayZoomFactorBelowMarkerSwitch.isOn      = true
        
        Globals.mapScrollingAndZoomIsEnabled         = false
        userMapScrollingEnbleSwitch.isOn             = false

        Globals.showWhatsNewUponNextStartup          = false
        showWhatsNewSwitch.isOn                      = false
        
        Globals.orbitGroundTrackLineEnabled          = true
        showOrbitGroundTrackLine.isOn                = true
        
        Globals.displayGlobe                         = true
        displayGlobeSwitch.isOn                      = true
        
        Globals.autoRotateGlobeEnabled               = true
        autoRotateGlobeSwitch.isOn                   = true
        
        Globals.mapTypeSelection                     = defaultMapType
        mapTypeSelector.selectedSegmentIndex         = defaultMapType
        
        Globals.zoomRangeFactorSelection             = defaultZoomFactor
        zoomRangeFactorSelector.selectedSegmentIndex = defaultZoomFactor

        Globals.numberOfDaysOfPassesSelectedSegment  = Globals.numberOfDaysOfPassesDefaultSelectionSegment
        numberOfDaysOfPasses.selectedSegmentIndex    = Globals.numberOfDaysOfPassesDefaultSelectionSegment
        
        Globals.markerType                           = defaultMarkerType
        markerTypeSelector.selectedSegmentIndex      = defaultMarkerType
        
        Globals.globeBackgroundImageSelection        = Globals.globeBackgroundImageDefaultSelectionSegment
        backgroundSelector.selectedSegmentIndex      = Globals.globeBackgroundImageDefaultSelectionSegment
        
        Globals.zoomFactorWasResetInSettings         = true       // Flag is set to indicate that TrackingViewController should check to restore zoom to its default values
        Globals.globeBackgroundWasChanged            = true
        Globals.blackScreenInHDEVExplanationPopsUp   = true
    }
    
    
    /// Set switches and selectors to current settings
    private func setUpSwitchesAndControlsFromSavedSettings() {
        
        if Globals.showCoordinatesIsOn {
            showCoordinatesSwitch.isOn                = true
        } else {
            showCoordinatesSwitch.isOn                = false
        }
        
        if Globals.displayZoomFactorBelowMarkerIsOn {
            displayZoomFactorBelowMarkerSwitch.isOn   = true
        } else {
            displayZoomFactorBelowMarkerSwitch.isOn   = false
        }

        if Globals.showWhatsNewUponNextStartup {
            showWhatsNewSwitch.isOn                   = true
        } else {
            showWhatsNewSwitch.isOn                   = false
        }
        
        if Globals.orbitGroundTrackLineEnabled {
            showOrbitGroundTrackLine.isOn             = true
        } else {
            showOrbitGroundTrackLine.isOn             = false
        }
        
        if Globals.displayGlobe {
            displayGlobeSwitch.isOn                   = true
        } else {
            displayGlobeSwitch.isOn                   = false
        }
        
        if Globals.autoRotateGlobeEnabled {
            autoRotateGlobeSwitch.isOn                = true
        } else {
            autoRotateGlobeSwitch.isOn                = false
        }
        
        if Globals.mapScrollingAndZoomIsEnabled {
            userMapScrollingEnbleSwitch.isOn          = true
        } else {
            userMapScrollingEnbleSwitch.isOn          = false
        }
        
        markerTypeSelector?.selectedSegmentIndex      = Globals.markerType
        numberOfDaysOfPasses?.selectedSegmentIndex    = Globals.numberOfDaysOfPassesSelectedSegment
        zoomRangeFactorSelector?.selectedSegmentIndex = Globals.zoomRangeFactorSelection
        mapTypeSelector?.selectedSegmentIndex         = Globals.mapTypeSelection
        backgroundSelector?.selectedSegmentIndex      = Globals.globeBackgroundImageSelection
        dateAndTimeSaved                              = "Last saved: \(Globals.lastDateAndTimeSettingsWereSaved)"
        versionAndCopyrightFooter                     = "Version: \(versionNumber)  Build: \(buildNumber)\n\(copyrightNotice)\n\nIncludes: WhatsNewKit © 2020 Sven Tiigi"
    }
    
    
    // Table view data source for footer
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {

        switch section {
        case 0 :
            return dateAndTimeSaved ?? ""
        case 1 :
            return versionAndCopyrightFooter
        default:
            return nil
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier != nil else { return }                                     // Prevents crash if a segue is unnamed
        
        switch segue.identifier {
        case Constants.segueToHelpFromSettings :
            let navigationController        = segue.destination as! UINavigationController
            let destinationVC               = navigationController.topViewController as! HelpViewController
            destinationVC.helpContentHTML   = UserGuide.settingsHelp
            destinationVC.title             = helpTitle
        default :
            break
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


/// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
