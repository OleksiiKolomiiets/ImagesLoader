//
//  FlickrImageDataLoader.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation
import FlickrKit

protocol DataLoaderDelegate: class {
    func onDataLoaded  (dataLoader: FlickrImageDataLoader)
    func onErrorCatched(dataLoader: FlickrImageDataLoader, error: Error)
}

typealias FlickrKitImageDictionary = [String: Any]

class FlickrImageDataLoader {
    
    // MARK: - Variables:
    public weak var delegate: DataLoaderDelegate?
    public var imageTags: [String]!
    public var imagesQuantity: Int!
    public var flickrKitImageDictionary = [String: [FlickrKitImageDictionary]]()
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
                            self.delegate?.onErrorCatched(dataLoader: self, error: error!)
                        }
                        return
                }
                self.flickrKitImageDictionary[tag] = photoArray
                if self.flickrKitImageDictionary.count == self.imageTags?.count{
                    DispatchQueue.main.async { () -> Void  in
                        self.delegate!.onDataLoaded(dataLoader: self)
                    }
                }
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
