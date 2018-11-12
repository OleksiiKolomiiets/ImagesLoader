//
//  FavoriteImage.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 11/2/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit
import CoreData

fileprivate class FavoriteImageSettings {
    static let kEntityName = "FavoriteImage"
}

class FavoriteImage: NSManagedObject {
    
    // *hard code* Version of FavoriteImage in CoreData increments if entity would changed
    static private let versionOfEntity = 2
    static public let isOldVersion = UserDefaults.standard.integer(forKey: "FavoriteImageVersion") != FavoriteImage.versionOfEntity
    
    static private var context: NSManagedObjectContext = ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)!
    
    static var allData: [FavoriteImage] {
        let request = NSFetchRequest<FavoriteImage>(entityName: FavoriteImageSettings.kEntityName)
        
        do {
            let matches = try context.fetch(request)            
            return matches
        } catch {
           return []
        }
        
    }
    
    static func createData(_ image: ImageData) {
        let allImageData = allData.map() { ImageData.instance(from: $0)}
        if !allImageData.contains(image) {
            let favoriteImage = FavoriteImage(context: context)
            favoriteImage.urlLarge1024 = image.urlLarge1024
            favoriteImage.urlSmall320 = image.urlSmall320
            favoriteImage.urlSmall240 = image.urlSmall240
            favoriteImage.urlSmall75 = image.urlSmall75
            favoriteImage.title = image.title
            favoriteImage.id = image.id
            
            do {
                try context.save()
            } catch { }
        }
    }
    
    static func deleteData(_ image: ImageData) {
        let request: NSFetchRequest<FavoriteImage> = FavoriteImage.fetchRequest()
        
        request.predicate = NSPredicate(format: "urlLarge1024 = %@", image.urlLarge1024 as NSURL)
        
        do {
            let matches = try context.fetch(request)
            context.delete(matches[0])
            do {
                try context.save()
            } catch { }
        } catch { }
        
    }
    
    static func deleteAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteImage")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch { }
    }
    
    static func updateVersion() {
        UserDefaults.standard.set(FavoriteImage.versionOfEntity, forKey: "FavoriteImageVersion")
    }
    
}
