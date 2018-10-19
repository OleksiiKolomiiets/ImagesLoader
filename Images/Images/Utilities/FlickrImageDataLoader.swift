//
//  ImageService.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation
import FlickrKit

protocol ImageServiceDelegate: class {
    func onDataLoaded  (service: FlickrImageDataLoader)
    func onErrorCatched(service: FlickrImageDataLoader, error: Error)
}

typealias FlickrKitImageDictionary = [String: Any]
typealias Tag = String

class FlickrImageDataLoader { // previous name -> ImageService
    
    // MARK: - Variables:
    public weak var delegate: ImageServiceDelegate?
    public var imageTags: [String]?
    public var imagesQuantity: Int!
    public var flickrKitImageDictionary = [Tag: [FlickrKitImageDictionary]]() {
        didSet {
            if self.flickrKitImageDictionary.count == imageTags?.count{
                DispatchQueue.main.async { () -> Void  in
                    self.delegate!.onDataLoaded(service: self)
                }
            }
        }
    }
    
    private let imageDataLoader = DispatchQueue(label: "FlickrImageDataLoader")
    
    
    // MARK: - Functions:
    // Start to upload images dataphotoArray
    public func reload() {
        flickrKitImageDictionary.removeAll()
        imageTags?.forEach() { tag in
            self.getImagesData(self.imagesQuantity, by: tag)
        }
    }
    
    // Getting images URL and title
    private func getImagesData(_ quantity: Int, by tag: String) {
        let quantity = String(quantity)
        imageDataLoader.async { [weak self] in
            guard let self = self else { return }
            FlickrKit.shared().call("flickr.photos.search", args: ["tags": tag, "per_page": quantity] ) { (response, error) -> Void in
                guard error == nil,
                    let response = response,
                    let topPhotos = response["photos"] as? [String: Any],
                    let photoArray = topPhotos["photo"] as? [FlickrKitImageDictionary]
                    else {
                        DispatchQueue.main.async { () -> Void  in
                            self.delegate?.onErrorCatched(service: self, error: error!)
                        }
                        return
                }
                self.flickrKitImageDictionary[tag] = photoArray
            }
        }
    }
    
    // Getting images URL using wrapped Flickr image data
    static func getUrlForPhoto(sizeType: ImageDimensionType,
                               using flickrKitImageDataWrapper: FlickrKitImageDataWrapper) -> URL {
        return FlickrKit.shared().photoURL(for    : sizeType.flickerPhotoSize,
                                           photoID: flickrKitImageDataWrapper.id,
                                           server : flickrKitImageDataWrapper.server,
                                           secret : flickrKitImageDataWrapper.secret,
                                           farm   : String(flickrKitImageDataWrapper.farm))
    }
    
    // Getting images URL using Flickr image data dictionary
    static func getUrlForPhoto(sizeType: ImageDimensionType, using flickrKitImageDictionary: FlickrKitImageDictionary) -> URL {
        return FlickrKit.shared().photoURL(for: sizeType.flickerPhotoSize,
                                           fromPhotoDictionary: flickrKitImageDictionary)
    }
}
