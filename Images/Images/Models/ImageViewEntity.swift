//
//  ImageViewEntity.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/27/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit
import MobileCoreServices



/// - Tag: ImageViewEntity
final class ImageViewEntity: NSObject, NSItemProviderWriting, NSItemProviderReading, Codable {
    
    // MARK: - Variables:
    public let title   : String!
    public let id      : String!
    public let server  : String!
    public let secret  : String!
    public let farm    : Int!
    
    static private let typeIdentifiersForItemProvider = [kUTTypeData as String]
    
     // Enumeration of existing feilds(keys in dictionry of api response)
    private enum KeyType: String {
        case title
        case id
        case server
        case secret
        case farm
    }
    // Enumeration of possible errors when creating an instance of ImageViewEntity
    private enum ImageViewEntityError: Error, LocalizedError {
        case invalidData
        
        var errorDescription: String? {
            switch self {
            case .invalidData:
                return "ImageViewEntity data invalid"
            }
        }
    }
    
    // MARK: - Function:    
    // Constructor to create instance using dictionary from api response
    init(from dictionary: [String: Any]) {
        self.title  = dictionary[KeyType.title.rawValue]    as? String
        self.id     = dictionary[KeyType.id.rawValue]       as? String
        self.server = dictionary[KeyType.server.rawValue]   as? String
        self.secret = dictionary[KeyType.secret.rawValue]   as? String
        self.farm   = dictionary[KeyType.farm.rawValue]     as? Int
    }
    
    // MARK: - NSItemProviderWriting
    static var writableTypeIdentifiersForItemProvider: [String] {
        // Representing image view entity as a data type
        return typeIdentifiersForItemProvider
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String,
                  forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
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
        // Specify image view entity as a data type
        return typeIdentifiersForItemProvider
    }
    
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
