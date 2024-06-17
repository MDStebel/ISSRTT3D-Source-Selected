//
//  PassesViewModel.swift
//  ISS Watch
//
//  Created by Michael Stebel on 6/5/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import CoreLocation
import Foundation
import SwiftUI

@Observable
final class PassesViewModel: ObservableObject {
    
    // MARK: Published properties
    
    var predictedPasses = [Passes.Pass]()
    var isComputing = false
    var noradID: String = ""
    
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
        
        struct Constants {
            static let noRatingStar      = #imageLiteral(resourceName: "star-unfilled")
            static let ratingStar        = #imageLiteral(resourceName: "star")
            static let unknownRatingStar = #imageLiteral(resourceName: "unknownRatingStar")
        }
        
        if magnitude != RatingSystem.unknown.rawValue {
            return RatingSystem.numberOfRatingStars(for: magnitude)
        } else {
            return nil
            //            for star in 0..<totalStars {
            //                cell.ratingStarView[star].image = Constants.unknownRatingStar
            //                cell.ratingStarView[star].alpha = 0.15
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
        let URLrequestString = endpointForPassesAPI + "\(stationID)/\(lat)/\(lon)/\(altitude)/\(numberOfDays)/\(minObservationTime)/&apiKey=\(apiKey)"
        guard let url = URL(string: URLrequestString) else {
            return nil
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let apiData = try decoder.decode(Passes.self, from: data)
            return apiData
        } catch {
            print("Error getting passes: \(error.localizedDescription)")
            return nil
        }
    }
}
