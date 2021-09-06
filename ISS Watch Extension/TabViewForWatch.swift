//
//  TabViewForWatch.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 9/5/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SwiftUI

struct TabViewForWatch: View {
    var body: some View {
        TabView {
            SubSolarPointView()
            ISSLocationView()
        }
    }
}

struct TabViewForWatch_Previews: PreviewProvider {
    static var previews: some View {
        TabViewForWatch()
    }
}
