//
//  FavoriteImage.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 11/2/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit
import CoreData

fileprivate class CoreDataManagerSettings {
    static let kEntityName = "FavoriteImage"
}

class CoreDataFavoriteManager: NSManagedObject, FavoriteManagerProtocol {
    
    static var isOverlapTheLimit: Bool {
        return allFavoriteImages.count >= maxImagesCount
    }
    
    static var allFavoriteImages: [ImageData] {
        guard let context: NSManagedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return [] }
        
        let request = NSFetchRequest<CoreDataFavoriteManager>(entityName: CoreDataManagerSettings.kEntityName)
        
        do {
            let matches = try context.fetch(request)            
            return matches.map { ImageData.instance(from: $0) }
        } catch {
            print("AllFavoriteImages errors.")
        }
        
        return []
    }
    
    static func addFavoriteImage(_ image: ImageData) {
        guard let context: NSManagedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }
        
        let favoriteImage = CoreDataFavoriteManager(context: context)
        favoriteImage.urlLarge1024 = image.urlLarge1024
        favoriteImage.urlSmall320 = image.urlSmall320
        favoriteImage.urlSmall240 = image.urlSmall240
        favoriteImage.title = image.title
        
        do {
            try context.save()
        } catch {
            print("Save errors.")
        }
    }
    
    static func deleteFavoriteImage(_ image: ImageData) {
        guard let context: NSManagedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }
        
        let request: NSFetchRequest<CoreDataFavoriteManager> = CoreDataFavoriteManager.fetchRequest()
        
        request.predicate = NSPredicate(format: "urlLarge1024 = %@", image.urlLarge1024 as NSURL)
        
        do {
            let matches = try context.fetch(request)
            context.delete(matches[0])
            do {
                try context.save()
            } catch {
                print("Save errors.")
            }
        } catch {
            print("DeleteFavoriteImage errors.")
        }
        
    }
    
}
