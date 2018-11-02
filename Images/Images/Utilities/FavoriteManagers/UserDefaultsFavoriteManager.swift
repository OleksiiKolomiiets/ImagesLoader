//
//  UserDefaultsFavoriteManager.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 10/31/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

fileprivate class UserDefaultsManagerSettings {
    static let kUserDefaultsKey = "SavedFavoriteImagesDataArray"
}

class UserDefaultsFavoriteManager: FavoriteManagerProtocol {
    
    
    // MARK: - Properties:
    
    public static var isOverlapTheLimit: Bool {
        return allFavoriteImages.count >= maxImagesCount
    }
    
    
    // MARK: - Functions:
    
    public static var allFavoriteImages: [ImageData] {
        let savedData = UserDefaults.standard.object(forKey: UserDefaultsManagerSettings.kUserDefaultsKey) as? [Data] ?? [Data]()
        return getImageDataCollection(from: savedData)
    }
    
    public static func addFavoriteImage(_ image: ImageData) {
        var imagesData = allFavoriteImages
        if !imagesData.contains(image) {
            imagesData.append(image)
            UserDefaults.standard.set(imagesData.map() { $0.data }, forKey: UserDefaultsManagerSettings.kUserDefaultsKey)
        }
    }
    
    public static func deleteFavoriteImage(_ image: ImageData) {
        let imagesData = allFavoriteImages
        let filtredImageData = imagesData.filter { imageData -> Bool in imageData != image }
        UserDefaults.standard.set(filtredImageData.map() { $0.data }, forKey: UserDefaultsManagerSettings.kUserDefaultsKey)
    }  
    
    private static func getImageDataCollection(from dataCollection: [Data]) -> [ImageData] {
        return dataCollection.map() { ImageData.instance(from: $0) }
    }
}
