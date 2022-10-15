//
//  String Extensions.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 5/11/19.
//  Copyright © 2016-2022 ISS Real-Time Tracker. All rights reserved.
//

import Foundation

extension String {
    
    /// Delete a prefix sustring from the beginning of a string.
    /// Checks that prefix substring exists.
    /// - Parameter prefix: Substring to remove.
    /// - Returns: New string.
    func deletingPrefix(_ prefix: String) -> String {
        
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
        
    }
}
