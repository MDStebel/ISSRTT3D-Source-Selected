//
//  AstronautBioViewController.swift
//  ISS Real-TimeTracker
//
//  Created by Michael Stebel on 7/10/16.
//  Copyright © 2016-2022 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit
import WebKit

class AstronautBioViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    // MARK: - Properties
    
    
    /// Activity indicator
    private let spinner = UIActivityIndicatorView()
    
    /// The web view
    private var bioWebView: WKWebView!
    
    /// String representation of bio URL. Will be set by CrewMembersTableViewController during its prepareForSegue.
    var bioURL = ""
    
    private let spinnerWidthAndHeight: CGFloat = 37
    
    // Change status bar to light color for this VC
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private struct Constants {
        static let fontForTitle = Theme.nasa
    }
    
    
    // MARK: - Methods
    
    
    @IBAction private func reloadWebView(_ sender: AnyObject) {
        bioWebView.reload()
    }
    
    
    private func setupSpinner() {
        
        // Set up spinner
        spinner.hidesWhenStopped = true
        
        if #available(iOS 13.0, *) {
            spinner.style = UIActivityIndicatorView.Style.large
        } else {
            spinner.style = .whiteLarge
        }
        
        spinner.color = UIColor(red: 1, green: 0.298, blue: 0.298, alpha: 1)
        let xPos = view.bounds.size.width / 2 - spinnerWidthAndHeight / 2
        let yPos = view.bounds.size.height / 2 - spinnerWidthAndHeight / 2
        spinner.frame = CGRect(x: xPos, y: yPos, width: spinnerWidthAndHeight, height: spinnerWidthAndHeight)
        
    }
    
    
    private func setupWebViewForBio() {
        
        // Set up webkit view
        let webConfiguration = WKWebViewConfiguration()
        bioWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        bioWebView.uiDelegate = self
        bioWebView.navigationDelegate = self
        bioWebView.addSubview(spinner)      // Add spinner to web view
        view = bioWebView                   // Set view to web view
        
    }
    
    
    override func viewDidLoad() {

        super.viewDidLoad()

        setupSpinner()
        setupWebViewForBio()
  
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        // Set navigation and status bar font and color to our Theme
        let titleFontSize                   = Theme.navigationBarTitleFontSize
        let barAppearance                   = UINavigationBarAppearance()
        barAppearance.backgroundColor       = UIColor(named: Theme.tint)
        barAppearance.titleTextAttributes   = [.font : UIFont(name: Constants.fontForTitle, size: titleFontSize) as Any, .foregroundColor : UIColor.white]
        navigationItem.standardAppearance   = barAppearance
        navigationItem.scrollEdgeAppearance = barAppearance
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        loadWebView()
        
    }
    
    
    private func loadWebView() {
        
        if let URL = URL(string: bioURL) {
            
            let urlRequest = URLRequest(url: URL)
            
            DispatchQueue.main.async {
                self.bioWebView.load(urlRequest)        // Load web page
            }
            
        } else {
            
            DispatchQueue.main.async {
                self.alert(for: "Error!", message: "Bad Web Address")
            }
            
        }
        
    }
    
    
    // MARK: - WebKit Delegates
    

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        DispatchQueue.main.async {
            self.spinner.startAnimating()
        }
        
    }

    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
        }
        
    }

    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        DispatchQueue.main.async {
            self.alert(for: "Navigation Error!", message: "Couldn't access web page.")
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        dismiss(animated: true, completion: nil)
        
    }

}
