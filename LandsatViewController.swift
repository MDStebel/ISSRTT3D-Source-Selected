//
//  LandsatViewController.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 5/20/16.
//  Copyright © 2016-2020 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit

class LandsatViewController: UIViewController {
    
    
    // MARK: - Types
    
    
    /// Constants
    private struct Constants {
        static let maxCloudScoreToShowImage             = 0.80
        static let segueToHelpFromLandsat               = "segueToHelpFromLandsat"
        static let fontForTitle                         = "Nasalization"
        static let landsatImageDateForcingParameter     = "2017-04-15"
    }
    
    
    // MARK: - Properties
    
    
    /// NASA Landsat 8 imagery API endpoint
    private let baseURLForLandsat                = "https://api.nasa.gov/planetary/earth/imagery/"
    
    /// API key from NASA
    private let APIKey                           = "dvPOzpsnRkbye6ZB2Xle0d0pWMLZDk3QHIO1jAeo"
    
    private let originalDateFormatUsedInJSONData = "yyyy-MM-dd'T'HH:mm:ss"
    private var dimParameter                     = ""
    private var dateFormatter                    = DateFormatter()
    
    /// This will be set to true if user selects to show a high cloud cover image to allow one-off display of image without enabling "allow high cloud cover images."
    private var allowHighCloudsThisTimeOnly      = false
    
    /// Current map longitude will be passed from TrackingViewController during prepare for segue
    var currentLong                                  = ""
    
    /// Current map latitude will be passed from TrackingViewController during prepare for segue
    var currentLat                                   = ""
    
    /// Position string will be passed from from TrackingViewController during prepare for segue
    var positionString                               = ""
    
