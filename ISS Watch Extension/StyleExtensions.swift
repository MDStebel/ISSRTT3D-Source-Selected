//
//  StyleExtensions.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 9/5/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SwiftUI

extension Color {
    
    // Create new colors from ISSRTT3D theme colors and other colors
    static let ISSRTT3DRed        = Color(Theme.tint)
    static let ISSRTT3DGrey       = Color(Theme.usrGuide)
    static let ISSRTT3DBackground = Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 0.75)
}


extension Font {
    static let ISSRTT3DFont = Font.custom(Theme.nasa, size: 15.0)
}


extension View {
    
    /// Extends View to allow us to use custom modifier without using ".modifier(..."
    /// - Returns: Custom modifier
    func withISSNavigationLinkFormatting() -> some View {
        self.modifier(ISSNavigationLinkModifier())
    }
}


/// Custom modifier for navigation links
struct ISSNavigationLinkModifier: ViewModifier {
    
    /// Button style navigation link custom modifier
    /// - Parameter content: The view being modified
    /// - Returns: Custom modifier
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 150, idealWidth: 175, maxWidth: .infinity, minHeight: 40, idealHeight: 40, maxHeight: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .opacity(0.95)
            .font(.subheadline)
            .foregroundColor(.white)
            .cornerRadius(20)
            .padding()
    }
}
