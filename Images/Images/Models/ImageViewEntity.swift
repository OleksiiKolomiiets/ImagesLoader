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
}
