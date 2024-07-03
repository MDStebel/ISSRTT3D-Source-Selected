//
//  Satellite Model.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 5/9/21.
//  Copyright © 2022-2024 ISS Real-Time Tracker. All rights reserved.
//

import UIKit

// MARK: - Space stations and/or other satellites that we can get pass predictions for

/// Model that represents current space stations, or any Earth-orbiting satellite, and their corresponding names, NORAD codes, and images
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
            return "48274"
        case .hst  :
            return "20580"
        case .none :
            return "25544"
        }
    }
    
    var satelliteName: String {
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
    
    var satelliteImage: UIImage? {
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
    
    var satelliteImageSmall: UIImage? {
        switch self {
        case .iss :
            return UIImage(named: Globals.issIconForMapView)!
        case .tss :
            return UIImage(named: Globals.tssIconForMapView)!
        case .hst :
            return UIImage(named: Globals.hubbleIconForMapView)!
        case .none :
            return UIImage(named: Globals.issIconForMapView)!
        }
    }
    
}
