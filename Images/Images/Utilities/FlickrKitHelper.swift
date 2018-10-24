//
//  FlickrKitHelper.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation
import FlickrKit

protocol FlickrKitHelperDelegate: class {
    func onErrorCatched(helper: FlickrKitHelper, error: Error)
}

typealias FlickrKitImageDictionary = [String: Any]

class FlickrKitHelper {
    
    // MARK: - Variables:
    public weak var delegate: FlickrKitHelperDelegate?
    
    public var imagesQuantity: Int!
    
    private var imageDataDictionary = [String: [ImageData]]()
    private var imageTags = [String]()
    
    private let flickrKitHelperDispatchQueue = DispatchQueue(label: "FlickrKitHelper")
    private let flickrKitHelperDispatchGroup = DispatchGroup()
    
    
    // MARK: - Functions:
    // Start to upload images dataphotoArray
    public func load(for tags: [String], completion: @escaping ([String: [ImageData]], [String]) -> Void) {
        
        imageDataDictionary.removeAll()
        imageTags = tags
        
        imageTags.forEach() { tag in
            self.setImagesData(self.imagesQuantity, by: tag)
        }
        
        flickrKitHelperDispatchGroup.notify(queue: .main) {
            print("****")
            completion(self.imageDataDictionary, self.imageTags)
        }
    }
    
    // Getting images data: URLs and title
    private func setImagesData(_ quantity: Int, by tag: String) {
        
        flickrKitHelperDispatchGroup.enter()
        
        let quantity = String(quantity)
        
        flickrKitHelperDispatchQueue.sync { [weak self] in
            guard let self = self else { return }
            
            FlickrKit.shared().call("flickr.photos.search", args: ["tags": tag, "per_page": quantity] ) { (response, error) -> Void in
                
                guard error == nil, let response = response,
                    let topPhotos = response["photos"] as? [String: Any],
                    let photoArray = topPhotos["photo"] as? [FlickrKitImageDictionary]
                    else {
                        DispatchQueue.main.async { () -> Void  in
                            self.delegate?.onErrorCatched(helper: self, error: error!)
                        }
                        return
                }
                
                var imageDataArray = [ImageData]()
                
                photoArray.forEach({ flickrKitImageData in
                    imageDataArray.append(ImageData(title       : flickrKitImageData["title"] as! String,
                                                    urlSmall240 : FlickrKitHelper.getUrlForPhoto(sizeType: .small240, using: flickrKitImageData),
                                                    urlSmall320 : FlickrKitHelper.getUrlForPhoto(sizeType: .small320, using: flickrKitImageData),
                                                    urlLarge1024: FlickrKitHelper.getUrlForPhoto(sizeType: .large1024, using: flickrKitImageData)))
                })
                
                self.imageDataDictionary[tag] = imageDataArray
                print(self.imageDataDictionary.count)
                
                self.flickrKitHelperDispatchGroup.leave()
            }
        }
    }
    
    // Getting images URL using Flickr image data dictionary
    static func getUrlForPhoto(sizeType: FKPhotoSize, using flickrKitImageDictionary: FlickrKitImageDictionary) -> URL {
        return FlickrKit.shared().photoURL(for: sizeType, fromPhotoDictionary: flickrKitImageDictionary)
    }
}
