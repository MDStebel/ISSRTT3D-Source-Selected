//
//  Theme.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 9/15/20.
//  Copyright © 2020-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


/// The main theme used in the app
struct Theme {
    
    static let ISSOrbitalColor                              = tint
    static let TSSOrbitalColor                              = "StarColor"
    static let appFont                                      = "Avenir Book"
    static let appFontBold                                  = "Avenir Next Medium"
    static let atlBgd                                       = "Alternate Background"
    static let bgd                                          = "Background"
    static let cellBackgroundColorAlpha: CGFloat            = 0.15
    static let cornerRadius: CGFloat                        = 15
    static let issrttWhite                                  = "ISSRTT-White"
    static let lblBgd                                       = "Label Background"
    static let nasa                                         = "nasalization"
    static let navigationBarTitleFontSizeForIPad: CGFloat   = 24
    static let navigationBarTitleFontSizeForIPhone: CGFloat = 20
    static let popupBgd                                     = "Pop-Up and Tab Bar Background"
    static let soundTrack                                   = "122607755-opening-chakras-new-age-medita.wav"
    static let star                                         = "StarColor"
    static let tblBgd                                       = "Table Background"
    static let tint                                         = "Tint"
    static let usrGuide                                     = "User Guide Background"
    static let white                                        = "White"
    
    static var lastBackgroundColorWas: UIColor              = .white
    static var navigationBarTitleFontSize: CGFloat          = 0
    static var whatsNewTitleFontSize: CGFloat               = 36
    
}