    // Change status bar to light color for this VC
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: - Outlets
    
    
    @IBOutlet private var changeLandsatImageScaleButton: UIBarButtonItem!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var spinner: UIActivityIndicatorView!
    @IBOutlet private var landsat8MetadataLabel: UILabel! {
        didSet {
            landsat8MetadataLabel.layer.maskedCorners   = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            landsat8MetadataLabel.layer.cornerRadius    = 27
            landsat8MetadataLabel.layer.masksToBounds   = true
            
        }
    }
    @IBOutlet private var saveImagePromptLabel: UILabel! {
        didSet {
            saveImagePromptLabel.isHidden = true
        }
    }
    
    
    // MARK: - Methods
    
    
    private func setupDimensionParameter() {
        dimParameter = Globals.landsatImageScaleDictionary[Globals.landsatImageScaleSelectedSegment] ?? Globals.landsatImageScaleDictionary[Globals.landsatImageScaleDefaultSegment] ?? "0.5"
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        spinner.hidesWhenStopped = true
        setupDimensionParameter()
        getLandsat8ImageAtLocation()

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
    }
    
    
    @IBAction func changeImageScaleButton(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Change Image Scale", message: "Change image scale this time only by selecting below, or change for next time in Settings.", preferredStyle: .actionSheet)
        
        // Add image scale selections from the dictionary with action
        for i in 0..<Globals.landsatImageScaleDictionary.count {
            alertController.addAction(UIAlertAction(title: "\(Globals.landsatImageScaleDictionary[i]!)°", style: .default) { (choice) in
                self.dimParameter = Globals.landsatImageScaleDictionary[i]!
                self.getLandsat8ImageAtLocation()
                }
            )
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.popoverPresentationController?.barButtonItem = changeLandsatImageScaleButton
        
        self.present(alertController, animated: true, completion: nil)
        
    } // end change image scale button
    
    
    /// If the user tapped on the image, save it to their photo library
    @IBAction func userTappedImage(_ sender: UITapGestureRecognizer) {
        
        saveImageToCameraRoll()
        
    } // end user tapped image
    
    
    /// If the user tapped the button, save the image to their photo library
    private func saveImageToCameraRoll() {
        
        if let imageToBeSaved = imageView.image {       // If there's an image, save it
            saveImage(imageToBeSaved)
        }
        
    } // end save image button
    
    
    /// Method to save image to the photo library. Will point to a selector to alert user of success/failure of save.
    private func saveImage(_ imageToBeSaved: UIImage) {
        
        spinner.startAnimating()                         // Start spinner
        
        UIImageWriteToSavedPhotosAlbum(imageToBeSaved, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    } // end save image
    
    
    /// Will be called by the selector in UIImageWriteToSavedPhotosAlbum upon return
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        
        defer { spinner.stopAnimating() }                // When done, successful or not, stop spinner
        
        if error == nil {
            alert(for: "Landsat 8 Image Saved!", message: "The image is now in your photo library.")
            return
        } else {
            alert(for: "Error saving image to photo library!", message: "Make sure ISS Real-Time Tracker has access to Photos in Settings.")
        }
        
    } // end did finish saving with error selector
    
    
    private func presentTooMuchCloudCoverPopup() {
        
        let alertController = UIAlertController(title: "Too much\ncloud cover in image", message: "Try again when the ISS is over\nanother area or turn on\nhigh cloud cover images\nin Settings.", preferredStyle: .alert)
        
        let showAnywayAction = UIAlertAction(title: "Show anyway", style: .default) { (showAnywayAction) in
            self.allowHighCloudsThisTimeOnly = true
            self.getLandsat8ImageAtLocation()
        }
        
        let dontShowAction = UIAlertAction(title: "Don't Show", style: .default) { (dontShow) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(showAnywayAction)
        alertController.addAction(dontShowAction)
        alertController.preferredAction = dontShowAction
        
        self.present(alertController, animated: true, completion: nil)
        
    } // end present too much cloud cover popup
    
    
    private func presentErrorGettingImagePopup() {
        
        let alertController = UIAlertController(title: "Error getting image", message: "There was a problem reading the image data.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Back", style: .default) { (dontShow) in
            self.dismiss(animated: true, completion: nil)
            }
        )
        
        self.present(alertController, animated: true, completion: nil)
        
    } // end present error getting image popup
    
    
    private func presentNoImageAtThisLocationPopup() {
        
        let alertController = UIAlertController(title: "Landsat 8 imagery is not available for this map location", message: "Try again when the ISS is over another area. Landsat 8 images are available for most land or coastal areas.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Back", style: .default) { (dontShow) in
            self.dismiss(animated: true, completion: nil)
            }
        )
        
        self.present(alertController, animated: true, completion: nil)
        
    } // end present no image at this location popup
    
    
    /// Get a Landsat 8 image, if available, from current map location
    private func getLandsat8ImageAtLocation() {
        
        DispatchQueue.main.async {                      // Start the spinner, hide the image save prompt and display message in header
            self.spinner.startAnimating()
            self.saveImagePromptLabel.isHidden = true
            self.landsat8MetadataLabel.text = "Searching For Image..."
        }
        
        // Create API URL request from endpoint, if not succesful return
        // IMPORTANT Note: on June 9, 2017, hard-coded date with known image availability for most places into URL request. Remove this when Landsat DB is updated!
        guard let URL = URL(string: baseURLForLandsat + "?lon=\(currentLong)&lat=\(currentLat)&date=\(Constants.landsatImageDateForcingParameter)&dim=\(dimParameter)&cloud_score=True&api_key=\(APIKey)") else { return }
        
        let imageryTask = URLSession.shared.dataTask(with: URL) { (data, response, error) -> Void in
            
            if let urlContent = data {
                
                // Call parser with data and if successful (not nil) copy image URL and image date to string array
                if let parsedLandsat8Image = JSONParser.shared.parseLandsat8Imagery(urlContent) {
                    
                    // If settings allow for displaying high cloud cover images, or if cloud score is under the limit, display it
                    if Globals.displayHighCloudCoverImages || self.allowHighCloudsThisTimeOnly || Double(parsedLandsat8Image.cloudScore) <= Constants.maxCloudScoreToShowImage {
                        
                        // Set up URL request with URL of Landsat 8 image
                        let imageURL = Foundation.URL(string: parsedLandsat8Image.imageURL)
                        
                        // Format date using converter
                        let imageDate = self.dateFormatter.convert(from: parsedLandsat8Image.captureDate, fromStringFormat: self.originalDateFormatUsedInJSONData, toStringFormat: Globals.outputDateFormatString) ?? parsedLandsat8Image.captureDate
                        
                        // Get image at URL
                        if let landsatImage = try? Data(contentsOf: imageURL!) {
                            
                            DispatchQueue.main.async {
                                
                                // Display image
                                self.imageView.image = UIImage(data: landsatImage)
                                
                                // Display image capture date in header bar
                                self.landsat8MetadataLabel.text = "\(self.positionString)  Scale: \(self.dimParameter)°\n Captured: \(imageDate)  Cloud: \(round(parsedLandsat8Image.cloudScore * 100))%"
                                
                                // Task is finished, so stop spinner and show the save image prompt
                                self.spinner.stopAnimating()
                                self.saveImagePromptLabel.isHidden = false
                                
                            } // end of GCD closure
                            
                        } else {
                            
                            DispatchQueue.main.async {
                                
                                // Task failed, so stop spinner
                                self.spinner.stopAnimating()
                                self.presentErrorGettingImagePopup()
                                self.landsat8MetadataLabel.text = "No Image Data"
                                
                            } // end of GCD closure
                            
                        }
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            
                            // Too much cloud cover, so display alert message with instructions for user
                            self.spinner.stopAnimating()
                            self.presentTooMuchCloudCoverPopup()
                            self.landsat8MetadataLabel.text = "High Cloud Cover (\(round(parsedLandsat8Image.cloudScore * 100))%)"
                            
                        } // end of GCD closure
                        
                    }
                    
                } else {
                    
                    DispatchQueue.main.async {
                        
                        // Task failed, so stop spinner
                        self.spinner.stopAnimating()
                        self.presentNoImageAtThisLocationPopup()
                        self.landsat8MetadataLabel.text = "No Image Available"
                        
                    } // end of GCD closure
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                    
                    // Task failed, so stop spinner
                    self.spinner.stopAnimating()
                    self.cannotConnectToInternetAlert()
                    self.landsat8MetadataLabel.text = "Could Not Connect to NASA"
                    
                } // end of GCD closure
                
            }
            
        }  // end of dataTaskWithURL closure
        
        
        // Start task
        imageryTask.resume()
        
        
    } // end get Landsat 8 image
    
    
    /// Prepare for seque
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier != nil else { return }                                     // Prevents crash if a segue is unnamed
        
        switch segue.identifier {
            
        case Constants.segueToHelpFromLandsat :

            DispatchQueue.main.async {
                self.spinner.startAnimating()
            }
            
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.topViewController as! HelpViewController
            destinationVC.helpContentHTML = UserGuide.landsatImageHelp
            destinationVC.helpButtonInCallingVCSourceView = navigationController.navigationBar

            DispatchQueue.main.async {
                self.spinner.stopAnimating()
            }
            
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
    
    
} // end vc
