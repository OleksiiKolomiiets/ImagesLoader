//
//  ImageService.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation
import FlickrKit

class ImageService {
    
    // MARK: Variables
    weak var delegate: ImageServiceDelegate?
    var imageTags: [String]?
    private let imageDataLoader = DispatchQueue(label: "ImageService")
    private var imagesData = [ImagesViewSource]()
    
    // MARK: Functions
    
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
                else { return }
                self.getImageEntities(from: photoArray, to: images)
            }
        }
    }
    
    private func getImageEntities(from source: [[String: Any]], to images: ImagesViewSource) {
        var images = images
        var imageArray =  [ImageViewEntity]()
        for photoDictionary in source {
            let photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.small240, fromPhotoDictionary: photoDictionary)
            let data = ImageViewEntity(from: photoDictionary, with: photoURL)
            
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
    static func getUrlForPhoto(using imageData: ImageViewEntity) -> URL {
        return FlickrKit.shared().photoURL(for: FKPhotoSize.large1024, photoID: imageData.photoID, server: imageData.server, secret: imageData.secret, farm: String(imageData.farm))
    }
}
