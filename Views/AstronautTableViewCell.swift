//
//  AstronautTableViewCell.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/16/16.
//  Copyright © 2016-2024 ISS Real-Time Tracker. All rights reserved.
//

import UIKit

/// A card-style custom cell for crew table
class AstronautTableViewCell: UITableViewCell {
    
    
    // MARK: - Properties
    
    
    private let cornerRadius = Theme.cornerRadius
    
    
    // MARK: - Outlets
    
    
    @IBOutlet var cellBackgroundView: UIView!
    @IBOutlet var astronautImage: AstronautImageView!
    @IBOutlet var astronautName: UILabel!
    @IBOutlet var astronautInfo: UILabel!
    @IBOutlet weak var headerBackground: UIView! {
        didSet {
            headerBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            headerBackground.layer.cornerRadius  = Theme.cornerRadius
            headerBackground.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var spacecraftWatermark: UIImageView!
    
    
    // MARK: - Methods
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellBackgroundView.layer.cornerRadius = cornerRadius
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
