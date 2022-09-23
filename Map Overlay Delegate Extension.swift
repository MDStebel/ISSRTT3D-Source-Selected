//
//  Map Delegates.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 2/17/20.
//  Copyright © 2020-2022 ISS Real-Time Tracker. All rights reserved.
//

import MapKit
import UIKit

extension TrackingViewController {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer         = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(named: Theme.tint)?.withAlphaComponent(0.75)
        renderer.lineWidth   = 5.0
        renderer.lineCap     = .butt
        
        return renderer
        
    }
    
}
