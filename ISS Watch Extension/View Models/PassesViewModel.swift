//
//  PassesViewModel.swift
//  ISS Watch
//
//  Created by Michael Stebel on 6/5/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import CoreLocation
import SwiftUI

@Observable
final class PassesViewModel: ObservableObject {
    
    // MARK: Published properties
    
    var isComputing     = false
    var noradID: String = ""
    var predictedPasses = [Passes.Pass]()
    
    private var lat: Double = 5
    private var lon: Double = 5
    
    /// Get array of predicted passes
    /// - Parameters:
    ///   - noradCode: Norad code for satellite
    ///   - latitude: User's latitude
    ///   - longitude: User's longitude
    func getPasses(for noradCode: String, latitude: Double, longitude: Double) {
        Task {
            isComputing.toggle()
            lat = latitude
            lon = longitude
            noradID = noradCode
            if let passes = await fetchData() {
                predictedPasses = passes.passes
                isComputing.toggle()
            }
        }
    }
    
    /// Get the number of stars from the rating system enum
    /// If no magnitude was returned by the API, return nil
    /// - Parameters:
    ///   - magnitude: pass magnitude
    /// - Returns: optional Int
    func getNumberOfStars(forMagnitude magnitude: Double) -> Int? {        
        if magnitude != RatingSystem.unknown.rawValue {
            return RatingSystem.numberOfRatingStars(for: magnitude)
        } else {
            return nil
        }
    }
    
    /// Get the next pass
    /// - Returns: An arrray of Passes
    private func fetchData() async -> Passes? {
        let altitude             = 0
        let apiKey               = ApiKeys.passesApiKey
        let endpointForPassesAPI = ApiEndpoints.passesAPIEndpoint
        let minObservationTime   = 300
        let numberOfDays         = 30
        let stationID            = noradID

        // Create the API URL request from endpoint. If not succesful, then return
        let URLrequestString = endpointForPassesAPI + "\(stationID)/\(lat)/\(lon)/\(altitude)/\(numberOfDays)/\(minObservationTime)&apiKey=\(apiKey)"
        
        // Ensure the URL is valid
        guard let url = URL(string: URLrequestString) else {
            print("Invalid URL")
            return nil
        }
        do {
            // Fetch the data asynchronously
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Decode the data into the Passes object
            let decoder = JSONDecoder()
            let apiData = try decoder.decode(Passes.self, from: data)
            return apiData
        } catch {
            // Handle errors
            print("Error getting passes: \(error.localizedDescription)")
            return nil
        }
    }
}
