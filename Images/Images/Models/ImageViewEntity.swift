//
//  ImageViewEntity.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/27/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

struct ImageViewEntity {    
    
    // MARK: - Variables:
    let url     : URL
    let title   : String
    let photoID : String
    let server  : String
    let secret  : String
    let farm    : Int
    
     // Enumaration for existing feilds(keys in api response dictionry)
    enum KeyType: String {
        case title
        case photoID = "id"
        case server
        case secret
        case farm
    }
    
    // MARK: - Function:    
    // Constructor to create instance using dictionary from api and existing url
    init(from dictionary: [String: Any], with url: URL) {
        self.url = url
        
        self.title      = dictionary[KeyType.title.rawValue]    as! String
        self.photoID    = dictionary[KeyType.photoID.rawValue]  as! String
        self.server     = dictionary[KeyType.server.rawValue]   as! String
        self.secret     = dictionary[KeyType.secret.rawValue]   as! String
        self.farm       = dictionary[KeyType.farm.rawValue]     as! Int
    }
}

