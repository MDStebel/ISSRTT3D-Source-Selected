//
//  SubSolarViewModel.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 9/6/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SwiftUI

final class SubSolarViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var subsolarLatitude: String  = ""
    @Published var subsolarLongitude: String = ""
    
    private var timer                        = Timer()
    private let timerValue                   = 5.0
    
    // MARK: - Methods
    
    init() {
        startUp()
    }
    
    func startUp() {
        updateSubSolarPoint()   // Get the data once before starting the timer so we have something we can use immediately
        startTimer()
    }
    
    private func updateSubSolarPoint() {
        let values        = AstroCalculations.getSubSolarCoordinates()
        subsolarLatitude  = CoordinateConversions.decimalCoordinatesToDegMinSec(coordinate: Double(values.latitude), format: Globals.coordinatesStringFormat, isLatitude: true)
        subsolarLongitude = CoordinateConversions.decimalCoordinatesToDegMinSec(coordinate: Double(values.longitude), format: Globals.coordinatesStringFormat, isLatitude: false)
    }
    
    /// Set up and start the timer
    private func startTimer() {
        if !timer.isValid {
            timer = Timer.scheduledTimer(timeInterval: timerValue, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        }
    }
    
    /// The selector the timer calls
    @objc func update() {
        updateSubSolarPoint()
    }
    
    /// Stop the timer
    func stop() {
        timer.invalidate()
    }
}
