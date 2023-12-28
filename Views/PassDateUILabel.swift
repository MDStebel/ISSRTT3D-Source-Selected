//
//  PassDateUILabel.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 6/13/18.
//  Copyright © 2016-2024 ISS Real-Time Tracker. All rights reserved.
//

import UIKit

/// Custom UILabel class adds a default background color
class PassDateUILabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor(named: Theme.lblBgd)
        
    }
    
}
