//
//  SubSolarViewModel.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 9/6/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import Foundation

class SubSolarViewModel: ObservableObject {
    @Published var subSolarPointString: String = ""
    
    init() {
        updateSubSolarPoint()
    }
    
    func updateSubSolarPoint() {
        let values = AstroCalculations.getSubSolarCoordinates()
        subSolarPointString = CoordinateConversions.decimalCoordinatesToDegMin(latitude: Double(values.latitude), longitude: Double(values.longitude), format: Globals.coordinatesStringFormatShortForm)
    }
}
