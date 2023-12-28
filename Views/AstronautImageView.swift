//
//  AstronautImageView.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/17/16.
//  Copyright © 2016-2024 ISS Real-Time Tracker. All rights reserved.
//

import UIKit

/// Custom ImageView for an astronaut
@IBDesignable
class AstronautImageView: UIImageView {
    
    
    // MARK: - Properties
    
    
    @IBInspectable var imageRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = imageRadius
        }
    }
    
    @IBInspectable var imageBackgroundColor: UIColor = .black {
        didSet {
            backgroundColor = imageBackgroundColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = .black {
        didSet{
            layer.borderColor = borderColor.cgColor
        }
    }
    
    //  To make a shadow appear on an image view, I need to create a container and put the image view inside it
    @IBInspectable var shadowColor: UIColor = .black {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 3.0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.6 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0, height: 3) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    
    // MARK: - Methods
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        contentMode = .scaleAspectFill
        layer.masksToBounds = true
        clipsToBounds = true
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}
