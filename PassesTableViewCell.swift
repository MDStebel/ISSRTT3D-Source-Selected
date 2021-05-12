//
//  PassesTableViewCell.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 6/12/18.
//  Copyright © 2016-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


class PassesTableViewCell: UITableViewCell {
    
    
    // MARK: - Properties
    
    
    private let cornerRadius = Theme.cornerRadius
    

    // MARK: - Outlets
    
    
    @IBOutlet var cellBackground: UIView!
    
    @IBOutlet var passDate: PassDateUILabel!
    
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var magnitudeLabel: UILabel!
    
    @IBOutlet var startTime: UILabel!
    @IBOutlet var maxTime: UILabel!
    @IBOutlet var endTime: UILabel!
    
    @IBOutlet var startAz: UILabel!
    @IBOutlet var maxAz: UILabel!
    @IBOutlet var endAz: UILabel!
    
    @IBOutlet var startEl: UILabel!
    @IBOutlet var maxEl: UILabel!
    @IBOutlet var endEl: UILabel!
    
    @IBOutlet var startComp: UILabel!
    @IBOutlet var maxComp: UILabel!
    @IBOutlet var endComp: UILabel!
    
    @IBOutlet var ratingStarView: [UIImageView]!  // Array of stars for rating
    
    
    // MARK: - Methods
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
            passDate.textColor = UIColor(named: Theme.white)
            
        } else {
            
            cellBackground.backgroundColor = UIColor(named: Theme.popupBgd)
            passDate.textColor = UIColor(named: Theme.popupBgd)
            
        }
        
    } 

}
