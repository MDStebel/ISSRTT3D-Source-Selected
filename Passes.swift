//
//  Passes.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 6/12/18.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import Foundation


/// Passes model using the n2yo.com API
struct Passes: Decodable {
    
    let info: Info
    let passes: [Pass]
    
    struct Info: Decodable {
        
        let satid: Int
        let satname: String
        let transactionscount: Int
        let passescount: Int
        
    }
    
    struct Pass: Decodable {
        
        let startAz: Double
        let startAzCompass: String
        let startEl: Double
        let startUTC: Double
        let maxAz: Double
        let maxAzCompass: String
        let maxEl: Double
        let maxUTC: Double
        let endAz: Double
        let endAzCompass: String
        let endEl: Double
        let endUTC: Double
        let mag: Double
        let duration: Int
        
    }
    
}
