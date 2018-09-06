//
//  TitleCellType.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 9/6/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

enum TitleCellType {
    case absent
    case present(String)
    
    
    // MARK: initialization of title cell according to its content
    init(title: String) {
        title.isEmpty ? (self = .absent) : (self = .present(title))
    }
    
    var description: String {
        switch self {
        case .absent:
            return ImagesViewControllerSettings.kDefultTitle
        case .present(let title):
            return title
        }
    }
}
