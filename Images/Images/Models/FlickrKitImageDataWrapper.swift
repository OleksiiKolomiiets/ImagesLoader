//
//  ImageViewEntity.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/27/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit
import MobileCoreServices

/// - Tag: FlickrKitImageDataWrapper
final class FlickrKitImageDataWrapper: NSObject, Codable {
    
    // MARK: - Variables:
    public let id      : String!
    public let server  : String!
    public let secret  : String!
    public let farm    : Int!
    
    static private let flickrTypeIdentifiersForItemProvider = [kUTTypeData as String]
    
    // MARK: - Function:    
    // Constructor to create instance using dictionary from api response
    init(from flickrDictionary: FlickrKitImageDictionary) {
        self.id     = flickrDictionary["id"]       as? String
        self.server = flickrDictionary["server"]   as? String
        self.secret = flickrDictionary["secret"]   as? String
        self.farm   = flickrDictionary["farm"]     as? Int
    }    
    
}

// MARK: - NSItemProviderReading
extension FlickrKitImageDataWrapper: NSItemProviderReading {
    static var readableTypeIdentifiersForItemProvider: [String] {
        // Specify image view entity as a data type
        return flickrTypeIdentifiersForItemProvider
    }

    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> FlickrKitImageDataWrapper {
        let decoder = JSONDecoder()
        do {
            //Here we decode the object back to it's class representation and return it
            let flickrKitImageDataWrapper = try decoder.decode(FlickrKitImageDataWrapper.self, from: data)
            return flickrKitImageDataWrapper
        } catch {
            fatalError(ImageViewEntityError.invalidData.localizedDescription)
        }
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
}

// MARK: - NSItemProviderWriting
extension FlickrKitImageDataWrapper: NSItemProviderWriting {
    static var writableTypeIdentifiersForItemProvider: [String] {
        // Representing image view entity as a data type
        return flickrTypeIdentifiersForItemProvider
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
}
