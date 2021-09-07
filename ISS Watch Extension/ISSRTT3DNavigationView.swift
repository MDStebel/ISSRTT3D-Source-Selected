//
//  ISSRTT3DNavigationView.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 9/7/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SwiftUI

struct ISSRTT3DNavigationView: View {
    var body: some View {
        NavigationView {
            VStack {
                SubSolarPointView()
                NavigationLink("Tracker", destination: ISSLocationView())
                    .withISSNavigationLinkFormatting()
            }
        }
    }
}

struct ISSRTT3DNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        ISSRTT3DNavigationView()
    }
}
