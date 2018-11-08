//
//  ImageGeoData.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 11/5/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

struct ImageGeoData {
    public let imageID  : String
    public let country  : String
    public let latitude : Double
    public let longitude: Double
    public let region   : String
    public let iconURL  : URL
}

extension ImageGeoData {
    init(with imageData: ImageData, _ country: String, _ latitude: Double,  _ longitude: Double,  _ region:String ) {
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.region = region
        
        imageID = imageData.id
        iconURL = imageData.urlSmall75
    }
}
