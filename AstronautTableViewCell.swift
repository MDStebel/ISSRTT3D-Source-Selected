//
//  AstronautTableViewCell.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/16/16.
//  Copyright © 2016-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


/// Custom cell for crew table
class AstronautTableViewCell: UITableViewCell {
    
    
    // MARK: - Properties
    
    private let cornerRadius: CGFloat = 15.0
    
    
    // MARK: - Outlets
    
    @IBOutlet var cellBackgroundView: UIView!
    @IBOutlet var astronautImage: AstronautImageView!
    @IBOutlet var astronautName: UILabel!
    @IBOutlet var astronautInfo: UILabel!
    
    
    // MARK: - Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellBackgroundView.layer.cornerRadius = cornerRadius
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
