//
//  TabBarType.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 11/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation
import UIKit

enum TabBarType: Int {
    case images
    case favorite
    case search
    
    var title: String {
        switch self {
        case .images:
            return "Images"
        case .favorite:
            return "Favorites"
        case .search:
            return "Search"
        }
    }
    
    var image: UIImage {
        return UIImage(imageLiteralResourceName: self.title.lowercased())
    }
}
