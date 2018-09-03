//
//  ImageTableViewCell.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var pictureImageView: UIImageView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!    
    
    // MARK: cell configuration
    
    func configure(with image: UIImage?, title: String) {
        titleLabel.text = title
        
        if image != nil  {
            spinner.stopAnimating()            
            pictureImageView.image = image
        }
    }
    
    override func prepareForReuse() {
        pictureImageView.image = nil
        spinner.startAnimating()
    }

}
