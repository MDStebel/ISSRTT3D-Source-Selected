//
//  LiveVideoViewController.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 8/7/16.
//  Copyright © 2016-2022 ISS Real-Time Tracker. All rights reserved.
//

import UIKit
import WebKit

class LiveVideoViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    // MARK: - Properties
    
    
    /// Constants used in this class
    private struct Constants {
        static let segueToHelpFromVideo     = "segueToHelpFromStreamingVideo"
        static let fontForTitle             = Theme.nasa
    }
    
    
    /// Channel will be selected by caller during prepare for segue
    var channelSelected: LiveTVChoices.Channels = .liveEarth {
        didSet {
            helpTitle = "\(channelSelected.rawValue) Help"
        }
    }

    
    /// Selector containing the URL to access the JSON date containing the final URLs of the channels
    private var whichJSONFileToUse = LiveTVChoices.URLAlternatives.v9.rawValue
    
    
    /// Live video feed address
    private var videoURL    = ""
    
    private var helpTitle   = ""
    
    /// The web view
    private var webView: WKWebView! {
        didSet{
            webView.backgroundColor = UIColor(named: Theme.popupBgd)
        }
    }
    
    
    /// Alias for the function type used in callback
    typealias callBack = () -> ()
    
    
    // Change status bar to light color for this VC
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    
    // MARK: - Methods
    

    @IBAction private func refresh(_ sender: UIBarButtonItem) {
        webView.reload()
    }

    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setUpWebView()
        getHDEVUrl(then: loadWebView)       // Get URL of the stream from my website, and if successful, execute callback

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
    
    
    private func setUpWebView() {
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.mediaTypesRequiringUserActionForPlayback = .audio

        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
        
    }
    
        
    /// Retrieve address of desired channel.
    ///
    /// Gets HDEV URL to use from JSON data, then executes callback.
    /// - Parameter then: The completion handler method to call after we have the channel URL.
    private func getHDEVUrl(then completionHandler: @escaping callBack) {
        
        // Make sure we can create the URL
        guard let myJsonFile = URL(string: whichJSONFileToUse) else { return }
        
        let getURLTask = URLSession.shared.dataTask(with: myJsonFile) { (data, response, error) -> Void in
            if let unparsedData = data {
                
                // Call parser with data and if successful (not nil) copy crew member names to currentCrew string array and fill the table
                if let parsedURL = try? JSONDecoder().decode(LiveTVChoices.self, from: unparsedData) {
                    
                    switch self.channelSelected {
                    case .liveEarth :
                        self.videoURL = parsedURL.liveURL
                    case .nasaTv :
                        self.videoURL = parsedURL.nasatvURL
                    }
                    
                    completionHandler()                     // We've got the URL from JSON. Now call the completionHandler (the callback)
                    
                } else {
                    
                    DispatchQueue.main.async {
                        self.alert(for: "Can't receive video stream at this time.", message: "Tap Done, wait a few minutes, then try again.")
                    }
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                    self.cannotConnectToInternetAlert()
                }
                
            }
            
        }
        
        // Start task
        getURLTask.resume()
        
    }
    
    
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

    }
    
    
    private func loadWebView() {
        
        if let URL = URL(string: videoURL) {
            let urlRequest = URLRequest(url: URL)
            DispatchQueue.main.async {
                self.webView.load(urlRequest)                       // Load web page from the main queue
                
                // Only the live Earth view needs to present this popup
                if Globals.blackScreenInHDEVExplanationPopsUp && self.channelSelected == .liveEarth {
                    self.explainBlankScreenToUserPopup()
                }
            }
        } else {
            DispatchQueue.main.async {
                self.alert(for: "URL Error!", message: "Can't access video feed.")
            }
        }
        
    }
    

    // MARK: - WebKit Navigation Delegate Methods

    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        DispatchQueue.main.async {
            self.alert(for: "Navigation Error!", message: "Can't access video feed.")
        }
        
    }
    
    
    /// Prepare for seque
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // This guard statement prevents a crash if a segue is unnamed
        guard segue.identifier != nil else { return }
        
        switch segue.identifier {
        case Constants.segueToHelpFromVideo :
            
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.topViewController as! HelpViewController
            
            // Set the appropriate help content for the specific channel selected and pass it to the help VC
            switch channelSelected {
            case .liveEarth :
                destinationVC.helpContentHTML = UserGuide.streamingVideoHelp
            case .nasaTv :
                destinationVC.helpContentHTML = UserGuide.NASATVVideoHelp
            }
            
            destinationVC.helpButtonInCallingVCSourceView = navigationController.navigationBar
            destinationVC.title                           = helpTitle
            
        default :
            break
        }
        
    }
    
    
    /// Unwind segue
    @IBAction func unwindFromOtherVCs(unwindSegue: UIStoryboardSegue) {
        
    } 
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
