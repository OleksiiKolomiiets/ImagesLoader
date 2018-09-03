//
//  ImageCollectionViewCell.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var pictureImageView: UIImageView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!

   
    // MARK: cell configuration
    
    func configure(with image: UIImage?) {
        
        if image == nil {
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
            pictureImageView.image = image
        }
    }
    
    override func prepareForReuse() {
        print(pictureImageView.image ?? "nil")
        if pictureImageView.image == nil {
             spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }
        
    }
}

