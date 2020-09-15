//
//  OrbitalPosition.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 7/20/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import Foundation


/// Model encapsulating the orbital position (lat/lon), altitude, and velocity of a satellite or orbiting spacecraft
struct OrbitalPosition {
    
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let velocity: Double
    let time: Double
    
    
    /// Parses JSON file with coordinates, altitude, velocity, and date & time from the data returned from the API
    static func parseLocationSpeedAndAltitude(from data: Data?) -> OrbitalPosition? {
        
        /// Type alias for a dictionary to make code easier to read
        typealias JSONDictionary = [String: Any]
        
        do {
            
            if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? JSONDictionary,
                let lat = json["latitude"] as? Double,
                let long = json["longitude"] as? Double,
                let dateAndTime = json["timestamp"] as? Double,
                let altitude = json["altitude"] as? Double,
                let velocity = json["velocity"] as? Double
            {
                return OrbitalPosition(latitude: lat, longitude: long, altitude: altitude, velocity: velocity, time: dateAndTime)
                
            } else {
                return nil
            }
            
        }
            
        catch {
            return nil
        }
        
    } // end parse location
    
    
} // end OrbitalPosition type


extension OrbitalPosition: CustomStringConvertible {
    
    var description: String {
        return "Lat: \(latitude) Lon: \(longitude) Alt: \(altitude) km Vel: \(velocity) km/h"
    }
    
}
