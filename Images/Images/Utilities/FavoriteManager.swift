//
//  FavoriteManager.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 10/31/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

protocol FavoriteManagerProtocol {
    var isOverlapTheLimit: Bool { get }
    func getAllFavoriteImages() -> [ImageData]
    func addFavoriteImage(_ image: ImageData)
    func deleteFavoriteImage(_ image: ImageData)
}

fileprivate class FavoriteManagerSettings {
    static let kUserDefaultsKey = "SavedFavoriteImagesDataArray"
    static let kMaxImagesCount  = 10
}

class FavoriteManager: FavoriteManagerProtocol {
    
    // MARK: - Properties:
    
    static let shared = FavoriteManager()
    
    // MARK: -
    
    public var favoriteImages = [ImageData]()
    public var maxImagesCount = FavoriteManagerSettings.kMaxImagesCount
    
    // MARK: - Initialization
    
    private init() {
        let savedData = UserDefaults.standard.object(forKey: FavoriteManagerSettings.kUserDefaultsKey) as? [Data] ?? [Data]()
        favoriteImages = getImageDataCollection(from: savedData)
    }
    
    // MARK: - Functions:
    public var isOverlapTheLimit: Bool {
        return favoriteImages.count >= maxImagesCount
    }
    
    public func getAllFavoriteImages() -> [ImageData] {
        let savedData = UserDefaults.standard.object(forKey: FavoriteManagerSettings.kUserDefaultsKey) as? [Data] ?? [Data]()
        return getImageDataCollection(from: savedData)
    }
    
    public func addFavoriteImage(_ image: ImageData) {
        var imagesData = getAllFavoriteImages()
        if !imagesData.contains(image) {
            imagesData.append(image)
            print("****SAVE****")
            favoriteImages.append(image)
            UserDefaults.standard.set(imagesData.map() { $0.data }, forKey: FavoriteManagerSettings.kUserDefaultsKey)
        } else {
            print("****ALREADY ADDED****")
        }
    }
    
    public func deleteFavoriteImage(_ image: ImageData) {
        let imagesData = getAllFavoriteImages()
        let filtredImageData = imagesData.filter { imageData -> Bool in
            imageData != image
        }
        favoriteImages = filtredImageData
        UserDefaults.standard.set(filtredImageData.map() { $0.data }, forKey: FavoriteManagerSettings.kUserDefaultsKey)
    }  
    
    private func getImageDataCollection(from dataCollection: [Data]) -> [ImageData] {
        var imageDataCollection = [ImageData]()
        for data in dataCollection {
            let imageData = ImageData(json: data)
            imageDataCollection.append(imageData)
        }
        return imageDataCollection
    }
}
