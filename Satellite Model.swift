//
//  Satellite Model.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 5/9/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import Foundation


/// Enum that enumerates the stations we can track
enum SatelliteID {
    case ISS, TSS, none
}


/// Defines a satellite object
class Satellite {
    
    var name: String
    var imageFileName: String
    var orbitalInclination: Float
    var altitudeInKM: Float
    var NORADCode: Int
    
    
    init(name: String, image: String, orbitalInclination: Float, altitudeInKM: Float, NORADCode: Int) {
        self.name               = name
        self.imageFileName      = image
        self.orbitalInclination = orbitalInclination
        self.altitudeInKM       = altitudeInKM
        self.NORADCode          = NORADCode
    }
    
    convenience init(name: String) {
        self.init(name: name, image: "defaultImage.png", orbitalInclination: Globals.ISSOrbitInclinationInDegrees, altitudeInKM: 430.0, NORADCode: 0)
        self.name               = name
    }
    
}


class SpaceStation: Satellite {
    
    var crew: [Astronaut]?
    var nation: String
    var orbitalColorName: String
    
    init(name: String, image: String, orbitalInclination: Float, altitudeInKM: Float, NORADCode: Int, crew: [Astronaut]?, nation: String, orbitalColorName: String) {
        self.crew               = crew
        self.nation             = nation
        self.orbitalColorName   = orbitalColorName
        super.init(name: name, image: image, orbitalInclination: orbitalInclination, altitudeInKM: altitudeInKM, NORADCode: NORADCode)
    }
    
}
