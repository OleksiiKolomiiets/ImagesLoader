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
    var picture: UIImage?
    
    // MARK: cell configuration
    
    func configure(with data: ImageViewEntity) {
        pictureImageView.image = #imageLiteral(resourceName: "Placeholder")
        spinner.startAnimating()
//        if data.image != nil {
//            spinner.stopAnimating()
//            pictureImageView.image = data.image
//        }
    }
}

extension UIImage {
    convenience init?(withContentsOfUrl url: URL) throws {
        let imageData = try Data(contentsOf: url)        
        self.init(data: imageData)
    }
    
}

