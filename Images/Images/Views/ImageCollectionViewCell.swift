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
    @IBOutlet private weak var removeButton: UIButton!
    
    // MARK: - Variables:
    var isAnimate: Bool! = true
    
    // MARK: - Functions:
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // cleaning cell before reuse
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
    
    func startAnimateCellRemoving() {
        removeButton.isHidden = false
        
        let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnimation.duration = 0.05
        shakeAnimation.repeatCount = 4
        shakeAnimation.autoreverses = true
        shakeAnimation.duration = 0.2
        shakeAnimation.repeatCount = .infinity
        
        let startAngle: Float = (-2) * Float.pi/180
        let stopAngle = -startAngle
        
        shakeAnimation.fromValue = NSNumber(value: startAngle as Float)
        shakeAnimation.toValue = NSNumber(value: 2 * stopAngle as Float)
        shakeAnimation.autoreverses = true
        shakeAnimation.timeOffset = 290 * drand48()
        
        let layer: CALayer = self.layer
        layer.add(shakeAnimation, forKey:"animate")
        isAnimate = true
    }
    
    func stopAnimateCellRemoving() {
        removeButton.isHidden = true
        
        let layer: CALayer = self.layer
        layer.removeAnimation(forKey: "animate")
        isAnimate = false
    }
}

