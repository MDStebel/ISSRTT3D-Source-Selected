//
//  PassDateUILabel.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 6/13/18.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


/// Custom UILabel class adds rounded corners and a default background color
class PassDateUILabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor(named: Theme.lblBgd)
        
        let cornerRadius = frame.height / 2.0
        layer.cornerRadius = cornerRadius
        
    }
    
}
