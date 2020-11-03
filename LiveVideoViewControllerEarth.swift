//
//  LiveVideoViewController.swift
//  ISS Tracker
//
//  Created by Michael Stebel on 8/7/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit
import WebKit


class LiveVideoViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    
    // MARK: - Types
    
    
    /// Alternative URLs containing my JSON file each of which contain the URL of the video stream to use
    private enum URLAlternatives: String {
        case v1 = "https://issrttapi.com/EHDC-Video-Location.json"
        case v5 = "https://truvisibility.com/file/get/f1054605-3d5c-4c9e-aaaa-a8fa005ac9ac/issrtt-hdev.json"
        case v6 = "https://truvisibility.com/file/get/0b38bbb2-137d-4356-95c3-a90301212362/issrtt-hdev.json"
        case v7 = "https://issrttapi.com/LiveTVURLs.json"
    }
    
    enum channel {
        case nasaTV
        case liveEarth
    }
    
    /* Note: These are the available URLS that can be used in my JSON files:
            http://www.ustream.tv/embed/17074538?v=3&wmode=direct
            https://www.ustream.tv/embed/17074538?html5ui;autoplay=1
    */
    
    private struct Constants {
        static let segueToHelpFromVideo     = "segueToHelpFromStreamingVideo"
        static let fontForTitle             = Globals.themeFont
    }
    
    // MARK: - Properties
    
    /// Channel will be selected during segue
    var channelSelected: channel = .liveEarth
    
    
    /// Live video feed address
    private var videoURL = ""
    
    /// Selector containing the URL to access will be
    private var whichJsonFileToUse = URLAlternatives.v7.rawValue
    
    /// The web view
    private var webView: WKWebView! {
        didSet{
            webView.backgroundColor = UIColor(named: "Pop-Up and Tab Bar Background")
        }
    }
    
    /// Define type for callback function
    typealias callBack = () -> ()
    
    // Change status bar to light color for this VC
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    // MARK: - Methods
    

    @IBAction private func refresh(_ sender: UIBarButtonItem) {
        
        webView.reload()
        
    } // end refresh

    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupWebView()
        getHDEVUrl(then: loadWebView)       // Get URL of the stream from my website and if successful, execute callback

    } // end view did load
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        // Set font and attributes for navigation bar
        let titleFontSize = Globals.navigationBarTitleFontSize
        if let titleFont = UIFont(name: Constants.fontForTitle, size: titleFontSize) {
            let attributes = [NSAttributedString.Key.font: titleFont, .foregroundColor: UIColor.white]
            navigationController?.navigationBar.titleTextAttributes = attributes
            navigationController?.navigationBar.barTintColor = UIColor(named: "Tint")
        }
    } // end view will appear
    
    
    private func setupWebView() {
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.mediaTypesRequiringUserActionForPlayback = .audio

        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
        
    } // end setup web view
    
        
    // Get HDEV URL to use from JSON data, then execute callback
    private func getHDEVUrl(then completionHandler: @escaping callBack ) {
        
        // Make sure we can create the URL
        guard let myJsonFile = URL(string: whichJsonFileToUse) else { return }
        
        let getURLTask = URLSession.shared.dataTask(with: myJsonFile) { (data, response, error) -> Void in
            if let unparsedData = data {

                // Call parser with data and if successful (not nil) copy crew member names to currentCrew string array and fill the table
                if let parsedURL = try? JSONDecoder().decode(LiveTVChoices.self, from: unparsedData) {
                    
                    switch self.channelSelected {
                    case .liveEarth :
                        self.videoURL = parsedURL.liveURL
                    case .nasaTV :
                        self.videoURL = parsedURL.nasatvURL
                    }
                    
                    completionHandler()                     // We got it! Now call completionHandler (callback)
                    
                } else {
                    
                    DispatchQueue.main.async {
                        self.alert(for: "Can't receive video stream at this time.", message: "Tap Done, wait a few minutes, then try again.")
                    } // end of GCD closure
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                    self.cannotConnectToInternetAlert()
                } // end of GCD closure
                
            }
            
        }  // end of dataTaskWithURL closure
        
        // Start task
        getURLTask.resume()
        
    } // end get HDEV URL
    
    
    private func explainBlankScreenToUserPopup() {
        
        let alertController = UIAlertController(title: "See a Blank Screen?", message: "If your screen is blank, then NASA is not currently streaming live video. Try later. Tap the help button on the upper-right for more information.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        let dontShowAgainAction = UIAlertAction(title: "Don't Show This Again", style: .default) { (dontShow) in
            Globals.blackScreenInHDEVExplanationPopsUp = false
            }
        
        alertController.addAction(okAction)
        alertController.addAction(dontShowAgainAction)
        alertController.preferredAction = okAction
        present(alertController, animated: true, completion: nil)

    } // end explain black screen popup
    
    
    private func loadWebView() {
        
        if let URL = URL(string: videoURL) {
            
            let urlRequest = URLRequest(url: URL)
            
            DispatchQueue.main.async {
                self.webView.load(urlRequest)                       // Load web page from the main queue
                if Globals.blackScreenInHDEVExplanationPopsUp && self.channelSelected != .nasaTV {
                    self.explainBlankScreenToUserPopup()
                }
            }
            
        } else {
            DispatchQueue.main.async {
                self.alert(for: "URL Error!", message: "Can't access video feed.")
            }
        }
        
    } // end load web view
    

    // MARK: - WebKit Navigation Delegate Methods

    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        DispatchQueue.main.async {
            self.alert(for: "Navigation Error!", message: "Can't access video feed.")
        }
        
    } // end delegate method
    
    
    /// Prepare for seque
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier != nil else { return }                                     // Prevents crash if a segue is unnamed
        
        switch segue.identifier {
            
        case Constants.segueToHelpFromVideo :
            
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.topViewController as! HelpViewController
            destinationVC.helpContentHTML = UserGuide.streamingVideoHelp
            destinationVC.helpButtonInCallingVCSourceView = navigationController.navigationBar
            
        default :
            
            break
            
        }
        
    } // end prepare for segue
    
    
    /// Unwind segue
    @IBAction func unwindFromOtherVCs(unwindSegue: UIStoryboardSegue) {
        
    } // End unwind
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
