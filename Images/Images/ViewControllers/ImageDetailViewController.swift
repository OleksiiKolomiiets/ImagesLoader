//
//  ImageDetailViewController.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 9/7/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

//MARK: - CONSTANTS

class ImageDetailViewControllerSettings {
    
    // Uploading images constants
    static let kDetailImageDimension:ImageDimensionType = .large
}

//MARK: - CLASS

class ImageDetailViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Outlets:
    @IBOutlet weak var scrollView           : UIScrollView!
    @IBOutlet weak var imageView            : UIImageView!
    @IBOutlet weak var loadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tabButton            : UITabBarItem!
    @IBOutlet weak var doneButton           : UIButton!
    
    // MARK: - Variables:
    var isDoneButtonHidden = true
    var isImageDataSetted = false
    var imageURL: URL! {
        willSet {
            isImageDataSetted = true
            if imageView != nil {
                imageView.image = nil
            }
        }
    }
    var image: UIImage? {
        didSet {
            imageView.image = image
            imageView.sizeToFit()
            setImageCentred()
            setZoomScale()
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        }
    }
    
    // MARK: - Actions:
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
    
    // MARK: - Functions:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDoubleTapGesture(for: view)
        doneButton.isHidden = isDoneButtonHidden
        
    }
    
    // Making bar content light on black background
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.frame = view.frame
        if imageView != nil,
            isImageDataSetted {
            fetchImage()
        }
    }
    
    // Using scroll delegate method for zooming the image
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // set image to the center of view
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setImageCentred()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isImageDataSetted = false
    }
    
    
    private func addDoubleTapGesture(for view: UIView) {
        // adding double tap gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(sender:)))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }
    
    private func setImageCentred() {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        let verticalInset = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 1
        let horizontalInset = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 1
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset) 
    }
    
    // Calculating minimum and maximum zoom scale for scroll view according to image sizes
    private func setZoomScale() {
        let width = image!.size.width
        let height = image!.size.height
        
        let verticalScale = view.frame.size.height / height
        let horizontalScale = view.frame.size.width / width
        
        let minScale = min(verticalScale, horizontalScale)
        let maxScale = max(verticalScale, horizontalScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = maxScale
    }
    
    // Getting image to display
    private func fetchImage() {
        if let cachedImage = ImageLoadHelper.getImageFromCache(by: imageURL) {
            self.image = cachedImage
        } else {
            loadActivityIndicator.startAnimating()
            ImageLoadHelper.getImage(by: imageURL) { loadedImage in
                self.loadActivityIndicator.stopAnimating()
                self.image = loadedImage
            }
        }
    }

}
