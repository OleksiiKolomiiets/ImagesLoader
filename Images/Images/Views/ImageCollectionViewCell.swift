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

    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var widthImageConstraint: NSLayoutConstraint!
    // MARK: cell configuration
    
    func configure(with image: UIImage?) {
                
        if image != nil {
            spinner.stopAnimating()
        } else {
            spinner.startAnimating()
        }        
        pictureImageView.image = image
        
        if let sidePaddings = superview?.superview?.superview?.superview?.superview?.superview?.superview?.frame.size.width {
            rightConstraint.constant = sidePaddings * 0.1
            leftConstraint.constant = sidePaddings * 0.1
            widthImageConstraint.constant = sidePaddings * 0.8
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pictureImageView.image = nil
    }
}

