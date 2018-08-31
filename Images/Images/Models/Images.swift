//
//  Images.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/31/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

class Images {
    let tag: String
    var data: [ImageViewEntity]?
    
    init(tag: String, data: [ImageViewEntity]?) {
        self.tag = tag
        self.data = data
    }
}
