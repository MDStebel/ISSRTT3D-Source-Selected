//
//  PassRatingModel.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 6/8/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import Foundation

/// Pass rating model based on magnitude of the object passing
enum RatingSystem: Double, CaseIterable {
    case unknown = 100000.0     // The API returns 100000 if there is no magnitude data available
    case poor    = 100.0
    case fair    = -0.5
    case good    = -1.0
    case better  = -1.5
    case best    = -2.0
    
    var numberOfStars: Int {
        switch self {
        case .unknown: return 0
        case .poor:    return 0
        case .fair:    return 1
        case .good:    return 2
        case .better:  return 3
        case .best:    return 4
        }
    }
    
    static func numberOfRatingStars(for magnitude: Double) -> Int {
        switch magnitude {
        case _ where magnitude <= RatingSystem.best.rawValue:
            return RatingSystem.best.numberOfStars
        case _ where magnitude <= RatingSystem.better.rawValue:
            return RatingSystem.better.numberOfStars
        case _ where magnitude <= RatingSystem.good.rawValue:
            return RatingSystem.good.numberOfStars
        case _ where magnitude <= RatingSystem.fair.rawValue:
            return RatingSystem.fair.numberOfStars
        case _ where magnitude == RatingSystem.unknown.rawValue:
            return RatingSystem.unknown.numberOfStars
        default:
            return RatingSystem.poor.numberOfStars
        }
    }
}
