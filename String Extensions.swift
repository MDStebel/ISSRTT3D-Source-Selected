//
//  String Extensions.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 5/11/19.
//  Copyright © 2019-2020 Michael Stebel Photography, LLC. All rights reserved.
//

import Foundation

extension String {
    
    /// Method to delete a prefix string from the beginning of a string
    func deletingPrefix(_ prefix: String) -> String {
        
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
        
    }
    
}
