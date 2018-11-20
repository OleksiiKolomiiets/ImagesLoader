//
//  ImageTableViewCell.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    // MARK: - Outlets:
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var pictureImageView: UIImageView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!    
    
    // MARK: - Functions:
    // cleaning cell before reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        pictureImageView.image = nil
    }
    
    // cell configuration
    public func configure(with image: UIImage?, _ title: String) {
        
        titleLabel.text = title
        
        if image != nil  {
            spinner.stopAnimating()
            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseIn, animations: {
                self.pictureImageView.alpha = 1.0
            }, completion: nil)            
        } else {
            spinner.startAnimating()
            pictureImageView.alpha = 0.0
        }
        
        pictureImageView.image = image
    }
    
}
