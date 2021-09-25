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
    
    /// Extends View to allow us to use custom modifier without using ".modifier(..."
    /// - Returns: Custom modifier
    func withMDSButtonModifier() -> some View {
        self.modifier(MDSButtonModifier())
    }
}


/// Button style custom modifier
///
/// Produces a small round button with a white background and ISSRTT3DRed foreground.
/// - Parameter content: The view being modified
/// - Returns: Custom modifier
struct MDSButtonModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .background(Color.ISSRTT3DRed)
            .font(.subheadline)
            .foregroundColor(.white)
            .cornerRadius(15)
            .padding([.leading, .trailing])
            .padding([.bottom], 3)
    }
}
