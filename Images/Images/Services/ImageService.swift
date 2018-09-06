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
    
    private let imageDataLoader = DispatchQueue(label: "ImageService")
    
    var tags: [String]?
    
    // MARK: dataSource for table and collection views
    
    private var imagesData = [Images]()
    
    weak var delegate: ImageServiceDelegate?
      
    // MARK: start to upload images data
    
    func reload() {
        imagesData.removeAll()
        let imagesQuantity = ImagesViewControllerSettings.kNumberOfUploadingImages
        tags?.forEach() { tag in
            self.getImagesData(imagesQuantity, by: tag)
        }
        
    }
    
    // MARK: getting images URL and title
    
    private func getImagesData(_ quantity: Int, by tag: String) {
        let images = Images(tag: tag, data: nil)       
        let quantity = String(quantity)
        imageDataLoader.async {
            FlickrKit.shared().call("flickr.photos.search", args: ["tags": tag, "per_page": quantity] ) { (response, error) -> Void in
                guard error == nil, (response != nil)  else { return }
                let topPhotos = response!["photos"] as! [String: Any]
                let photoArray = topPhotos["photo"] as? [[String: Any]]
                
                self.getImageEntities(from: photoArray!, to: images)
            }
        }
    }
    
    private func getImageEntities(from source: [[String: Any]], to images: Images) {
        var images = images
        var imageArray =  [ImageViewEntity]()
        for photoDictionary in source {
            let title = photoDictionary["title"]! as! String
            let photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.small240, fromPhotoDictionary: photoDictionary)
            let data = ImageViewEntity(url: photoURL, title: title)
            imageArray.append(data)
        }
        images.data = imageArray
        self.imagesData.append(images)
        if self.imagesData.count == tags?.count {
            DispatchQueue.main.async { () -> Void  in
                self.delegate!.onDataLoaded(service: self, data: self.imagesData)
            }
        }
    }
}
