//
//  ImageDetailViewController.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 9/7/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            self.scrollView.addSubview(self.imageView)
        }
    }
    @IBOutlet weak var loadActivityIndicator: UIActivityIndicatorView!
    
    var imageData: ImageViewEntity!
    var imageView = UIImageView()
    var image: UIImage? {
        didSet {
            self.imageView.image = image
            self.imageView.sizeToFit()
            self.scrollView.contentSize = self.imageView.frame.size
        }
    }
        
    @IBAction func done(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.maximumZoomScale = 1.2
        scrollView.minimumZoomScale = 1/2
        scrollView.delegate = self
        if imageView.image == nil {
            fetchImage()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    private func fetchImage() {
        let sizedPhotoUrl = ImageService.getUrlForPhoto(using: imageData)
        
        if let cachedImage = ImageLoadHelper.getImageFromCache(by: sizedPhotoUrl) {
            self.image = cachedImage
        } else {
            loadActivityIndicator.startAnimating()
            ImageLoadHelper.getImage(by: sizedPhotoUrl) { loadedImage in
                self.loadActivityIndicator.stopAnimating()
                self.image = loadedImage
            }
        }
    }

}
