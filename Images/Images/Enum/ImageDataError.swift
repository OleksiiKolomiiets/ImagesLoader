//
//  ImageDataError.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/31/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

// MARK: image data error type

enum ImageDataError: Error {
    case missing(String)
    case invalid(String, Any)
}
