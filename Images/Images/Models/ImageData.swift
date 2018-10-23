//
//  ImageData
//  Images
//
//  Created by Oleksii  Kolomiets on 8/27/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

struct ImageData: Codable {
    let title       : String
    let urlSmall240 : URL
    let urlSmall320 : URL
    let urlLarge1024: URL
}

enum ImageDataError: Error, LocalizedError {
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "ImageData data invalid."
        }
    }
}
