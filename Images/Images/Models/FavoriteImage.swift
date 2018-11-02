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

class FavoriteImage: NSManagedObject {
    
    static var allData: [FavoriteImage] {
        guard let context: NSManagedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return [] }
        
        let request = NSFetchRequest<FavoriteImage>(entityName: CoreDataManagerSettings.kEntityName)
        
        do {
            let matches = try context.fetch(request)            
            return matches
        } catch {
            print("AllFavoriteImages errors.")
        }
        
        return []
    }
    
    static func createData(_ image: ImageData) {
        guard let context: NSManagedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }
        
        let favoriteImage = FavoriteImage(context: context)
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
    
    static func deleteData(_ image: ImageData) {
        guard let context: NSManagedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }
        
        let request: NSFetchRequest<FavoriteImage> = FavoriteImage.fetchRequest()
        
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
