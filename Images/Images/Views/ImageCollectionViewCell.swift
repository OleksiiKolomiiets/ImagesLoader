//
//  ImageCollectionViewCell.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    //=================
    // MARK: - Outlets:
    //=================
    
    @IBOutlet private weak var pictureImageView: UIImageView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    
    //===================
    // MARK: - Functions:
    //===================
    
    // cleaning cell before reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        pictureImageView.image = nil
    }
    
    // cell configuration
    func configure(with image: UIImage?) {                
        if image != nil {
            spinner.stopAnimating()
        } else {
            spinner.startAnimating()
        }        
        pictureImageView.image = image
    }
    
    // method for testing
    
    func setCell() {
        spinner.startAnimating()
        pictureImageView.layer.borderWidth = 1
        pictureImageView.layer.cornerRadius = 15
        pictureImageView.layer.borderColor = UIColor.white.cgColor
    }
}

