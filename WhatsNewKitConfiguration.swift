//
//  WhatsNewKitConfiguration.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/3/19.
//  Copyright © 2019-2021 Michael Stebel Consulting, LLC. All rights reserved.
//  Uses WhatsNewKit by Sven Tiigi
//

import WhatsNewKit
import UIKit


// Initialize a WhatsNew instance
private let whatsNew = WhatsNew(
    
    // The Title
    title: "What's New",
    
    // The features and other information to showcase
    items: [
        WhatsNew.Item(
            title: "New: Tracks the Chinese Space Station, Too!",
            subtitle: """
                      Version 7 adds real-time tracking of the new Tiangong space station (TSS) in the fullscreen 3D globe view! Now track both the ISS & TSS in 3D! TSS pass predictions will be coming later. Learn more in Help.
                      """,
            image: UIImage(named: "icons8-megaphone_filled.imageset")
        ),
        WhatsNew.Item(
            title: "Improvements & Fixes",
            subtitle: """
                      All-new passes section. Now provides ISS and TSS pass predictions (the latter with limitations, see User Guide and help). Refreshed passes and crew table layout designs.
                      """,
            image: UIImage(named: "icons8-bug_filled")
        ),
        WhatsNew.Item(
            title: "Built-In Help",
            subtitle: """
                      To learn how to use this app, please tap on the \(Globals.helpChar) button (top-right). Each screen has its own help button that explains how to use a specfic feature.
                      """,
            image: UIImage(named: "icons8-help_filled")
        ),
        WhatsNew.Item(
            title: "Getting Support",
            subtitle: """
                      Have questions or issues? Use "Spacey" the chatbot at https://issrtt.com. You can get there easily from Settings. Just tap \(Globals.settingsChar) at the top-left.
                      """,
            image: UIImage(named: "icons8-customer_support")
        )
    ]
)


// Initialize a detail button
let detailButton = WhatsNewViewController.DetailButton(
    title: "ISS Real-Time Tracker 3D Version \(WhatsNew.Version.current())",
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
