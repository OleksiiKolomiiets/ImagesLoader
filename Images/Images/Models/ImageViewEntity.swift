//
//  ImageViewEntity.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/27/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation
import UIKit

struct ImageViewEntity {
    let url: URL
    let title: String
    
    init(url: URL, title: String) {
        self.url = url
        self.title = title
    }
    
    init(json: [String : Any]) throws { 
        guard let urlString = json["url"] as? String else { throw ImageDataError.missing("Image URL is missing.")}
        guard let title = json["title"] as? String else { throw ImageDataError.missing("Image title is missing.")}
        guard let url = URL(string: urlString) else { throw ImageDataError.invalid("Image URL is invalid.", urlString)}
        self.url = url
        self.title = title
        
    }
    
    enum ImageDataError: Error {
        case missing(String)
        case invalid(String, Any)
    }
}
