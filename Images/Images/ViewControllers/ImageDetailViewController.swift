//
//  ImageDetailViewController.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 9/7/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController, UIScrollViewDelegate {

    // MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadActivityIndicator: UIActivityIndicatorView!
    
    var imageData: ImageViewEntity!
    var image: UIImage? {
        didSet {
            // MARK: reacting when image is set
            self.imageView.image = image
            self.imageView.sizeToFit()
            self.scrollView.contentSize = self.imageView.frame.size
        }
    }
    
    // MARK: action for ending display selected image
    @IBAction func done(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func doubleTap(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.maximumZoomScale {
            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: sender.location(in: sender.view)), animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width  = imageView.frame.size.width  / scale
        let newCenter = scrollView.convert(center, from: imageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.maximumZoomScale = 2
        scrollView.delegate = self
        if imageView.image == nil {
            fetchImage()
        }
    }
    
    // MARK: Making bar content light on black background
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Using scroll delegate method for zooming the image
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // MARK: Calculating mimum zoom scale for scroll view according to image sizes
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
    
    // MARK: Getting image to display
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
