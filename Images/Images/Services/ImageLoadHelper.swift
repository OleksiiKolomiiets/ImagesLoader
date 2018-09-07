//
//  ImageLoadHelper.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/28/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation
import UIKit

class ImageLoadHelper {
    
    // MARK: cache for uploaded images
    static private var loaderQueue = DispatchQueue(label: "ImageLoadHelper")
    
    // MARK: cache for uploaded images
    static private var cache = [URL: UIImage]()
    
    // MARK: method for getting mages from cache
    static func getImageFromCache(by url: URL) -> UIImage? {
        return ImageLoadHelper.cache[url]
    }
    
    
    // MARK: method for uploading the image by URL
    static func getImage(by url: URL, completion: @escaping (UIImage?) -> Void) {
        loaderQueue.async {
            let image = upload(by: url)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    static private func upload(by url: URL) -> UIImage? {
        var image: UIImage?
        if let imageData = try? Data(contentsOf: url) {
            image = UIImage(data: imageData)
            self.cache[url] = image
        }
        return image
    }
}




