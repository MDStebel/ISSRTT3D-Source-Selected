//
//  StyleExtensions.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 9/5/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SwiftUI

extension Color {
    // Add global ISSRTT3D theme colors
    static let ISSRTT3DRed = Color(Theme.tint)
    static let ISSRTT3DGrey  = Color(Theme.lblBgd)
}

extension Font {
    static let ISSRTT3DFont = Font.custom(Theme.nasa, size: 15.0)
}

