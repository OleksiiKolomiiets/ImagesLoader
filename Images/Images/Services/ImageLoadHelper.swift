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
    
    static var cache = [URL: UIImage]()
    
    // MARK: method for uploading the image by URL
    
    static func uploadImage(by url: URL, completion: @escaping (UIImage?, Error?) -> Void) {
        if cache.contains(where: { $0.key == url}),
            let image = cache[url] {
            completion(image, nil)
        } else {
            OperationQueue().addOperation() {
                guard let imageData = try? Data(contentsOf: url),
                    let image = UIImage(data: imageData) else {
                        completion(nil, FetchingError.invalidData("URL is invalid", url))
                        return
                }
                cache[url] = image
                completion(image, nil)
            }
        }
    }
    
}


