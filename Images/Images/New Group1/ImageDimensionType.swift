//
//  ImageDimensionType.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 9/14/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import FlickrKit

enum ImageDimensionType {
    
    case small
    case large
    
    var size: FKPhotoSize {
        switch self {
        case .small:
            return .small240
        case .large:
            return .medium640
        }
    }
}
