//
//  HelpViewController.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 2/21/16.
//  Copyright © 2016-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit
import WebKit


class HelpViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    // MARK: - Properties
    
    
    /// During segue to this VC, the HTML content for the web view will be contained here
    var helpContentHTML = ""
    
    /// During segue to this VC, this variable will contain the source view of the help button
    var helpButtonInCallingVCSourceView = UIView()
    
    // Change status bar to light color for this VC
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private struct Constants {
        static let fontForTitle = Theme.nasa
    }
    
    
    // MARK: - Outlets
    
    
    @IBOutlet private var helpTextWebView: WKWebView!
    
    
    // MARK: - Methods
    
    
    private func setUpViewForHelp() {
        
        helpTextWebView.uiDelegate                   = self
        helpTextWebView.navigationDelegate           = self
        let webConfiguration                         = WKWebViewConfiguration()
        webConfiguration.preferences.minimumFontSize = 12.0
        helpTextWebView                              = WKWebView(frame: .zero, configuration: webConfiguration)
        view                                         = helpTextWebView
        
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set the target rectangle for the popover
        popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection([.up])
        popoverPresentationController?.sourceRect = CGRect(x: -1.00, y: 3.0, width: helpButtonInCallingVCSourceView.bounds.width, height: helpButtonInCallingVCSourceView.bounds.height)
        
        setUpViewForHelp()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        // Set font and attributes for navigation bar
        let titleFontSize = Theme.navigationBarTitleFontSize
        if let titleFont = UIFont(name: Constants.fontForTitle, size: titleFontSize) {
            let attributes = [NSAttributedString.Key.font: titleFont, .foregroundColor: UIColor.white]
            navigationController?.navigationBar.titleTextAttributes = attributes
            navigationController?.navigationBar.barTintColor = UIColor(named: Theme.tint)
        }
        
        // Show the help content
        helpTextWebView.loadHTMLString(helpContentHTML, baseURL: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
} 
