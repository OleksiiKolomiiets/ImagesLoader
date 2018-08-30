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
    func onDataLoaded(service: ImageService, data: [String : ImageViewEntity])
}

class ImageService {
    
    var tags: [String]
    weak var delegate: ImageServiceDelegate?
    
    init(tags: [String]) {
        self.tags = tags
    }
    
    func reload() {
        let imagesQuantity = ImagesViewControllerSettings.cNumberOfUploadingImages
        tags.forEach() { tag in
            self.getImagesData(imagesQuantity, by: tag)
        }
    }
    
    var imageArray: [ImageViewEntity]? {
        didSet {
            imageArray?.forEach() {
                print($0.title)
                print($0.url)
            }
        }
    }
    
    func getImageEntities(from source: [[String: Any]]) {
        imageArray = [ImageViewEntity]()
        for photoDictionary in source {
            let title = photoDictionary["title"]! as! String
            let photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.small240, fromPhotoDictionary: photoDictionary)
            let data = ImageViewEntity(url: photoURL, title: title)
            imageArray?.append(data)
        }
    }
    
    func getImagesData(_ quantity: Int, by tag: String) {
        OperationQueue().addOperation() {
            let quantity = String(quantity)
            FlickrKit.shared().call("flickr.photos.search", args: ["tags": tag, "per_page": quantity] ) { (response, error) -> Void in
                if (response != nil) {
                    let topPhotos = response!["photos"] as! [String: Any]
                    let photoArray = topPhotos["photo"] as? [[String: Any]]
                    DispatchQueue.main.async { () -> Void  in
                        self.getImageEntities(from: photoArray!)
                    }
                } else if let apiError = error {
                    // TODO: handle the errors
                }
            }
        }
    }
}

class ImageLoadHelper {
    
    static var cache = [URL: UIImage]()
    
    var url: URL
    var image: UIImage?
    
    init(url: URL) {
        self.url = url
        setImage()
    }
    
    private func setImage() {
        let image = try? UIImage(withContentsOfUrl: self.url)
        self.image = image!
    }
    
}

