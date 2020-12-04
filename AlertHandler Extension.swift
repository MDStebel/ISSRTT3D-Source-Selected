//
//  AlertHandler Extension.swift
//
//  Created by Michael Stebel on 11/9/15.
//  Copyright © 2016-2021 Michael Stebel Consulting, LLC. All rights reserved..
//

import UIKit


extension UIViewController: AlertHandler {
    
    ///  Convenience method to display a simple alert
    func alert(for title: String, message messageToDisplay: String) {
        
        let alertController = UIAlertController(title: title, message: messageToDisplay, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    /// Display alert if unable to connect to a server
    func cannotConnectToInternetAlert() {
        
        alert(for: "Can't connect to the server.", message: "Check your Internet connection\nand try again.")
        
    }
    
}
