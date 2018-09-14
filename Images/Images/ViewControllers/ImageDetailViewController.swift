//
//  ImageDetailViewController.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 9/7/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    var imageData: ImageViewEntity!
    var image: UIImage? {
        didSet {
            // MARK: reacting when image is set
            self.imageView.image = image
            self.imageView.sizeToFit()
            setImageCentred()
        }
    }
    
    // MARK: - Actions
    
    // action for ending display selected image
    @IBAction func done(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // action when immage tapped twice
    @objc func doubleTapped(sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if imageView.image == nil {
            fetchImage()
        }
        
        // adding double tap gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(sender:)))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }
    
    
    // Making bar content light on black background
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Using scroll delegate method for zooming the image
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
     // set image to the center of view
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setImageCentred()
    }
    
    fileprivate func setImageCentred() {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        let verticalInset = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 1
        let horizontalInset = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 1
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
    
    // Calculating mimum zoom scale for scroll view according to image sizes
    private var minimumZoomScale: CGFloat {
        let width = imageView.frame.size.width
        let height = imageView.frame.size.height
        
        var scale: CGFloat = 0.0
        if width > height {
            scale = view.frame.size.width / width
        } else {
            scale = view.frame.size.height / height
        }
        return scale
    }
    
    // Getting image to display
    private func fetchImage() {
        let sizedPhotoUrl = ImageService.getUrlForPhoto(using: imageData)
        
        if let cachedImage = ImageLoadHelper.getImageFromCache(by: sizedPhotoUrl) {
            self.image = cachedImage
        } else {
            loadActivityIndicator.startAnimating()
            ImageLoadHelper.getImage(by: sizedPhotoUrl) { loadedImage in
                self.loadActivityIndicator.stopAnimating()
                self.image = loadedImage
                self.scrollView.minimumZoomScale = self.minimumZoomScale
            }
        }
    }

}
