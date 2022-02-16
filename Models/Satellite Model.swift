//
//  Satellite Model.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 5/9/21.
//  Copyright © 2022 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit

// MARK: - Space stations and/or other satellites that we can get pass predictions for

/// Model represents space  stations and their corresponding names and images
public enum StationsAndSatellites: String, CaseIterable {
    
    case iss
    case tss
    case hst
    case none
    
    var satelliteNORADCode: String {
        switch self {
        case .iss  :
            return "25544"
        case .tss  :
            return "49222"
        case .hst  :
            return "20580"
        case .none :
            return "25544"
        }
    }
    
    var stationName: String {
        switch self {
        case .iss  :
            return "ISS"
        case .tss  :
            return "Tiangong"
        case .hst  :
            return "Hubble"
        case .none :
            return "ISS"
        }
    }
    
    var stationImage: UIImage? {
        switch self {
        case .iss :
            return UIImage(named: Globals.issIconFor3DGlobeView)!
        case .tss :
            return UIImage(named: Globals.tssIconFor3DGlobeView)!
        case .hst :
            return UIImage(named: Globals.hubbleIconFor3DGlobeView)!
        case .none :
            return UIImage(named: Globals.issIconFor3DGlobeView)!
        }
    }
}



//
///// Defines a satellite object
//class Satellite {
//    
//    var name: String
//    var imageFileName: String
//    var orbitalInclination: Float
//    var altitudeInKM: Float
//    var NORADCode: Int
//    
//    
//    init(name: String, image: String, orbitalInclination: Float, altitudeInKM: Float, NORADCode: Int) {
//        self.name               = name
//        self.imageFileName      = image
//        self.orbitalInclination = orbitalInclination
//        self.altitudeInKM       = altitudeInKM
//        self.NORADCode          = NORADCode
//    }
//    
//    convenience init(name: String) {
//        self.init(name: name, image: "defaultImage.png", orbitalInclination: Globals.ISSOrbitInclinationInDegrees, altitudeInKM: 430.0, NORADCode: 0)
//        self.name               = name
//    }
//    
//}
//
//
//class SpaceStation: Satellite {
//    
//    var crew: [Astronaut]?
//    var nation: String
//    var orbitalColorName: String
//    
//    init(name: String, image: String, orbitalInclination: Float, altitudeInKM: Float, NORADCode: Int, crew: [Astronaut]?, nation: String, orbitalColorName: String) {
//        self.crew               = crew
//        self.nation             = nation
//        self.orbitalColorName   = orbitalColorName
//        super.init(name: name, image: image, orbitalInclination: orbitalInclination, altitudeInKM: altitudeInKM, NORADCode: NORADCode)
//    }
//    
//}
