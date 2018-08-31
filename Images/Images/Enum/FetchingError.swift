//
//  FetchingError.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/31/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

// MARK: fetching error type

enum FetchingError: Error {
    case invalidData(String, Any)
}
