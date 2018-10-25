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
    
    // MARK: - Variables:
    static private var loaderQueue = DispatchQueue(label: "ImageLoadHelper") // Custom thread for uploading images
    static private var cache = [URL: UIImage]()  // Cache for uploaded images
    
    // MARK: - Functions:
    // Method for getting images from cache
    static func getImageFromCache(by url: URL) -> UIImage? {
        return ImageLoadHelper.cache[url]
    }
    
    // Method for loading the image by URL
    static func loadImage(by url: URL, completion: @escaping (UIImage?) -> Void) {
        
        loaderQueue.async {
            let image = downloadImage(by: url)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    // Method for downloading the image by URL
    static private func downloadImage(by url: URL) -> UIImage? {
        
        var image: UIImage?
        
        if let imageData = try? Data(contentsOf: url) {
            image = UIImage(data: imageData)
            self.cache[url] = image
        }
        
        return image
    }
    
}
