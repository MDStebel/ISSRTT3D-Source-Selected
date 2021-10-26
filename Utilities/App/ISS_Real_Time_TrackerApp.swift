//
//  ISS_Real_Time_TrackerApp.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 8/26/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SwiftUI

@main
struct ISS_Real_Time_TrackerApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            GlobeView()
        }
        
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
