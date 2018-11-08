//
//  ImageGeoAnnotation.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 11/7/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

import MapKit

class ImageGeoAnnotation: NSObject, MKAnnotation {
    
    // MARK: - Outlets:
    
    private let imageID: String
    
    public let title: String?
    public let markerIconURL: URL    
    public let coordinate: CLLocationCoordinate2D
    
    
    // MARK: - Constructor:
    
    init(with imageGeoData: ImageGeoData) {
        self.imageID = imageGeoData.imageID
        self.title = imageGeoData.country + ", " + imageGeoData.region
        self.coordinate = CLLocationCoordinate2D(latitude: imageGeoData.latitude, longitude: imageGeoData.longitude)
        self.markerIconURL = imageGeoData.iconURL
        
        super.init()
    }
}
