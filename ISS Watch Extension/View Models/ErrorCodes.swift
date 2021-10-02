//
//  ErrorCodes.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/1/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import Combine
import SwiftUI

/// Errors used in app
struct ErrorCodes: Error, Identifiable {
    
    let id      = UUID()
    let title   = "Error"
    var message = "Can't get data"
}

