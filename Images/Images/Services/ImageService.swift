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
    
    private var tags: [String]
    weak var delegate: ImageServiceDelegate?
    private var imageArray: [ImageViewEntity]?
    private var images = [Images]()
    
    init(tags: [String]) {
        self.tags = tags
    }
    
    // MARK: start to upload images data
    
    func reload() {
        let imagesQuantity = ImagesViewControllerSettings.kNumberOfUploadingImages
        tags.forEach() { tag in
            self.getImagesData(imagesQuantity, by: tag)
        }
        
    }
    
    // MARK: getting images URL and title
    
    private func getImagesData(_ quantity: Int, by tag: String) {
        let images = Images(tag: tag, data: nil)
        OperationQueue().addOperation() {
            DispatchQueue.global(qos: .utility).async { () -> Void  in
                let quantity = String(quantity)
                FlickrKit.shared().call("flickr.photos.search", args: ["tags": tag, "per_page": quantity] ) { (response, error) -> Void in
                    if error == nil, (response != nil) {
                        let topPhotos = response!["photos"] as! [String: Any]
                        let photoArray = topPhotos["photo"] as? [[String: Any]]
                        self.getImageEntities(from: photoArray!, to: images)
                    } else if error != nil {
                        return
                    }
                }
            }
        }
    }
    
    private func getImageEntities(from source: [[String: Any]], to images: Images) {
        var images = images
        imageArray = [ImageViewEntity]()
        for photoDictionary in source {
            let title = photoDictionary["title"]! as! String
            let photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.small240, fromPhotoDictionary: photoDictionary)
            let data = ImageViewEntity(url: photoURL, title: title)
            imageArray?.append(data)
        }
        images.data = self.imageArray
        self.images.append(images)
        if self.images.count == tags.count {
            DispatchQueue.main.async { () -> Void  in
                self.delegate!.onDataLoaded(service: self, data: self.images)
            }
        }
    }
}
