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

class FlickrKitHelper {
    
    // MARK: - Variables:
    public var imagesPerPage: Int
    
    private var imageDataDictionary: [String: [ImageData]]?
    private var flickrNetworkError: [Error]?
    
    private let flickrKitHelperDispatchQueue = DispatchQueue(label: "FlickrKitHelper")
    private let flickrKitHelperDispatchGroup = DispatchGroup()
    
    
    // MARK: - Functions:
    
    init(imagesPerPage: Int) {
        self.imagesPerPage = imagesPerPage
    }
    
    // Start to upload images dataphotoArray
    public func load(for tags: [String], completion: @escaping ([String: [ImageData]]?, [Error]?) -> Void) {
        
        imageDataDictionary?.removeAll()
        
        tags.forEach() { tag in
            self.startLoadingData(for: tag, self.imagesPerPage) { error in
                
                guard var flickrNetworkError = self.flickrNetworkError else {
                    self.flickrNetworkError = [error]
                    return
                }
                
                if flickrNetworkError.contains(where: { $0.localizedDescription == error.localizedDescription }) {
                    flickrNetworkError.append(error)
                }
                
            }
        }
        
        flickrKitHelperDispatchGroup.notify(queue: .main) {            
            completion(self.imageDataDictionary, self.flickrNetworkError)
        }
        
        
    }
    
    // Loading images data: URLs and title
    private func startLoadingData(for tag: String, _ perPage: Int, _ failure: @escaping (Error) -> Void) {
        
        flickrKitHelperDispatchGroup.enter()
        
        let perPageString = String(perPage)
        
        flickrKitHelperDispatchQueue.async {
            
            FlickrKit.shared().call("flickr.photos.search", args: ["tags": tag, "per_page": perPageString] ) { (response, error) -> Void in
                
                if let error = error {
                    failure(error)
                } else if let response = response {
                    
                    let photos = response["photos"] as! [String: Any]
                    let photo = photos["photo"] as! [FlickrKitImageDictionary]
                    
                    var imageDataArray = [ImageData]()
                    
                    photo.forEach({ flickrKitImageData in
                        imageDataArray.append(ImageData(title       : flickrKitImageData["title"] as! String,
                                                        urlSmall240 : FlickrKitHelper.getFlickrUrl(forSize: .small240 , using: flickrKitImageData),
                                                        urlSmall320 : FlickrKitHelper.getFlickrUrl(forSize: .small320 , using: flickrKitImageData),
                                                        urlLarge1024: FlickrKitHelper.getFlickrUrl(forSize: .large1024, using: flickrKitImageData)))
                    })
                    
                    if self.imageDataDictionary != nil {
                        self.imageDataDictionary![tag] = imageDataArray
                    } else {
                        self.imageDataDictionary = [tag: imageDataArray]
                    }
                    
                }
                
                self.flickrKitHelperDispatchGroup.leave()
            }
        }
    }
    
    // Getting images URL using Flickr image data dictionary
    static func getFlickrUrl(forSize flickrKitPhotoSize: FKPhotoSize, using flickrKitImageDictionary: FlickrKitImageDictionary) -> URL {
        return FlickrKit.shared().photoURL(for: flickrKitPhotoSize, fromPhotoDictionary: flickrKitImageDictionary)
    }
}
