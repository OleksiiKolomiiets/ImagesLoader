//
//  ImageDetailViewController.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 9/7/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController, UIScrollViewDelegate {
    
    
    // MARK: - Outlets:
    
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var imageView  : UIImageView!
    @IBOutlet weak var spinner    : UIActivityIndicatorView!
    @IBOutlet weak var tabButton  : UITabBarItem!
    @IBOutlet weak var doneButton : UIButton!
    @IBOutlet weak var geoButton  : UIButton!
    
    
    // MARK: - Variables:
    
    private var isImageDataSetted = false
    
    public var isDoneButtonHidden = true    
    public var imageData: ImageData! {
        didSet {
            isImageDataSetted = true
        }
    }
    
    
    // MARK: - Actions:
    
    // action for ending display selected image
    @IBAction func doneButtonTouched(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // show geo coordinate of an image
    @IBAction func geoButtonTapped(_ sender: UIButton) {
        let geoLocationViewController = UIStoryboard(name: "GEOLocation", bundle: nil).instantiateViewController(withIdentifier: "GEOLocationViewController") as! GEOLocationViewController
        geoLocationViewController.imagesData = [imageData]
        self.present(geoLocationViewController, animated: true)
        
        
    }
    
    // action when immage tapped twice
    @objc private func doubleTapped(sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
    
    
    // MARK: - VC Lifecycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDoubleTapGesture(to: view)
        doneButton.isHidden = isDoneButtonHidden
        doneButton.rounded()
        geoButton.rounded()
    }
    
    // Making bar content light on black background
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.frame = view.frame
        if imageView != nil, isImageDataSetted {
            fetchImage()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isImageDataSetted = false
    }
    
    
    // MARK: - Functions:
    
    private func setUpImageView(_ imageView: UIImageView, with image: UIImage?) {
        imageView.image = image
        imageView.sizeToFit()
        centerImageView(imageView, in: imageView.superview as! UIScrollView)
        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
            self.imageView.alpha = 1.0
        }, completion: nil)
    }
    
    private func setUpScrolView(_ scrollView: UIScrollView, with image: UIImage?) {
        guard let image = image else { return }
        setUpMinMaxZoomScale(for: scrollView, dependingOnSizeOf: image)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
    }
    
    private func addDoubleTapGesture(to view: UIView) {
        // adding double tap gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(sender:)))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }
    
    private func centerImageView(_ imageView: UIImageView, in scrollView: UIScrollView) {
        let imageViewSize   = imageView.frame.size
        let scrollViewSize  = scrollView.bounds.size
        let verticalInset   = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 1
        let horizontalInset = imageViewSize.width  < scrollViewSize.width  ? (scrollViewSize.width - imageViewSize.width)   / 2 : 1
        
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset) 
    }
    
    // Calculating minimum and maximum zoom scale for scroll view according to image sizes
    private func setUpMinMaxZoomScale(for scrollView: UIScrollView, dependingOnSizeOf image: UIImage) {
        
        // calculating minimum and maximum zoom scale for scroll view
        let width = image.size.width
        let height = image.size.height
        
        let verticalScale = scrollView.frame.size.height / height
        let horizontalScale = scrollView.frame.size.width / width
        
        let minScale = min(verticalScale, horizontalScale)
        let maxScale = max(verticalScale, horizontalScale)
        
        // setting minimum and maximum zoom scale for scroll view
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = maxScale
    }
    
    // Fetching image to display
    private func fetchImage() {
        if let cachedImage = ImageLoadHelper.getImageFromCache(by: imageData.urlLarge1024) {
            self.setUpImageView(self.imageView, with: cachedImage)
            self.setUpScrolView(self.scrollView, with: cachedImage)
        } else {
            spinner.startAnimating()
            ImageLoadHelper.loadImage(by: imageData.urlLarge1024) { [weak self] loadedImage in
                guard let strongSelf = self else { return }
                strongSelf.spinner.stopAnimating()
                strongSelf.setUpImageView(strongSelf.imageView, with: loadedImage)
                strongSelf.setUpScrolView(strongSelf.scrollView, with: loadedImage)
            }
        }
    }


    // MARK: - UIScrollViewDelegate:
    
    // Using scroll delegate method for zooming the image
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // set image to the center of view
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageView(imageView, in: scrollView)
    }
}
