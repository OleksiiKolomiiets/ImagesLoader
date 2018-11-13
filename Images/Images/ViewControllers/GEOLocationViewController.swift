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
    
    @IBOutlet weak var mapView: ImagesMapView!
    
    
    // MARK: - Properties:
    
    public var imagesData: [ImageData]!
    
    
    // MARK: - Lifecycle methods of view cintroller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.setUpMapView(with: imagesData)
    }
    
    
    // MARK: - Actions:
    
    @IBAction func doneButtonTouched(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
