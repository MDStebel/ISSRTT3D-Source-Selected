//
//  Animatable Table Protocol.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 10/10/16.
//  Copyright © 2016-2024 ISS Real-Time Tracker. All rights reserved.
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
    /// - Parameter tableToAnimate: Table to animate.
    func animate(table tableToAnimate: UITableView) {
        
        tableToAnimate.reloadData()
        
        let cells = tableToAnimate.visibleCells
        let tableViewHeight = tableToAnimate.bounds.size.height
        
        DispatchQueue.main.async {
            var delayCounter = 0
            for cell in cells {
                cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
                UIView.animate(withDuration: 1.75, delay: Double(delayCounter) * 0.08, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut,
                               animations: {cell.transform = CGAffineTransform.identity},
                               completion: nil)
                delayCounter += 1
            }
        }
    }
}
