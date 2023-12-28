//
//  Protocols.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 2/20/16.
//  Copyright © 2016-2024 ISS Real-Time Tracker. All rights reserved.
//

import Foundation

#if os(watchOS)
protocol ConvertsToDegreesMinutesSeconds {
    
    static func decimalCoordinatesToDegMinSec(coordinate: Double, format: String, isLatitude: Bool) -> String
    
}

#else

protocol ConvertsToDegreesMinutesSeconds {
    
    static func decimalCoordinatesToDegMinSec(latitude: Double, longitude: Double, format: String) -> String
    
}

#endif

protocol StringDateConversions {
    
    func convert(from date: String, fromStringFormat: String, toStringFormat: String) -> String?
    func getCurrentDateAndTimeInAString(forCurrent date: Date, withOutputFormat: String) -> String
    
}

protocol AlertHandler {
    
    func alert(for title: String, message messageToDisplay: String)
    
}

