//
//  ImageGeoData.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 11/5/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

struct ImageGeoData: Codable {
    public let country  : String
    public let latitude : Double
    public let longitude: Double
    public let region   : String
}

extension ImageGeoData {
    init( _ country: String,
          _ latitude: Double,
          _ longitude: Double,
          _ region:String ) {
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.region = region
    }
    
    static func instance(from data: Data?) -> ImageGeoData? {
        guard let data = data else { return nil }
        return try? JSONDecoder().decode(ImageGeoData.self, from: data)
    }
    
    public var data: Data {
        return try! JSONEncoder().encode(self) as Data
    }
}
