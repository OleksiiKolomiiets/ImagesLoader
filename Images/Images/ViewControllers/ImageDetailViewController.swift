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

    //=================
    // MARK: - Outlets:
    //=================
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tabButton: UITabBarItem!
    @IBOutlet weak var doneButton: UIButton!
    
    //===================
    // MARK: - Variables:
    //===================
    
    var imageData: ImageViewEntity! {
        didSet {
            isImageDataSetted = true
            if imageView != nil,
                imageView.image != nil {
                imageView.image = nil
            }
        }
    }
    var image: UIImage? {
        didSet {
            imageView.image = image
            imageView.sizeToFit()
            setImageCentred()
            var max = maxScale
            var min = minScale
            if min > max{
                let temp = max
                max = min
                min = temp
            }
            scrollView.minimumZoomScale = min
            scrollView.maximumZoomScale = max
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        }
    }
    var doneButtonisHidden = true
    var isImageDataSetted = false
    
    //=================
    // MARK: - Actions:
    //=================
    
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
    
    //===================
    // MARK: - Functions:
    //===================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // adding double tap gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(sender:)))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
        doneButton.isHidden = doneButtonisHidden
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(isImageDataSetted)
        scrollView.frame = view.frame
        if imageView != nil,
            isImageDataSetted {
            fetchImage()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isImageDataSetted = false
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
    
    // Calculating mimum and maximum zoom scale for scroll view according to image sizes
   
    private var maxScale: CGFloat {
        let width = image!.size.width
        let height = image!.size.height
        return (width >= height) ? (view.frame.size.height / height) :   (view.frame.size.width / width)
    }
    
    private var minScale: CGFloat {
        let width = image!.size.width
        let height = image!.size.height
        return (width >= height) ? (view.frame.size.width / width)   : (view.frame.size.height / height)
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
            }
        }
    }

}
