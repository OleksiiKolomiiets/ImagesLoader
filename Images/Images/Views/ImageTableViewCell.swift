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

    // MARK: cell configuration
    
    func configure(with data: ImageViewEntity?) {
        pictureImageView.image = #imageLiteral(resourceName: "Placeholder")
        spinner.startAnimating()
//        if let data = data {
//            if data.image != nil {
//                spinner.stopAnimating()
//                pictureImageView.image = data.image
//            }
//        }
        titleLabel.text = data?.title
    }    

}
