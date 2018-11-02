//
//  FavoriteManager.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 10/31/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

protocol FavoriteManagerProtocol {
    static var maxImagesCount: Int { get }
    static var isOverlapTheLimit: Bool { get }
    static func getAllFavoriteImages() -> [ImageData]
    static func addFavoriteImage(_ image: ImageData)
    static func deleteFavoriteImage(_ image: ImageData)
}

fileprivate class FavoriteManagerSettings {
    static let kUserDefaultsKey = "SavedFavoriteImagesDataArray"
    static let kMaxImagesCount  = 10
}

class FavoriteManager: FavoriteManagerProtocol {
    
    // MARK: - Properties:
    
    public static let maxImagesCount = FavoriteManagerSettings.kMaxImagesCount
    
    public static var isOverlapTheLimit: Bool {
        return getAllFavoriteImages().count >= maxImagesCount
    }
    
    
    // MARK: - Functions:
    
    public static func getAllFavoriteImages() -> [ImageData] {
        let savedData = UserDefaults.standard.object(forKey: FavoriteManagerSettings.kUserDefaultsKey) as? [Data] ?? [Data]()
        return getImageDataCollection(from: savedData)
    }
    
    public static func addFavoriteImage(_ image: ImageData) {
        var imagesData = getAllFavoriteImages()
        if !imagesData.contains(image) {
            imagesData.append(image)
            UserDefaults.standard.set(imagesData.map() { $0.data }, forKey: FavoriteManagerSettings.kUserDefaultsKey)
        }
    }
    
    public static func deleteFavoriteImage(_ image: ImageData) {
        let imagesData = getAllFavoriteImages()
        let filtredImageData = imagesData.filter { imageData -> Bool in imageData != image }
        UserDefaults.standard.set(filtredImageData.map() { $0.data }, forKey: FavoriteManagerSettings.kUserDefaultsKey)
    }  
    
    private static func getImageDataCollection(from dataCollection: [Data]) -> [ImageData] {
        return dataCollection.map() { ImageData.instance(from: $0) }
    }
}
