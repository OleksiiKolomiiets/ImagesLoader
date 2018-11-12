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
    
    init(with imageData: ImageData) {
        self.imageID = imageData.id
        self.title = imageData.geoData!.country + ", " + imageData.geoData!.region
        self.coordinate = CLLocationCoordinate2D(latitude: imageData.geoData!.latitude, longitude: imageData.geoData!.longitude)
        self.markerIconURL = imageData.urlSmall75
        
        super.init()
    }
}
