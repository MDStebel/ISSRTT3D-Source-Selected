//
//  StyleExtensions.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 9/5/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SwiftUI


/// Create new colors from ISSRTT3D theme colors and other colors
extension Color {
    
    static let ISSRTT3DBackground = Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 0.75)
    static let ISSRTT3DGold       = Color(Theme.issrtt3dGoldCGColor!)
    static let ISSRTT3DGrey       = Color(Theme.usrGuide)
    static let ISSRTT3DRed        = Color(Theme.tint)
}


extension Font {
    
    static let ISSRTT3DFont       = Font.custom(Theme.nasa, size: 15.0)
}


extension View {
    
    /// Custom modifier for a button
    ///
    /// Returns a small round button with a white background and ISSRTT3DRed foreground.
    var withMDSButtonModifier: some View {
        self.modifier(MDSButtonModifier())
    }
}


struct MDSButtonModifier: ViewModifier {
    
    /// Button style custom modifier
    ///
    /// Produces a small round button with a white background and ISSRTT3DRed foreground.
    /// - Returns: Custom modifier
    func body(content: Content) -> some View {
        content
            .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .background(Color.ISSRTT3DRed)
            .font(.system(size: 16, weight: .semibold, design: .default))
            .foregroundColor(.white)
            .cornerRadius(.infinity)
            .shadow(color: .ISSRTT3DRed, radius: 7)
            .padding([.horizontal])
    }
}


extension View {
    
    /// Custom modifier for text
    ///
    /// Returns small ISSRed text
    var withMDSDataLabelModifier: some View {
        self.modifier(MDSDataLabelModifier())
    }
}


struct MDSDataLabelModifier: ViewModifier {
    
    /// Custom modifier for text
    ///
    /// Produces a small ISSRed text
    /// - Returns: Custom modifier
    func body(content: Content) -> some View {
        content
            .font(.system(size: 8.0))
            .foregroundColor(.ISSRTT3DRed)
    }
}
