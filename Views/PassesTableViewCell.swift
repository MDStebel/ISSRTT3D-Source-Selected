//
//  PassesTableViewCell.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 6/12/18.
//  Copyright © 2016-2022 ISS Real-Time Tracker. All rights reserved.
//

import UIKit

/// A card style custom cell for passes
class PassesTableViewCell: UITableViewCell {
        
    
    // MARK: - Properties
    
    
    private let cornerRadius = Theme.cornerRadius
    

    // MARK: - Outlets
    

    @IBOutlet var cellBackground: UIView!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var endAz: UILabel!
    @IBOutlet var endComp: UILabel!
    @IBOutlet var endEl: UILabel!
    @IBOutlet var endTime: UILabel!
    @IBOutlet var magnitudeLabel: UILabel!
    @IBOutlet var maxAz: UILabel!
    @IBOutlet var maxComp: UILabel!
    @IBOutlet var maxEl: UILabel!
    @IBOutlet var maxTime: UILabel!
    @IBOutlet var passDate: PassDateUILabel! {
        didSet {
            passDate.textAlignment = NSTextAlignment.center
        }
    }
    @IBOutlet var ratingStarView: [UIImageView]!            // Array of stars for rating
    @IBOutlet var startAz: UILabel!
    @IBOutlet var startComp: UILabel!
    @IBOutlet var startEl: UILabel!
    @IBOutlet var startTime: UILabel!
    @IBOutlet var stationIcon: UIImageView!
    
    
    // MARK: - Methods
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        passDate.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        passDate.layer.cornerRadius  = cornerRadius
        passDate.layer.masksToBounds = true
        
        cellBackground.layer.cornerRadius = cornerRadius
        cellBackground.layer.shadowColor = UIColor.black.cgColor
        cellBackground.layer.shadowRadius = 3.0
        cellBackground.layer.shadowOpacity = 0.6
        cellBackground.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            
            cellBackground.backgroundColor = UIColor(named: Theme.tint)
            passDate.textColor = UIColor(named: Theme.tblBgd)
            
        } else {
            
            cellBackground.backgroundColor = UIColor(named: Theme.popupBgd)
            passDate.textColor = UIColor(named: Theme.popupBgd)
            
        }
        
    } 

}
