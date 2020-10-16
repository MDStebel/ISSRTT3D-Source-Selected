//
//  Date Conversions Extension.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 5/27/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


/// Extension to DateFormatter to convert dates. Conforms to StringDateConversions protocol.
extension DateFormatter: StringDateConversions {
    
    /// Take a date and convert it from its original format to a new format and return optional string.
    /// - Parameters:
    ///   - date: Date string.
    ///   - fromStringFormat: Format date is in.
    ///   - toStringFormat: Format used in converting date.
    /// - Returns: Optional date string.
    func convert(from date: String, fromStringFormat: String, toStringFormat: String) -> String? {
        
        dateFormat = fromStringFormat
        
        if let tempDate = self.date(from: date) {
            
            dateFormat = toStringFormat
            return string(from: tempDate)
            
        } else {

            return nil
        }
        
    }

    
    /// Convert a Date to a date in String representation.
    /// - Parameters:
    ///   - date: Date
    ///   - withOutputFormat: Format to use.
    /// - Returns: Date as a string.
    func getCurrentDateAndTimeInAString(forCurrent date: Date, withOutputFormat: String) -> String {
        
        dateFormat = withOutputFormat
        return string(from: date)
        
    }

}
