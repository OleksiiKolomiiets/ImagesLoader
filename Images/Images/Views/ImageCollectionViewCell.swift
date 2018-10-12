//
//  ImageCollectionViewCell.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets:
    @IBOutlet private weak var pictureImageView: UIImageView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var dropZoneAnimatedView: UIView!
    
    // MARK: - Functions:
    // cleaning cell before reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        pictureImageView.image = nil
    }
    
    // cell configuration
    func configure(with image: UIImage?) {                
        if image != nil {
            spinner.stopAnimating()
        } else {
            spinner.startAnimating()
        }        
        pictureImageView.image = image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // method for testing
    func setCell() {
        spinner.startAnimating()
        pictureImageView.layer.borderWidth = 1
        pictureImageView.layer.cornerRadius = 15
        pictureImageView.layer.borderColor = UIColor.white.cgColor
    }
    
    func setAnimationForDropZone() {
        if dropZoneAnimatedView.layer.sublayers == nil {
            let yourViewBorder = CAShapeLayer()
            yourViewBorder.strokeColor = UIColor.black.cgColor
            yourViewBorder.lineDashPattern = [8, 6]
            
            yourViewBorder.frame = dropZoneAnimatedView.bounds
            
            print(yourViewBorder.frame)
            yourViewBorder.fillColor = nil
            yourViewBorder.path = UIBezierPath(roundedRect: dropZoneAnimatedView.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 20, height: 20)).cgPath
            //        yourViewBorder.path = UIBezierPath(rect: dropZoneView.bounds).cgPath
            dropZoneAnimatedView.layer.addSublayer(yourViewBorder)
            
            let animation = CABasicAnimation(keyPath: "lineDashPhase")
            animation.fromValue = 0
            animation.toValue = yourViewBorder.lineDashPattern?.reduce(0) { $0 - $1.intValue } ?? 0
            animation.duration = 1
            animation.repeatCount = .infinity
            yourViewBorder.add(animation, forKey: "line")
        }
    }
}

