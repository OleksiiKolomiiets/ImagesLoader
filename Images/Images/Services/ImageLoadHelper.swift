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
    
    
    // MARK: method for uploading the image by URL
    static func get(by url: URL, completion: @escaping (UIImage?) -> Void) {
        if let image = ImageLoadHelper.cache[url] {
            completion(image)
        } else {
            loaderQueue.async {
                let image = upload(by: url)
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
    static private func upload(by url: URL) -> UIImage? {
        let imageData = try? Data(contentsOf: url)
        let image = UIImage(data: imageData!)
        self.cache[url] = image
        return image
    }
}




