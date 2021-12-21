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
    
    static let hubbleColor        = Color(Theme.hubbleOrbitalColor)
    static let ISSRTT3DBackground = Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 0.75)
    static let ISSRTT3DGold       = Color(Theme.issrtt3dGoldCGColor!)
    static let ISSRTT3DGrey       = Color(Theme.usrGuide)
    static let ISSRTT3DRed        = Color(Theme.tint)
    static let subsolorColor      = Color.yellow
    
}


extension Font {
    
    static let ISSRTT3DFont       = Font.custom(Theme.nasa, size: 15.0)
    
}


extension View {
    
    /// Custom modifier for a button
    ///
    /// Returns a small round button with a white background and ISSRTT3DRed foreground.
    var withSmallButtonModifier: some View {
        self.modifier(smallButtonModifier())
    }
    
}


struct smallButtonModifier: ViewModifier {
    
    /// Button style custom modifier
    ///
    /// Produces a small round button with a white background and ISSRTT3DRed foreground.
    /// - Returns: Custom modifier
    func body(content: Content) -> some View {
        content
            .frame(width: 60, height: 27, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .background(Color.white.opacity(0.10))
            .font(.system(size: 16, weight: .semibold, design: .default))
            .foregroundColor(.white)
            .clipShape(Circle())
            .padding([.horizontal])
        
//            .buttonStyle(.bordered)
//            .buttonBorderShape(.roundedRectangle)
//            .padding(.top)
//            .foregroundColor(.accentColor)
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
    /// Produces a small bold white text
    /// - Returns: Custom modifier
    func body(content: Content) -> some View {
        content
            .font(.custom(Theme.appFont, size: 10.0).bold())
            .foregroundColor(.white)
            .lineLimit(1)
    }
    
}


extension View {
    
    /// Custom modifier for coordinates text
    ///
    /// Returns medium sized bold text
    var withCoordinatesTextModifier: some View {
        self.modifier(CoordinatesTextModifier())
    }
    
}


struct CoordinatesTextModifier: ViewModifier {
    
    /// Custom modifier for coordinates text
    ///
    /// Returns medium sized bold text
    func body(content: Content) -> some View {
        content
            .font(.custom(Theme.appFont, size: 15).bold())
            .minimumScaleFactor(0.9)
    }
    
}
