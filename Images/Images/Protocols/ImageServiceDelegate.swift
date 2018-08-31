//
//  ImageServiceDelegate.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/31/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

// MARK: delegate for service 

protocol ImageServiceDelegate: class {
    func onDataLoaded(service: ImageService, data: Images)
}
