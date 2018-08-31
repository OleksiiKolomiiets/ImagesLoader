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
    
    var tags: [String]
    weak var delegate: ImageServiceDelegate?
    private var imageArray: [ImageViewEntity]?
    
    init(tags: [String]) {
        self.tags = tags
    }
    
    // MARK: start to upload images data
    
    func reload() {
        let imagesQuantity = ImagesViewControllerSettings.cNumberOfUploadingImages
        tags.forEach() { tag in
            self.getImagesData(imagesQuantity, by: tag)
        }
        
    }
    
    // MARK: getting images URL and title
    
    private func getImagesData(_ quantity: Int, by tag: String) {
        let images = Images(tag: tag, data: nil)
        OperationQueue().addOperation() {
            DispatchQueue.global(qos: .userInitiated).async { () -> Void  in
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
        imageArray = [ImageViewEntity]()
        for photoDictionary in source {
            let title = photoDictionary["title"]! as! String
            let photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.small240, fromPhotoDictionary: photoDictionary)
            let data = ImageViewEntity(url: photoURL, title: title)
            imageArray?.append(data)
        }
        images.data = self.imageArray
        DispatchQueue.main.async { () -> Void  in
            self.delegate!.onDataLoaded(service: self, data: images)
        }
    }
}
