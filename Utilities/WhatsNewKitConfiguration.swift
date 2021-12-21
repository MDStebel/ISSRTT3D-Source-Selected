//
//  WhatsNewKitConfiguration.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/3/19.
//  Copyright © 2019-2021 Michael Stebel Consulting, LLC. All rights reserved.
//  Uses WhatsNewKit by Sven Tiigi
//

#if !os(watchOS)    // Only the iOS and iPadOS versions use this

import WhatsNewKit
import UIKit

// Initialize a WhatsNew instance
private let whatsNew = WhatsNew(
    
    // The Title
    title: "What's New",
    
    // The features and other information to showcase
    items: [
        WhatsNew.Item(
            title: "What's New",
            subtitle: """
                      Globe autorotation is now available in the watchOS app. Can be toggled on/off. Default is on.
                      """,
            image: UIImage(systemName: "megaphone.fill")
        ),
        WhatsNew.Item(
            title: "What's Fixed",
            subtitle: """
                      Performance improvements and bug fixes.
                      """,
            image: UIImage(systemName: "ant.fill")
        ),
        WhatsNew.Item(
            title: "Apple Watch App Included",
            subtitle: """
                      Own an Apple Watch? Installing ISS Real-Time Tracker 3D will also install the companion app on your watch. The watchOS app provides the interactive 3D globe and detail view showing ISS, Tiangong, Hubble Space Telescope, and the subsolar point coordinates and altitudes. Requires watchOS 8 or higher.
                      """,
            image: UIImage(systemName: "applewatch.watchface")
        ),
        WhatsNew.Item(
            title: "Built-In Help",
            subtitle: """
                      To learn how to use this app, please tap on the \(Globals.helpChar) button (top-right). Each screen has its own help button that explains how to use a specfic feature.
                      """,
            image: UIImage(systemName: "questionmark.circle.fill")
        ),
        WhatsNew.Item(
            title: "Getting Support",
            subtitle: """
                      Have questions or issues? Use my chatbot at https://issrtt.com. You can get there easily from Settings. Just tap the settings button at the top-left.
                      """,
            image: UIImage(named: "icons8-customer_support")
        )
    ]
    
)


// Initialize a detail button
let detailButton = WhatsNewViewController.DetailButton(
    title: "ISS Real-Time Tracker 3D Version \(Globals.versionNumber)",
    action: .website(url: "")
)


// Fonts for items and other text
private var detailButtonFont                        = UIFont(name: Theme.appFont, size: 12)!
private var itemTitleFont                           = UIFont(name: Theme.appFont, size: 12)!
private var mainFont                                = UIFont(name: Theme.appFont, size: 12)!


// Set the ISSRTT custom theme
private var myTheme = WhatsNewViewController.Theme { configuration in
    
    if Globals.isIPad {
        mainFont         = UIFont(name: Theme.appFont, size: 15)!
        itemTitleFont    = UIFont(name: Theme.appFontBold, size: 24)!
        detailButtonFont = UIFont(name: Theme.appFont, size: 14)!
    } else {
        mainFont         = UIFont(name: Theme.appFont, size: 13)!
        itemTitleFont    = UIFont(name: Theme.appFontBold, size: 18)!
        detailButtonFont = UIFont(name: Theme.appFont, size: 12)!
    }
    
    configuration.backgroundColor                   = UIColor(named: Theme.usrGuide)!
    configuration.completionButton.animation        = .slideUp
    configuration.completionButton.backgroundColor  = UIColor(named: Theme.tint)!
    configuration.completionButton.hapticFeedback   = .selection
    configuration.completionButton.titleColor       = .white
    configuration.detailButton                      = detailButton
    configuration.detailButton?.titleColor          = .lightGray
    configuration.detailButton?.titleFont           = detailButtonFont
    configuration.itemsView.animation               = .slideLeft
    configuration.itemsView.subtitleColor           = .white
    configuration.itemsView.subtitleFont            = mainFont
    configuration.itemsView.titleColor              = .white
    configuration.itemsView.titleFont               = itemTitleFont
    configuration.tintColor                         = UIColor(named: Theme.tint)!
    configuration.titleView.animation               = .slideDown
    configuration.titleView.secondaryColor          = .init(startIndex: 7, length: 3, color: UIColor(named: Theme.star)!)
    configuration.titleView.titleColor              = UIColor(named: Theme.tint)!
    configuration.titleView.titleFont               = UIFont(name: Theme.nasa, size: Theme.whatsNewTitleFontSize)!
    configuration.titleView.titleMode               = .fixed
    
}

// Assign to configuration
private let myConfiguration = WhatsNewViewController.Configuration(theme: myTheme)

/// Initialize WhatsNewViewController with WhatsNew
let whatsNewViewController  = WhatsNewViewController(whatsNew: whatsNew, configuration: myConfiguration)

#endif
