//
//  Spacecraft Model.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/19/21.
//  Copyright © 2022 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit

// MARK: - Spacecraft that shuttle crewmembers to/from space stations

/// Model  for manned spacecraft
public enum Spacecraft: String, CaseIterable {
    
    case soyuz      = "Soyuz"
    case crewDragon = "Crew Dragon"
    case starliner  = "Starliner"
    
    var spacecraftName: String {
        switch self {
        case .soyuz :
            return "Soyuz"
        case .crewDragon :
            return "Crew Dragon"
        case .starliner :
            return "Starliner"
        }
    }
    
    var spacecraftImages: UIImage {
        switch self {
        case .soyuz      :
            return #imageLiteral(resourceName: "Soyuz-2")
        case .crewDragon :
            return #imageLiteral(resourceName: "spacex-dragon-spacecraft-1")
        case .starliner  :
            return #imageLiteral(resourceName: "astronaut_filled_Grey")
        }
    }
}
