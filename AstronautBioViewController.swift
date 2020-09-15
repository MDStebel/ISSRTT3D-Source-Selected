//
//  AstronautBioViewController.swift
//  ISS Real-TimeTracker
//
//  Created by Michael Stebel on 7/10/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
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
        return .lightContent
    }
    
    private struct Constants {
        static let fontForTitle = Theme.nasa
    }
    
    
    // MARK: - Methods
    
    
    @IBAction private func reloadWebView(_ sender: AnyObject) {
        
        bioWebView.reload()
        
    } // reload web view
    
    
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
  
    } // end view did load
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        // Set font and attributes for navigation bar
        let titleFontSize = Globals.navigationBarTitleFontSize
        if let titleFont = UIFont(name: Constants.fontForTitle, size: titleFontSize) {
            let attributes = [NSAttributedString.Key.font: titleFont, .foregroundColor: UIColor.white]
            navigationController?.navigationBar.titleTextAttributes = attributes
            navigationController?.navigationBar.barTintColor = UIColor(named: Theme.tint)
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        loadWebView()
        
    } // end view did appear
    
    
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
        
    } // end load web view
    
    
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
