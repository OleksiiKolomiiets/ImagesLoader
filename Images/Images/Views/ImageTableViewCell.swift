//
//  ImageTableViewCell.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: cell reuse
    
    override func prepareForReuse() {
        spinner.startAnimating()
        pictureImageView.image = nil
    }

    // MARK: cell configuration
    
    func configure(with image: UIImage, title: String) {
        spinner.stopAnimating()
        pictureImageView.image = image
        titleLabel.text = String(title.prefix(18))
    }    

}
