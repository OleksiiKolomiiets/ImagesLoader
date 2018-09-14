//
//  ImagesViewControllerSettings.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/29/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImagesViewControllerSettings {
    
    //MARK: - Uploading images constants
    static let kNumberOfUploadingImages: Int = 30
    static let kTags = ["sun", "mercury", "venus", "earth", "mars", "jupiter","saturn", "uranus", "neptune", "pluto"]
    static let kDefultTitle = "Title doesn't exist"
    static let kNumberOfTagsInOneLoad = 3
    static let kCellsImageDimension:ImageDimensionType = .small
    
    //MARK: - Reloading constant
    static let kTimeLimit = 30.0
    
    //MARK: - Table view constants
    static let kHeightForRow: CGFloat = 91
    static let kHeightForHeader: CGFloat = 80
    static let kCellIdentifierForTableView: String = "imageCell"
    
    //MARK: - Collection view constants
    static let kCellIdentifierForCollectionView: String = "imageCollectionView"
    static let kCellPaddingQuote: CGFloat = 0.1
    static let kCellWidthQuote: CGFloat = 0.8
}


