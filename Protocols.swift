//
//  Protocols.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 2/20/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import Foundation


protocol ConvertsToDegreesMinutesSeconds {
    
    static func decimalCoordinatesToDegMinSec(latitude: Double, longitude: Double, format: String) -> String
    
}


protocol StringDateConversions {
    
    func convert(from date: String, fromStringFormat: String, toStringFormat: String) -> String?
    
    func getCurrentDateAndTimeInAString(forCurrent date: Date, withOutputFormat: String) -> String
    
}


protocol AlertHandler {
    
    func alert(for title: String, message messageToDisplay: String)
    
}
