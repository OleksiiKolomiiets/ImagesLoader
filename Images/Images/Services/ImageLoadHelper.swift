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
    
    static func uploadImage(by url: URL, completion: @escaping (UIImage?) -> Void) {
        OperationQueue().addOperation() {
            let imageData = try? Data(contentsOf: url)
            let image = UIImage(data: imageData!)
            cache[url] = image
            OperationQueue.main.addOperation() {
                completion(image)
            }            
        }
    }
    
}


