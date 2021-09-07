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
    static let ISSRTT3DRed  = Color(Theme.tint)
    static let ISSRTT3DGrey = Color(Theme.usrGuide)
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
            .background(Color.ISSRTT3DGrey)
            .foregroundColor(.white)
            .font(.subheadline)
            .frame(height: 30)
            .cornerRadius(15)
            .offset(y: 10.0)
    }
}
