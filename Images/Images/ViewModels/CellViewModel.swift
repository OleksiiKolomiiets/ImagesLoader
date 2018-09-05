//
//  CellViewModel.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 9/3/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation
import UIKit

class CellViewModel {
    let image: UIImage?
    let title: String
    
    init(image: UIImage?, title: String) {
        self.image = image
        self.title = title
    }
}