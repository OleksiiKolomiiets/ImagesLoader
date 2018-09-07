//
//  ImageDetailViewController.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 9/7/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadActivityIndicator: UIActivityIndicatorView!
    
    var imageData: ImageViewEntity!
        
    @IBAction func done(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        if imageView.image == nil {
            fetchImage()
        }
    }
    
    private func fetchImage() {
        let sizedPhotoUrl = ImageService.getUrlForPhoto(using: imageData)
        print(sizedPhotoUrl)
        print(imageData.url)
        
        if let image = ImageLoadHelper.getImageFromCache(by: sizedPhotoUrl) {
            imageView.image = image
        } else {
            loadActivityIndicator.startAnimating()
            ImageLoadHelper.getImage(by: sizedPhotoUrl) { image in
                self.loadActivityIndicator.stopAnimating()
                self.imageView.image = image
            }
        }
    }
    

}