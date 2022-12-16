//
//  CrewMemberDetailView.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 11/18/17.
//  Copyright © 2016-2023 ISS Real-Time Tracker. All rights reserved.
//

import UIKit

class CrewMemberDetailView: UIView {

    
    // MARK: - Properties
    
    
    /// This will contain the Twitter URL passed from the VC, if it exists. If there's no Twitter URL, then don't show the button
    var twitterHandleURL: String? = nil {
        willSet {
            twitterButton.isHidden = newValue == "" ? true : false
        }
    }
    
    private let cornerRadius = Theme.cornerRadius
    private let shortBioBackgroundColor = UIColor(named: Theme.popupBgd)?.cgColor
    
    
    // MARK: - Outlets
    
    
    @IBOutlet var shortBioInforomation: UILabel!
    @IBOutlet var shortBioName: UILabel!
    @IBOutlet var fullBioButton: UIButton!
    @IBOutlet var twitterButton: UIButton!
    
    
    // MARK: - Methods

    
    override func layoutIfNeeded() {
        layoutIfNeeded()
    }
    
    
    /// Open Twitter app to this crew member's Twitter profile in Twitter app or Twitter website
    @IBAction private func goToTwitter() {

        // First make sure we have a valid Twitter URL and can extract the handle from it and that the handle isn't blank
        guard twitterHandleURL != "", let twitterHandle = twitterHandleURL?.deletingPrefix("https://twitter.com/"), twitterHandle != "", twitterHandle.count > 3 else { return }
        
        let appURL = URL(string: "twitter://user?screen_name=\(twitterHandle)")!
        let webURL = URL(string: "https://twitter.com/\(twitterHandle)")!
        
        // Open Twitter app if installed. Otherwise, open Twitter website in Safari
        let application = UIApplication.shared
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            application.open(webURL as URL)
        }
    }
    
    
    @IBAction private func close(_ sender: Any) {
        removeFromSuperview()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        layer.cornerRadius    = cornerRadius
        layer.shadowColor     = UIColor.black.cgColor
        layer.shadowRadius    = 4.0
        layer.shadowOpacity   = 0.6
        layer.shadowOffset    = CGSize(width: 0.0, height: 3.0)
        layer.backgroundColor = shortBioBackgroundColor
        
    }
}
