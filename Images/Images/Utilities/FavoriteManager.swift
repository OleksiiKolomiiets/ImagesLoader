//
//  FavoriteManager.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 10/31/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

fileprivate class FavoriteManagerSettings {
    static let kUserDefultsKey = "SavedFavoriteImagesDataArray"
    static let kMaxImagesCount = 4
}

class FavoriteManager {
   
    typealias ExceptionHandler = (Int) -> ()
    typealias SuccessHandler = () -> ()
    
    // MARK: - Properties:
    
    static let shared = FavoriteManager()
    
    // MARK: -
    
    public var favoriteImages = [ImageData]()
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Functions:
    
    public func save(_ draggedData: [Data], success: SuccessHandler, exception: ExceptionHandler) {
        var savedData = userDefaults.object(forKey: FavoriteManagerSettings.kUserDefultsKey) as? [Data] ?? [Data]()
        let favoriteImagesMaxCount = FavoriteManagerSettings.kMaxImagesCount
        
        if favoriteImages.count < favoriteImagesMaxCount {
            
            let draggedImages = getImageDataCollection(from: draggedData)
            
            var isDataAdded = false
            
            for draggedImage in draggedImages {
                let draggedImageAlreadySaved = favoriteImages.contains(where: { image -> Bool in
                    image.urlLarge1024 == draggedImage.urlLarge1024
                })
                if !draggedImageAlreadySaved {
                    
                    favoriteImages.append(draggedImage)
                    
                    let data = getData(fromImageData: draggedImage)
                    savedData.append(data)
                    
                    isDataAdded = true
                }
            }
            
            if isDataAdded {
                print("****SAVE****")
                userDefaults.set(savedData, forKey: FavoriteManagerSettings.kUserDefultsKey)
                success()
            }
        } else {
            print("****ALERT****")
            exception(favoriteImagesMaxCount)
        }
    }
    
    public func deleteImage(at index: Int) {
        print("****DELETE****")
        favoriteImages.remove(at: index)
        
        var userDefaultsData = userDefaults.object(forKey: FavoriteManagerSettings.kUserDefultsKey) as? [Data] ?? [Data]()
        userDefaultsData.remove(at: index)
        userDefaults.set(userDefaultsData, forKey: FavoriteManagerSettings.kUserDefultsKey)
    }
    
    public func download() {
        print("****DOWNLOAD****")
        let savedData = userDefaults.object(forKey: FavoriteManagerSettings.kUserDefultsKey) as? [Data] ?? [Data]()
        favoriteImages = getImageDataCollection(from: savedData)
    }
    
    private func getImageDataCollection(from dataCollection: [Data]) -> [ImageData] {
        var imageDataCollection = [ImageData]()
        for data in dataCollection {
            let imageData = getImageData(from: data)
            imageDataCollection.append(imageData)
        }
        return imageDataCollection
    }
    
    private func getImageData(from data: Data) -> ImageData {
        return try! JSONDecoder().decode(ImageData.self, from: data)
    }
    
    private func getData(fromImageData: ImageData) -> Data {
        return try! JSONEncoder().encode(fromImageData) as Data
    }
    
}
