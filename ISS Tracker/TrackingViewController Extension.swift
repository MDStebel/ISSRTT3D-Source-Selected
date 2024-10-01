//
//  TrackingViewController Extension.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 2/20/2024.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import UIKit
import MapKit

extension TrackingViewController {
    
    /// Update the info box data 
    private func updateCoordinatesDisplay() {
        DispatchQueue.main.async { [self] in
            altitudeLabel.text    = altString
            coordinatesLabel.text = positionString
            velocityLabel.text    = velString
        }
    }
    
    /// Draw orbit ground track line overlay
    private func drawOrbitGroundTrackLine() {
        appendCurrentCoordinate()
        
        guard Globals.orbitGroundTrackLineEnabled, listOfCoordinates.count >= 2 else { return }
        
        drawPolyline()
        removeExcessCoordinates()
    }

    private func appendCurrentCoordinate() {
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude) ?? 0.0, longitude: CLLocationDegrees(longitude) ?? 0.0)
        listOfCoordinates.append(coordinate)
    }

    private func drawPolyline() {
        let lastTwoCoordinates = Array(listOfCoordinates.suffix(2))
        let polyline = MKPolyline(coordinates: lastTwoCoordinates, count: lastTwoCoordinates.count)
        let polylineRenderer = MKPolylineRenderer(overlay: polyline)
        polylineRenderer.strokeColor = .blue
        polylineRenderer.fillColor = .blue
        map.addOverlay(polyline)
    }

    private func removeExcessCoordinates() {
        let maxCoordinates = 4
        if listOfCoordinates.count == maxCoordinates {
            listOfCoordinates.removeFirst(maxCoordinates - 1)
        }
    }
    
    /// Overlay delegate
    /// - Parameters:
    ///   - mapView: An MKMapView
    ///   - overlay: An MKOverlay
    /// - Returns: A renderer
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = colorForTarget(target)
        renderer.lineWidth = 5.0
        renderer.lineCap = .round
        return renderer
    }

    private func colorForTarget(_ target: StationsAndSatellites) -> UIColor {
        switch target {
        case .iss:
            return UIColor(named: Theme.issOrbitalColor) ?? .gray
        case .tss:
            return UIColor(named: Theme.tssOrbitalColor) ?? .gray
        case .hst:
            return UIColor(named: Theme.hubbleOrbitalColor) ?? .gray
        case .none:
            return UIColor(named: Theme.issOrbitalColor) ?? .gray
        }
    }
    
    /// Set up the overlays and any buttons that depend on the user's settings
    fileprivate func setUpAllOverlaysAndButtons() {
        
        DispatchQueue.main.async {
            
            self.setUpDisplayConfiguration()
            
            if Globals.zoomFactorWasResetInSettings {           // If reset was pressed in Settings, or if the zoom scale factor was changed, this flag will be set. So, reset zoom to default values for the selected scale factor and call zoomValueChanged method.
                self.setUpZoomSlider(usingSavedZoomFactor: false)
                self.zoomValueChanged(self.zoomSlider)
            }
            
            if Globals.showCoordinatesIsOn {
                self.displayInfoBox(true)
            } else {
                self.displayInfoBox(false)
            }
            
            if Globals.displayZoomFactorBelowMarkerIsOn {
                self.zoomFactorLabel.isHidden        = false
                self.setupZoomFactorLabel(self.timerValue)
            } else {
                self.zoomFactorLabel.isHidden        = true
            }
            
            if Globals.orbitGroundTrackLineEnabled {
                self.clearOrbitTrackButton.alpha     = 1.0
                self.clearOrbitTrackButton.isEnabled = true
            } else {
                self.clearOrbitTrackButton.alpha     = 0.60
                self.clearOrbitTrackButton.isEnabled = false
            }
            
            self.cursor.isHidden = false                        // Now, show the marker
        }
    }

    /// Update map and globe
    fileprivate func updateGlobeAndMapForPositionsOfStations() {
        
        DispatchQueue.main.async {
            
            self.setUpAllOverlaysAndButtons()
            
            // Update map position
            self.location = CLLocationCoordinate2DMake(CLLocationDegrees(self.latitude) ?? 0.0, CLLocationDegrees(self.longitude) ?? 0.0)
            self.span = MKCoordinateSpan.init(latitudeDelta: self.latDelta, longitudeDelta: self.lonDelta)
            self.region = MKCoordinateRegion.init(center: self.location, span: self.span)
            self.map.setRegion(self.region, animated: true)
                                    
            // Draw ground track, if enabled
            if Globals.orbitGroundTrackLineEnabled {
                self.drawOrbitGroundTrackLine()
            }
            
            // Update the coordinates and other data in the info box, if enabled
            if Globals.showCoordinatesIsOn {
                self.updateCoordinatesDisplay()
            }
            
            // Update mini globe with ISS position, footprint, and orbital track, if enabled.
            if Globals.displayGlobe {
                self.updateEarthGlobeScene(in: self.globe, hubbleLatitude: self.hLat, hubbleLongitude: self.hLon, issLatitude: self.iLat, issLongitude: self.iLon, tssLatitude: self.tLat, tssLongitude: self.tLon, hubbleLastLat: &self.hubbleLastLat, issLastLat: &self.issLastLat, tssLastLat: &self.tssLastLat)
                self.setUpCoordinatesLabel(withTopCorners: false)
                self.globeScene.isHidden        = false
                self.globeExpandButton.isHidden = false
                self.globeStatusLabel.isHidden  = false
            } else {
                self.setUpCoordinatesLabel(withTopCorners: true)
                self.globeScene.isHidden        = true
                self.globeExpandButton.isHidden = true
                self.globeStatusLabel.isHidden  = true
            }
        }
    }
    
    /// Locate satellite position and other data
    /// - Parameter satellite: The target satellite as a StationsAndSatellites object
    func locateSatellite(for satellite: StationsAndSatellites) {
        
        let satelliteCodeNumber = satellite.satelliteNORADCode
        
        /// Make sure we can create the URL from the endpoint and parameters
        guard let endpointURL = URL(string: Constants.generalEndpointString + "\(satelliteCodeNumber)/0/0/0/1/" + "&apiKey=\(Constants.generalAPIKey)") else { return }
        
        /// Task to get JSON data from API by sending request to API endpoint, parse response for position data, and then display positions.
        /// Uses a capture list to capture a weak reference to self. This should prevent a retain cycle and allow ARC to release instance and reduce memory load.
        let globeUpdateTask = URLSession.shared.dataTask(with: endpointURL) { [ self ] (data, response, error) in
            if let data {
                let decoder = JSONDecoder()
                do {
                    // Parse JSON
                    let parsedPosition = try decoder.decode(SatelliteOrbitPosition.self, from: data)
                    self.coordinates   = parsedPosition.positions
                    
                    switch satellite {
                    case .iss:
                        DispatchQueue.main.sync {
                            self.issLatitude            = self.coordinates[0].satlatitude
                            self.issLongitude           = self.coordinates[0].satlongitude
                            self.iLat                   = String(self.issLatitude)
                            self.iLon                   = String(self.issLongitude)
                            self.latitude               = String(self.issLatitude)
                            self.longitude              = String(self.issLongitude)
                            self.tssLatitude            = 0
                            self.tssLongitude           = 0
                            self.tLat                   = ""
                            self.tLon                   = ""
                            self.hubbleLatitude         = 0
                            self.hubbleLongitude        = 0
                            self.hLat                   = ""
                            self.hLon                   = ""
                            self.velocity               = "27540"
                        }
                    case .tss:
                        DispatchQueue.main.sync {
                            self.tssLatitude            = self.coordinates[0].satlatitude
                            self.tssLongitude           = self.coordinates[0].satlongitude
                            self.tLat                   = String(self.tssLatitude)
                            self.tLon                   = String(self.tssLongitude)
                            self.latitude               = String(self.tssLatitude)
                            self.longitude              = String(self.tssLongitude)
                            self.issLatitude            = 0
                            self.issLongitude           = 0
                            self.iLat                   = ""
                            self.iLon                   = ""
                            self.hubbleLatitude         = 0
                            self.hubbleLongitude        = 0
                            self.hLat                   = ""
                            self.hLon                   = ""
                            self.velocity               = "27648"
                        }
                    case .hst:
                        DispatchQueue.main.sync {
                            self.hubbleLatitude         = self.coordinates[0].satlatitude
                            self.hubbleLongitude        = self.coordinates[0].satlongitude
                            self.hLat                   = String(self.hubbleLatitude)
                            self.hLon                   = String(self.hubbleLongitude)
                            self.latitude               = String(self.hubbleLatitude)
                            self.longitude              = String(self.hubbleLongitude)
                            self.issLatitude            = 0
                            self.issLongitude           = 0
                            self.iLat                   = ""
                            self.iLon                   = ""
                            self.tssLatitude            = 0
                            self.tssLongitude           = 0
                            self.tLat                   = ""
                            self.tLon                   = ""
                            self.velocity               = "27360"
                        }
                    case .none:
                        return
                    }                    
                    
                    self.altitude      = String(self.coordinates[0].sataltitude)
                    self.atDateAndTime = String(self.coordinates[0].timestamp)
                    
                    // Update positions and info box
                    self.updateGlobeAndMapForPositionsOfStations()
                    
                } catch {
                    
                    // If parsing fails
                    DispatchQueue.main.async {
                        self.stopAction()
                        self.alert(for: "Can't get ISS location", message: "Wait a few minutes\nand then tap ▶︎ again.")
                    }
                }
            } else {
                
                // If can't access API
                DispatchQueue.main.async {
                    self.stopAction()
                    self.cannotConnectToInternetAlert()
                }
            }
        }
        
        globeUpdateTask.resume()
    }
}
