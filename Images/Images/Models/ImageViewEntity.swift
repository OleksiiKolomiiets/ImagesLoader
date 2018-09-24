//
//  ImageViewEntity.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/27/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

struct ImageViewEntity: Codable {
    
    // MARK: - Variables
    let url: URL
    let title: String
    let photoID: String
    let server: String
    let secret: String
    let farm: Int
    
    enum codingKeys: String, CodingKey {
        case title
        case photoID = "id"
        case server
        case secret
        case farm
    }
    
    // MARK: - Functions
    // Constructor to create instance using dictionary from api and existing url
    init(from dictionary: [String: Any], with url: URL) {
        self.url = url
        self.title = dictionary["title"] as! String
        self.photoID = dictionary["id"] as! String
        self.server = dictionary["server"] as! String
        self.secret = dictionary["secret"] as! String
        self.farm = dictionary["farm"] as! Int
    }
}

