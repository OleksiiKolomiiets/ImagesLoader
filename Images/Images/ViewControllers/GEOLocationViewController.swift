//
//  GEOLocationViewController.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 11/5/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class GEOLocationViewController: UIViewController {
    
    
    // MARK: - Outlets:
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - Properties:
    
    public var imageGeoData: ImageGeoData!    
    
    
    // MARK: - Lifecycle methods of view cintroller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.title = imageGeoData.country + " - " + imageGeoData.region
        pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: imageGeoData.latitude, longitude: imageGeoData.longitude)
        mapView.setCenter(pointAnnotation.coordinate, animated: true)
        mapView.addAnnotation(pointAnnotation)
    }
    
    
    // MARK: - Actions:
    
    @IBAction func doneButtonTouched(_ sender: UIButton) {
        print(imageGeoData)
        self.dismiss(animated: true)
    }
}
