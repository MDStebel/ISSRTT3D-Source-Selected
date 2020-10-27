//
//  WhatsNewKitConfiguration.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 10/3/19.
//  Copyright © 2019-2020 Michael Stebel Consulting, LLC. All rights reserved.
//  Uses WhatsNewKit by Sven Tiigi
//

import WhatsNewKit
import UIKit


// Initialize WhatsNew
private let whatsNew = WhatsNew(
    
    // The Title
    title: "What's New",
    
    // The features and other information to showcase
    items: [
        WhatsNew.Item(
            title: "New Feature!",
            subtitle: """
                      Photorealistic interactive 3D globe with ISS position, orbital track, & precise location of the Sun. Drag the globe to pan/rotate it. Enable/disable auto-rotate. You can also enable/disable the globe in Settings.
                      """,
            image: UIImage(named: "icons8-megaphone_filled.imageset")
        ),
        WhatsNew.Item(
            title: "Improvements & Fixes",
            subtitle: """
                      Support for iPhone 12 series. Plust, lots of user interface enhancements, performace improvements, and other under-the-hood stuff.
                      """,
            image: UIImage(named: "icons8-bug_filled")
        ),
        WhatsNew.Item(
            title: "User Support",
            subtitle: "If you have any questions or issues, please visit the support website at https://issrtt.com. You can get there easily from the Settings screen in the app.",
            image: UIImage(named: "icons8-customer_support")
        ),
        WhatsNew.Item(
            title: "Built-In Help",
            subtitle: """
                      To learn how to use this app, please tap on the '?' button (top-right). Each screen has its own help button that explains how to use a specfic feature.
                      """,
            image: UIImage(named: "icons8-help_filled")
        )
    ]
)

// Initialize a detail button
let detailButton = WhatsNewViewController.DetailButton(
    title: "ISS Real-Time Tracker Version \(WhatsNew.Version.current())",
    action: .website(url: "")
)

// Main font for items and other text
private let mainFont = UIFont(name: Theme.appFont, size: 16)!
private let itemTitleFont = UIFont(name: Theme.appFontBold, size: 20)!
private let detailButtonFont = UIFont(name: Theme.appFont, size: 14)!

// Set the ISSRTT custom theme
private var myTheme = WhatsNewViewController.Theme { configuration in
    configuration.backgroundColor                   = UIColor(named: Theme.usrGuide)!
    configuration.tintColor                         = UIColor(named: Theme.tint)!
    configuration.titleView.titleMode               = .fixed
    configuration.titleView.titleFont               = UIFont(name: Theme.nasa, size: Theme.whatsNewTitleFontSize)!
    configuration.titleView.titleColor              = UIColor(named: Theme.tint)!
    configuration.titleView.secondaryColor          = .init(startIndex: 7, length: 3, color: UIColor(named: Theme.star)!)
    configuration.titleView.animation               = .slideDown
    configuration.itemsView.subtitleColor           = .white
    configuration.itemsView.subtitleFont            = mainFont
    configuration.itemsView.titleColor              = .white
    configuration.itemsView.animation               = .slideLeft
    configuration.completionButton.hapticFeedback   = .selection
    configuration.detailButton?.titleFont           = detailButtonFont
    configuration.completionButton.animation        = .slideUp
    configuration.completionButton.backgroundColor  = UIColor(named: Theme.tint)!
    configuration.completionButton.titleColor       = .white
    configuration.detailButton                      = detailButton
    configuration.detailButton?.titleColor          = .lightGray
    configuration.detailButton?.titleFont           = detailButtonFont
}

// Assign to configuration
private let myConfiguration = WhatsNewViewController.Configuration(theme: myTheme)

/// Initialize WhatsNewViewController with WhatsNew
let whatsNewViewController = WhatsNewViewController(whatsNew: whatsNew, configuration: myConfiguration)