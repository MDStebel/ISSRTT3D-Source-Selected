//
//  ErrorCodes.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 10/1/21.
//  Copyright © 2021-2024 ISS Real-Time Tracker. All rights reserved.
//

import Combine
import SwiftUI

/// Errors used by the app
struct ErrorCodes: Error, Identifiable {
    
    let id      = UUID()
    let title   = "Error!"
    var message = "Can't get data"
    
}

