//
//  SettingsTableViewController.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 2/21/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    
    // MARK: - Properties
    
    
    private let websiteURL                  = "https://www.issrtt.com/#support"
    private let urlForRating                = "itms://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1079990061"
    private let urlForMyOtherApps           = "itms://itunes.apple.com/us/developer/michael-stebel/id1027443988"
    private let urlForFacebookLink          = "https://www.facebook.com/issrealtimetracker/"
    private let defaultMapType              = 2                                                     // Hybrid map type is the default
    private let defaultMarkerType           = 0                                                     // ISS icon marker type is the default
    private let defaultZoomFactor           = 2                                                     // Medium zoom is the default
    private let versionNumber               = Globals.versionNumber
    private let buildNumber                 = Globals.buildNumber
    private let copyrightNotice             = Globals.copyrightString
    private var dateAndTimeSaved: String?   = ""
    private var versionAndCopyrightFooter   = ""
    
    private struct Constants {
        static let segueToHelpFromSettings  = "segueToHelpFromSettings"
        static let fontForTitle             = Theme.nasa
    }
    
    /// During segue to this VC, this variable will contain the source view of the settings button
    var settingsButtonInCallingVCSourceView = UIView()
    
    // Change status bar to light color for this VC
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: - Outlets
    
    
    @IBOutlet private var mapTypeSelector: UISegmentedControl!
    @IBOutlet private var zoomRangeFactorSelector: UISegmentedControl!
    @IBOutlet private var markerTypeSelector: UISegmentedControl!
    @IBOutlet private var numberOfDaysOfPasses: UISegmentedControl! {
        // Set up segment labels from dictionary
        didSet{
            for index in 0..<Globals.numberOfDaysDictionary.count {
                numberOfDaysOfPasses.setTitle(Globals.numberOfDaysDictionary[index], forSegmentAt: index)
            }
        }
    }
    
    
    @IBOutlet private var showOrbitGroundTrackLine: UISwitch!
    @IBOutlet private var showCoordinatesSwitch: UISwitch!
    @IBOutlet private var displayZoomFactorBelowMarkerSwitch: UISwitch!
    @IBOutlet private var userMapScrollingEnbleSwitch: UISwitch!
    @IBOutlet private var showWhatsNewSwitch: UISwitch!
    
    
    // MARK: - Methods
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Set the target rect for the popover
        popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection([.up])
        popoverPresentationController?.sourceRect = CGRect(x: 1.00, y: 3.0, width: settingsButtonInCallingVCSourceView.bounds.width, height: settingsButtonInCallingVCSourceView.bounds.height)
        
        Globals.zoomFactorWasResetInSettings = false
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        setSwitchesAndControls()
        
        // Set font and attributes for navigation bar
        let titleFontSize = Theme.navigationBarTitleFontSize
        if let titleFont = UIFont(name: Constants.fontForTitle, size: titleFontSize) {
            let attributes = [NSAttributedString.Key.font: titleFont, .foregroundColor: UIColor.white]
            navigationController?.navigationBar.titleTextAttributes = attributes
            navigationController?.navigationBar.barTintColor = UIColor(named: Theme.tint)
        }
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
        
        switch sender.selectedSegmentIndex {
        case 0 :
            Globals.markerType = 0
        case 1 :
            Globals.markerType = 1
        case 2 :
            Globals.markerType = 2
        default :
            Globals.markerType = 0
        }
        
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
    
    
    ///  Got to my other apps on the App Store
    @IBAction private func linkToMyOtherApps(_ sender: UIButton) {
        
        if let iTunesLinkForMyOtherApps = URL(string: urlForMyOtherApps), UIApplication.shared.canOpenURL(iTunesLinkForMyOtherApps) {
            UIApplication.shared.open(iTunesLinkForMyOtherApps, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (success) in })
        }
        
    }
    
    
    @IBAction func likeOnFacebook(_ sender: UIButton) {
        
        if let facebookLink = URL(string: urlForFacebookLink), UIApplication.shared.canOpenURL(facebookLink) {
            UIApplication.shared.open(facebookLink, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (success) in })
        }
        
    }
    
    
    /// Reset all settings to their defaults
    @IBAction private func resetSettings(_ sender: UIBarButtonItem) {
        
        Globals.showCoordinatesIsOn = true
        showCoordinatesSwitch.isOn = true
        
        Globals.displayZoomFactorBelowMarkerIsOn = true
        displayZoomFactorBelowMarkerSwitch.isOn = true
        
        Globals.mapScrollingAndZoomIsEnabled = false
        userMapScrollingEnbleSwitch.isOn = false

        Globals.showWhatsNewUponNextStartup = false
        showWhatsNewSwitch.isOn = false
        
        Globals.orbitGroundTrackLineEnabled = true
        showOrbitGroundTrackLine.isOn = true
        
        Globals.mapTypeSelection = defaultMapType
        mapTypeSelector.selectedSegmentIndex = defaultMapType
        
        Globals.zoomRangeFactorSelection = defaultZoomFactor
        zoomRangeFactorSelector.selectedSegmentIndex = defaultZoomFactor

        Globals.numberOfDaysOfPassesSelectedSegment = Globals.numberOfDaysOfPassesDefaultSelectionSegment
        numberOfDaysOfPasses.selectedSegmentIndex = Globals.numberOfDaysOfPassesDefaultSelectionSegment
        
        Globals.markerType = defaultMarkerType
        markerTypeSelector.selectedSegmentIndex = defaultMarkerType
        
        Globals.zoomFactorWasResetInSettings = true                     // Flag is set to indicate that main ViewController should check to restore zoom to its default values
        
        Globals.blackScreenInHDEVExplanationPopsUp = true
        
    }
    
    
    /// Set switches and selectors to current settings
    private func setSwitchesAndControls() {
        
        if Globals.showCoordinatesIsOn {
            showCoordinatesSwitch.isOn = true
        } else {
            showCoordinatesSwitch.isOn = false
        }
        
        if Globals.displayZoomFactorBelowMarkerIsOn {
            displayZoomFactorBelowMarkerSwitch.isOn = true
        } else {
            displayZoomFactorBelowMarkerSwitch.isOn = false
        }

        if Globals.showWhatsNewUponNextStartup {
            showWhatsNewSwitch.isOn = true
        } else {
            showWhatsNewSwitch.isOn = false
        }
        
        if Globals.orbitGroundTrackLineEnabled {
            showOrbitGroundTrackLine.isOn = true
        } else {
            showOrbitGroundTrackLine.isOn = false
        }
        
        if Globals.mapScrollingAndZoomIsEnabled {
            userMapScrollingEnbleSwitch.isOn = true
        } else {
            userMapScrollingEnbleSwitch.isOn = false
        }
        
        markerTypeSelector?.selectedSegmentIndex = Globals.markerType
        numberOfDaysOfPasses?.selectedSegmentIndex = Globals.numberOfDaysOfPassesSelectedSegment
        zoomRangeFactorSelector?.selectedSegmentIndex = Globals.zoomRangeFactorSelection
        mapTypeSelector?.selectedSegmentIndex = Globals.mapTypeSelection
        dateAndTimeSaved = "Last saved: \(Globals.lastDateAndTimeSettingsWereSaved)"
        versionAndCopyrightFooter = "Version: \(versionNumber)  Build: \(buildNumber)\n\(copyrightNotice)\nIncludes WhatsNewKit © 2020 Sven Tiigi"

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
            let destinationVC = segue.destination as! HelpViewController
            destinationVC.helpContentHTML = UserGuide.settingsHelp
            
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
