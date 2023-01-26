//
//  APIKeysAndEndpoints.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 9/8/21.
//  Copyright © 2021-2023 ISS Real-Time Tracker. All rights reserved.
//

import Foundation

/// List of keys for the APIs used in the apps
struct ApiKeys {
    
    static let generalLocationKey        = "BZQB9N-9FTL47-ZXK7MZ-3TLE"
    static let issLocationKey            = "BZQB9N-9FTL47-ZXK7MZ-3TLE"
    static let locationKey               = "BZQB9N-9FTL47-ZXK7MZ-3TLE"
    static let nasaKey                   = "dvPOzpsnRkbye6ZB2Xle0d0pWMLZDk3QHIO1jAeo"
    static let passesApiKey              = "BZQB9N-9FTL47-ZXK7MZ-3TLE"
    static let tssLocationKey            = "BZQB9N-9FTL47-ZXK7MZ-3TLE"
    
}


/// List of the endpoints and URLs used in the apps
struct ApiEndpoints {
    
    static let crewAPIEndpoint           = "https://issrttapi.com/crew.json"
    static let crewBioBackupURL          = "https://www.issrtt.com/issrtt-astronaut-bio-not-found"
    static let generalTrackerAPIEndpoint = "https://api.n2yo.com/rest/v1/satellite/positions/"
    static let issTrackerAPIEndpointA    = "https://api.wheretheiss.at/v1/satellites/25544"
    static let issTrackerAPIEndpointB    = "https://api.open-notify.org/iss-now.json"
    static let issTrackerAPIEndpointC    = "https://api.n2yo.com/rest/v1/satellite/positions/"
    static let passesAPIEndpoint         = "https://api.n2yo.com/rest/v1/satellite/visualpasses/"
    static let ratingURL                 = "itms://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1079990061"
    static let supportURL                = "https://www.issrtt.com/#support"
    static let tssTrackerAPIEndpoint     = "https://api.n2yo.com/rest/v1/satellite/positions/48274/0/0/0/1/"
    
}
