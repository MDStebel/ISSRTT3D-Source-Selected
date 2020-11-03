//
//  Animatable Table Protocol.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 10/10/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


/// Protocol that provides animation of cells in a table
protocol TableAnimatable: AnyObject {
    
    func animate(table tableToAnimate: UITableView)
    
}


extension TableAnimatable {
    
    /// Default implementation.
    ///
    /// Animates the drawing of a table such that it looks springy.
    func animate(table tableToAnimate: UITableView) {
        
        tableToAnimate.reloadData()
        
        let cells = tableToAnimate.visibleCells
        let tableViewHeight = tableToAnimate.bounds.size.height
        
        DispatchQueue.main.async {
            
            for cell in cells {
                cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
            }
            
            var delayCounter = 0
            for cell in cells {
                UIView.animate(withDuration: 1.75, delay: Double(delayCounter) * 0.08, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut,
                               animations: {cell.transform = CGAffineTransform.identity},
                               completion: nil)
                delayCounter += 1
            }
            
        }
        
    }
    
}
