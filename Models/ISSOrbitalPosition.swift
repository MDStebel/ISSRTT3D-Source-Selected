//
//  OrbitalPosition.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 7/20/16.
//  Copyright © 2016-2023 ISS Real-Time Tracker. All rights reserved.
//

import Foundation

/// Model encapsulating the orbital position (lat/lon), altitude, and velocity of a satellite or orbiting spacecraft
struct ISSOrbitalPosition: Codable {
    
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let velocity: Double
    let time: Double
    
    
    /// Parses JSON file with coordinates, altitude, velocity, and date & time from the data returned from the API.
    /// - Parameter data: The data returned from API
    /// - Returns: An OrbitalPosition instance
    static func parseLocationSpeedAndAltitude(from data: Data?) -> ISSOrbitalPosition? {
        
        /// Type alias for a dictionary to make code easier to read
        typealias JSONDictionary = [String: Any]
        
        do {
            
            if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? JSONDictionary,
                let lat         = json["latitude"] as? Double,
                let long        = json["longitude"] as? Double,
                let dateAndTime = json["timestamp"] as? Double,
                let altitude    = json["altitude"] as? Double,
                let velocity    = json["velocity"] as? Double
            {
                return ISSOrbitalPosition(latitude: lat, longitude: long, altitude: altitude, velocity: velocity, time: dateAndTime)
                
            } else {
                return nil
            }
            
        }
            
        catch {
            return nil
        }
        
    }
    
}


extension ISSOrbitalPosition: CustomStringConvertible {
    
    var description: String {
        return "Lat: \(latitude) Lon: \(longitude) Alt: \(altitude) km Vel: \(velocity) km/h"
    }
    
}
