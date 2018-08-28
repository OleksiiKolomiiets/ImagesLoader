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
    
    static func getImages(by tag: String, complition: @escaping ([ImageViewEntity]?, Error?) -> Void) {
        FlickrKit.shared().call("flickr.photos.search", args: ["tags": tag, "per_page": "25"] ) { (response, error) -> Void in
            DispatchQueue.main.async { () -> Void in
                var photoURLs: [ImageViewEntity]?
                var resultError: Error?
                if (response != nil) {
                    photoURLs = [ImageViewEntity]()
                    // Pull out the photo urls from the results
                    let topPhotos = response!["photos"] as! [String: Any]
                    let photoArray = topPhotos["photo"] as! [[String: Any]]
                    for photoDictionary in photoArray {
                        let title = photoDictionary["title"]! as! String
                        let photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.small240, fromPhotoDictionary: photoDictionary)
                        let data = ImageViewEntity(imageUrl: photoURL, title: title)
                        photoURLs?.append(data)
                    }
                } else if let apiError = error {
                    resultError = apiError
                }
                complition(photoURLs, resultError)
            }
        }
    }
}
