//
//  FavoriteImageTableViewCell.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 10/25/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class FavoriteImageTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var favoriteImageView: UIImageView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    
    public func setUpImageView(by image: UIImage?) {
        
        if image == nil {
            
            spinner.startAnimating()
            
        } else {
            
            spinner.stopAnimating()
            favoriteImageView.image = image
        }
    }
}
