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
    
    // cleaning cell before reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        favoriteImageView.image = nil
    }
    
    public func setUpImageView(by image: UIImage?) {
        
        if image != nil {
            spinner.stopAnimating()
            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseIn, animations: {
                self.favoriteImageView.alpha = 1.0
            }, completion: nil)
        } else {
            spinner.startAnimating()
            favoriteImageView.alpha = 0.0
        }
        
        favoriteImageView.image = image
    }
}
