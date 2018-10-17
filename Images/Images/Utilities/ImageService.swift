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
    func onDataLoaded(service: ImageService, data: [ImagesViewSource])
    func onErrorCatched(service: ImageService, error: Error)
}

class ImageService {
    
    // MARK: - Variables:
    weak var delegate: ImageServiceDelegate?
    var imageTags: [String]?
    private let imageDataLoader = DispatchQueue(label: "ImageService")
    private var imagesData = [ImagesViewSource]()
    
    // MARK: - Functions:
    // Start to upload images data
    func reload() {
        imagesData.removeAll()
        let imagesQuantity = ImagesViewControllerSettings.kNumberOfUploadingImages
        imageTags?.forEach() { tag in
            self.getImagesData(imagesQuantity, by: tag)
        }
    }
    
    // Getting images URL and title
    private func getImagesData(_ quantity: Int, by tag: String) {
        let images = ImagesViewSource(tag: tag, data: nil)
        let quantity = String(quantity)
        imageDataLoader.async {
            FlickrKit.shared().call("flickr.photos.search", args: ["tags": tag, "per_page": quantity] ) { (response, error) -> Void in
                guard error == nil,
                    let response = response,
                    let topPhotos = response["photos"] as? [String: Any],
                    let photoArray = topPhotos["photo"] as? [[String: Any]]
                    else {
                        DispatchQueue.main.async { () -> Void  in
                            self.delegate?.onErrorCatched(service: self, error: error!)
                        }
                        return
                }
                self.getImageEntities(from: photoArray, to: images)
            }
        }
    }
    
    private func getImageEntities(from source: [[String: Any]], to images: ImagesViewSource) {
        var images = images
        var imageArray =  [ImageViewEntity]()
        for photoDictionary in source {
            let data = ImageViewEntity(from: photoDictionary)
            imageArray.append(data)
        }
        images.data = imageArray
        self.imagesData.append(images)
        if self.imagesData.count == imageTags?.count {
            DispatchQueue.main.async { () -> Void  in
                self.delegate!.onDataLoaded(service: self, data: self.imagesData)
            }
        }
    }
    
    // Getting images URL using Flikr image data
    static func getUrlForPhoto(sizeType: ImageDimensionType = ImageDetailViewControllerSettings.kDetailImageDimension,
                               using imageData: ImageViewEntity) -> URL {
        return FlickrKit.shared().photoURL(for: sizeType.size, photoID: imageData.id, server: imageData.server, secret: imageData.secret, farm: String(imageData.farm))
    }
    
    // Getting images URL using Flikr image data
    static func getUrlForPhoto(photoID: String, server: String, secret: String, farm: String) -> URL {        
        let size = ImageDetailViewControllerSettings.kDetailImageDimension.size
        return FlickrKit.shared().photoURL(for: size, photoID: photoID, server: server, secret: secret, farm: farm)
    }
}
