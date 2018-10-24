//
//  FlickrKitHelper.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation
import FlickrKit

typealias FlickrKitImageDictionary = [String: Any]

enum FlickrKitHelperError: Error, LocalizedError {
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "FlickrKit resonse data invalid."
        }
    }
}

class FlickrKitHelper {
    
    // MARK: - Variables:
    public var imagesPerPage: Int
    
    private var imageDataDictionary = [String: [ImageData]]()
    
    private let flickrKitHelperDispatchQueue = DispatchQueue(label: "FlickrKitHelper")
    private let flickrKitHelperDispatchGroup = DispatchGroup()
    
    
    // MARK: - Functions:
    
    init(imagesPerPage: Int) {
        self.imagesPerPage = imagesPerPage
    }
    
    // Start to upload images dataphotoArray
    public func load(for tags: [String], completion: @escaping ([String: [ImageData]]) -> Void, failure: @escaping (Error) -> Void) {
        
        imageDataDictionary.removeAll()
        
        tags.forEach() { tag in
            self.startLoadingData(for: tag, self.imagesPerPage, failure)
        }
        
        flickrKitHelperDispatchGroup.notify(queue: .main) {
            completion(self.imageDataDictionary)
        }
    }
    
    // Getting images data: URLs and title
    private func startLoadingData(for tag: String, _ perPage: Int, _ failure: @escaping (Error) -> Void) {
        
        flickrKitHelperDispatchGroup.enter()
        
        let perPageString = String(perPage)
        
        flickrKitHelperDispatchQueue.sync { [weak self] in
            guard let self = self else { return }
            
            FlickrKit.shared().call("flickr.photos.search", args: ["tags": tag, "per_page": perPageString] ) { (response, error) -> Void in
                
                if let error = error {
                    failure(error)
                } else {
                
                    guard let response = response,
                        let photos = response["photos"] as? [String: Any],
                        let photo = photos["photo"] as? [FlickrKitImageDictionary]
                        else {
                            failure(FlickrKitHelperError.invalidData)
                            return
                    }
                    
                    var imageDataArray = [ImageData]()
                    
                    photo.forEach({ flickrKitImageData in
                        imageDataArray.append(ImageData(title       : flickrKitImageData["title"] as! String,
                                                        urlSmall240 : FlickrKitHelper.getUrlForPhoto(sizeType: .small240 , using: flickrKitImageData),
                                                        urlSmall320 : FlickrKitHelper.getUrlForPhoto(sizeType: .small320 , using: flickrKitImageData),
                                                        urlLarge1024: FlickrKitHelper.getUrlForPhoto(sizeType: .large1024, using: flickrKitImageData)))
                    })
                    
                    self.imageDataDictionary[tag] = imageDataArray
                }
                
                self.flickrKitHelperDispatchGroup.leave()
            }
        }
    }
    
    // Getting images URL using Flickr image data dictionary
    static func getUrlForPhoto(sizeType: FKPhotoSize, using flickrKitImageDictionary: FlickrKitImageDictionary) -> URL {
        return FlickrKit.shared().photoURL(for: sizeType, fromPhotoDictionary: flickrKitImageDictionary)
    }
}
