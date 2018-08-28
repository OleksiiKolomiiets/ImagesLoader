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
    var picture: UIImage? {
        didSet {
            spinner?.stopAnimating()
            self.pictureImageView.backgroundColor = .clear
            self.pictureImageView.image = picture
        }
    }
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    func configure(with data: ImageViewEntity) {
        let url = data.imageUrl
        spinner.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let image = try? UIImage(withContentsOfUrl: url)
            DispatchQueue.main.async {                
                if data.imageUrl == url {
                    if data.title.isEmpty {
                        self?.titleLabel.text = "Title doesn't exist."
                    } else {
                        self?.titleLabel.text = data.title
                    }
                    self?.picture = image!
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let screenSize = UIScreen.main.bounds
        let separatorHeight = CGFloat(1.0)
        let additionalSeparator = UIView.init(frame: CGRect(x: 0, y: self.frame.size.height-separatorHeight, width: screenSize.width, height: separatorHeight))
        additionalSeparator.backgroundColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
        self.addSubview(additionalSeparator)
    }
}
