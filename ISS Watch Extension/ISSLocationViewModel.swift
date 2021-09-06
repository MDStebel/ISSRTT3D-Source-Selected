//
//  ISSLocationViewModel.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 9/6/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import Foundation

class ISSLocationViewModel: ObservableObject {
    @Published var issLocationString: String = ""
    
    init() {
        updateISSLocation()
    }
    
    func updateISSLocation() {
        // replace with actual code to get coordinates from API
        let values: (Double, Double) = (50.0, 179.9)
        issLocationString = CoordinateConversions.decimalCoordinatesToDegMinSec(latitude: values.0, longitude: values.1, format: Globals.coordinatesStringFormat)
    }
}
