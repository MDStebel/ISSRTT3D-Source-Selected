//
//  SubSolarViewModel.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 9/6/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import Combine
import SwiftUI

final class SubSolarViewModel: ObservableObject {
    
    // MARK: - Published properties
    
    @Published var subsolarLatitude: String  = ""
    @Published var subsolarLongitude: String = ""
    
    // MARK: - Properties
    
    private let timerValue                   = 3.0
    private var timer: AnyCancellable?
    
    
    // MARK: - Methods
    
    init() {
        
        start()
        
    }
    
    
    func startUp() {
        
        updateSubSolarPoint()   // Get the data once before starting the timer so we have something we can use immediately
        start()
        
    }
    
    
    private func updateSubSolarPoint() {
        
        let subsolarCoordinates = AstroCalculations.getSubSolarCoordinates()
        subsolarLatitude        = CoordinateConversions.decimalCoordinatesToDegMinSec(coordinate: Double(subsolarCoordinates.latitude), format: Globals.coordinatesStringFormat, isLatitude: true)
        subsolarLongitude       = CoordinateConversions.decimalCoordinatesToDegMinSec(coordinate: Double(subsolarCoordinates.longitude), format: Globals.coordinatesStringFormat, isLatitude: false)
        
    }
    
    
    /// Set up and start the timer
    private func start() {
        
        timer = Timer
            .publish(every: timerValue, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.updateSubSolarPoint()
            }
        
    }

    
    /// Stop the timer
    func stop() {
        
        timer?.cancel()
        
    }
    
}
