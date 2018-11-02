//
//  FlickrKitHelper.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation
import FlickrKit

class FlickrKitHelper {    
    
    typealias FlickrKitImageDictionary = [String: Any]
    typealias FlickrKitHelperCompletionHandler = ([String: [ImageData]]?, Error?) -> Void
    
    // MARK: - Variables:
    
    public var imagesPerPage: Int
    
    private var imageDataDictionary: [String: [ImageData]]?
    private var flickrError: Error?
    
    private let flickrKitHelperDispatchQueue = DispatchQueue(label: "FlickrKitHelper")
    private let flickrKitHelperDispatchGroup = DispatchGroup()
    
    
    // MARK: - Functions:
    
    init(imagesPerPage: Int) {
        self.imagesPerPage = imagesPerPage
    }
    
    // Starting to load images data
    public func load(for tags: [String], completion: @escaping FlickrKitHelperCompletionHandler) {
        
        imageDataDictionary?.removeAll()
        flickrError = nil
        
        tags.forEach() { tag in
            self.startLoadingData(for: tag, self.imagesPerPage) 
        }
        
        flickrKitHelperDispatchGroup.notify(queue: .main) {
            completion(self.imageDataDictionary, self.flickrError)
        }
        
        
    }
    
    // Loading images data: URLs and title
    private func startLoadingData(for tag: String, _ perPage: Int) {
        
        flickrKitHelperDispatchGroup.enter()
        
        let perPageString = String(perPage)
        
        flickrKitHelperDispatchQueue.async {
            
            FlickrKit.shared().call("flickr.photos.search", args: ["tags": tag, "per_page": perPageString] ) { (response, error) -> Void in
                
                if let error = error {
                    if self.flickrError == nil {
                        self.flickrError = error
                        print(error.localizedDescription)
                    }
                } else if let response = response {
                    
                    let photos = response["photos"] as! [String: Any]
                    let photo  = photos["photo"]    as! [FlickrKitImageDictionary]
                    
                    var imageDataArray = [ImageData]()
                    
                    photo.forEach({ flickrKitImageData in
                        imageDataArray.append(ImageData(title       : flickrKitImageData["title"] as! String,
                                                        urlSmall240 : self.getFlickrUrl(forSize: .small240,  using: flickrKitImageData),
                                                        urlSmall320 : self.getFlickrUrl(forSize: .small320,  using: flickrKitImageData),
                                                        urlLarge1024: self.getFlickrUrl(forSize: .large1024, using: flickrKitImageData)))
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
    private func getFlickrUrl(forSize flickrKitPhotoSize: FKPhotoSize, using flickrKitImageDictionary: FlickrKitImageDictionary) -> URL {
        return FlickrKit.shared().photoURL(for: flickrKitPhotoSize, fromPhotoDictionary: flickrKitImageDictionary)
    }
}
