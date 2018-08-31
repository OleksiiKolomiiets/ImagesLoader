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
    
    // MARK: cell reuse
    
    override func prepareForReuse() {
        spinner.startAnimating()
        pictureImageView.image = nil
    }
    
    // MARK: cell configuration
    
    func configure(with image: UIImage) {   
        pictureImageView.image = image
        spinner.stopAnimating()
    }
}

