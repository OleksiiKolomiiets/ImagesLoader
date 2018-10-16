//
//  ImageViewEntity.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/27/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit
import MobileCoreServices

enum ImageViewEntityError: Error, LocalizedError {
    case invalidData
    
    var errorDescription: String? {
        switch self {
            
        case .invalidData:
            return "ImageViewEntity data invalid"
        }
    }
}

/// - Tag: ImageViewEntity
final class ImageViewEntity: NSObject, NSItemProviderWriting, NSItemProviderReading, Codable {
    
    // MARK: - Variables:
    let url     : URL
    let title   : String
    let id      : String
    let server  : String
    let secret  : String
    let farm    : Int
    
    
     // Enumaration for existing feilds(keys in api response dictionry)
    enum KeyType: String {
        case title
        case id
        case server
        case secret
        case farm
    }
    
    // MARK: - Function:    
    // Constructor to create instance using dictionary from api and existing url
    init(from dictionary: [String: Any], with url: URL) {
        self.url = url
        
        self.title  = dictionary[KeyType.title.rawValue]    as! String
        self.id     = dictionary[KeyType.id.rawValue]       as! String
        self.server = dictionary[KeyType.server.rawValue]   as! String
        self.secret = dictionary[KeyType.secret.rawValue]   as! String
        self.farm   = dictionary[KeyType.farm.rawValue]     as! Int
    }
    
    // MARK: - NSItemProviderWriting
    static var writableTypeIdentifiersForItemProvider: [String] {
        // Representing image view entity as a data type
        return [kUTTypeData as String]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let progress = Progress(totalUnitCount: 100)
        do {
            //Here the object is encoded to a JSON data object and sent to the completion handler
            let data = try JSONEncoder().encode(self)
            progress.completedUnitCount = 100
            completionHandler(data, nil)
        } catch {
            completionHandler(nil, error)
        }
        return progress
    }
    
    // MARK: - NSItemProviderReading
    static var readableTypeIdentifiersForItemProvider: [String] {
        //We know we want to accept our object as a data representation, so we'll specify that here
        return [kUTTypeData as String]
    }
    
    //This function actually has a return type of Self, but that really messes things up when you are trying to return your object, so if you mark your class as final as I've done above, the you can change the return type to return your class type.
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> ImageViewEntity {
        let decoder = JSONDecoder()
        do {
            //Here we decode the object back to it's class representation and return it
            let imageView = try decoder.decode(ImageViewEntity.self, from: data)
            return imageView
        } catch {
            fatalError(ImageViewEntityError.invalidData.localizedDescription)
        }
    }    
    
}
