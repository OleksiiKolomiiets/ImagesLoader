//
//  ImageCollectionViewCell.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var picture: UIImage? {
        didSet {
            spinner?.stopAnimating()
            self.pictureImageView.image = picture
        }
    }
    func configure(with data: ImageViewEntity) {
        let url = data.imageUrl
        spinner.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            let image = try? UIImage(withContentsOfUrl: url)
            DispatchQueue.main.async {
                if url == data.imageUrl {
                    self.picture = image!
                }
            }
        }
    }
}

extension UIImage {
    
    convenience init?(withContentsOfUrl url: URL) throws {
        let imageData = try Data(contentsOf: url)        
        self.init(data: imageData)
    }
    
}
