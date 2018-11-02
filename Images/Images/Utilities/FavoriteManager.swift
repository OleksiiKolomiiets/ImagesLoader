//
//  FavoriteManager.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 10/31/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

/** Freez
    Setting fo UserDefaults
fileprivate class UserDefaultsManagerSettings {
    static let kUserDefaultsKey = "SavedFavoriteImagesDataArray"
}
 */

class FavoriteManager: FavoriteManagerProtocol {
    
    
    // MARK: - Properties:
    
    public static var isOverlapTheLimit: Bool {
        return allFavoriteImages.count >= maxImagesCount
    }
    
    
    // MARK: - Functions:
    
    public static var allFavoriteImages: [ImageData] {
        
        // Retrive all data via CoreData
        let allFavoriteImagesData = FavoriteImage.allData
        return allFavoriteImagesData.map() { ImageData.instance(from: $0) }

        /** Freez
            UserDefaults aproach to retrive data
        let savedData = UserDefaults.standard.object(forKey: UserDefaultsManagerSettings.kUserDefaultsKey) as? [Data] ?? [Data]()
        return getImageDataCollection(from: savedData)
        */
    }
    
    public static func addFavoriteImage(_ image: ImageData) {
        
        // Add favorite via CoreData
        FavoriteImage.createData(image)
        
        /** Freez
            UserDefaults aproach to add data
        var imagesData = allFavoriteImages
        if !imagesData.contains(image) {
            imagesData.append(image)
            UserDefaults.standard.set(imagesData.map() { $0.data }, forKey: UserDefaultsManagerSettings.kUserDefaultsKey)
        }
         */
    }
    
    public static func deleteFavoriteImage(_ image: ImageData) {
        
        // Dalete favorite via CoreData
        FavoriteImage.deleteData(image)
        
        /** Freez
            UserDefaults aproach to delete data
        let imagesData = allFavoriteImages
        let filtredImageData = imagesData.filter { imageData -> Bool in imageData != image }
        UserDefaults.standard.set(filtredImageData.map() { $0.data }, forKey: UserDefaultsManagerSettings.kUserDefaultsKey)
         */
    }  
    
    /** Freez
        Methods for UserDefaults aproach to manage data
    private static func getImageDataCollection(from dataCollection: [Data]) -> [ImageData] {
        return dataCollection.map() { ImageData.instance(from: $0) }
    }
     */
}
