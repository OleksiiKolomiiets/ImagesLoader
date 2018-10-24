//
//  ImageDimensionType.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 9/14/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import FlickrKit

enum ImageDimensionType {
    
    case small240
    case small320
    case large
    
    var flickerPhotoSize: FKPhotoSize {
        
        switch self {
        case .small240:
            return .small240
        case .small320:
            return .small320
        case .large:
            return .large1024
        }
    }
}
