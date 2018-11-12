//
//  ImageData
//  Images
//
//  Created by Oleksii  Kolomiets on 8/27/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

struct ImageData: Codable {
    let id          : String
    let title       : String
    let urlSmall75  : URL
    let urlSmall240 : URL
    let urlSmall320 : URL
    let urlLarge1024: URL
    var geoData     : ImageGeoData?
    
    init(id: String, title: String, urlSmall75: URL, urlSmall240: URL, urlSmall320: URL, urlLarge1024: URL, geoData: ImageGeoData? = nil ) {
        self.id           = id
        self.title        = title
        self.urlSmall75   = urlSmall75
        self.urlSmall240  = urlSmall240
        self.urlSmall320  = urlSmall320
        self.urlLarge1024 = urlLarge1024
        self.geoData      = geoData
    }
}

extension ImageData {    
    public var data: Data {
        return try! JSONEncoder().encode(self) as Data
    }
    
    static public func instance(from jsonData: Data) -> ImageData {
        return try! JSONDecoder().decode(ImageData.self, from: jsonData)
    }
    
    static public func instance(from coreDataEntity: FavoriteImage) -> ImageData {
        return ImageData(id          : coreDataEntity.id!,
                         title       : coreDataEntity.title!,
                         urlSmall75  : coreDataEntity.urlSmall75!,
                         urlSmall240 : coreDataEntity.urlSmall240!,
                         urlSmall320 : coreDataEntity.urlSmall320!,
                         urlLarge1024: coreDataEntity.urlLarge1024!,
                         geoData     : ImageGeoData.instance(from: coreDataEntity.geoData))
    }
    
}

extension ImageData: Equatable {
    public static func ==(lhs: ImageData, rhs: ImageData) -> Bool {
        return lhs.id == rhs.id
    }
}
