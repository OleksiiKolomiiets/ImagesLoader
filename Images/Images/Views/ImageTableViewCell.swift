//
//  ImageTableViewCell.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    //=================
    // MARK: - Outlets:
    //=================
    
    @IBOutlet private weak var titleLabel: UILabel!
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
    func configure(with image: UIImage?,_ title: String) {
        titleLabel.text = title.isEmpty ? ImagesViewControllerSettings.kDefultTitle : title
        
        if image != nil  {
            spinner.stopAnimating()
        } else {
            spinner.startAnimating()
        }
        pictureImageView.image = image
    }
    
}
