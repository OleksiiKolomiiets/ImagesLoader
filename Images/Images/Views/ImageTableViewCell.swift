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
    
    func configure(with data: CellViewModel) {
        let title = data.title.isEmpty ? ImagesViewControllerSettings.kDefultTitle : data.title
        titleLabel.text = title
        
        spinner.startAnimating()
        if data.image != nil  {
            spinner.stopAnimating()            
            pictureImageView.image = data.image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pictureImageView.image = nil
    }
    
}
