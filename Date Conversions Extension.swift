//
//  Date Conversions Extension.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 5/27/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


/// Extension to NSDateFormatter to convert dates. Conforms to StringDateConversions protocol
extension DateFormatter: StringDateConversions {
    
    /// Take a date and convert it from its original format to a new format and return optional string
    func convert(from date: String, fromStringFormat: String, toStringFormat: String) -> String? {
        
        dateFormat = fromStringFormat
        
        if let tempDate = self.date(from: date) {
            
            dateFormat = toStringFormat
            return string(from: tempDate)
            
        } else {

            return nil
        }
        
    }

    
    func getCurrentDateAndTimeInAString(forCurrent date: Date, withOutputFormat: String) -> String {
        
        dateFormat = withOutputFormat
        return string(from: date)
        
    }

}
