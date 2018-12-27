//
//  ImageGeoAnnotationkView.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 11/7/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation
import MapKit

fileprivate class ImageGeoAnnotationViewSettings {
    static let kSizeOfImage   = 30
    static let kCalloutOffset = CGPoint(x: -5, y: 5)
}

class ImageGeoAnnotationView: MKAnnotationView {
    
    
    // MARK: - Property:
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let imageGeoAnnotation = newValue as? ImageGeoAnnotation else {return}            
            setupAnnotationView(with: imageGeoAnnotation)
        }
    }
    
    
    // MARK: - View lifecycle methods:
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        image = nil
    }
    
    
    // MARK: - Functions:
    
    private func setupAnnotationView(with imageGeoAnnotation: ImageGeoAnnotation) {
               
        setupSizeOf(self, with: ImageGeoAnnotationViewSettings.kSizeOfImage)
        
        setupCalloutBy(offset: ImageGeoAnnotationViewSettings.kCalloutOffset)
        
        setupAnnotationImageFor(self, with: imageGeoAnnotation)
    }
    
    private func setupAnnotationImageFor(_ view: MKAnnotationView, with imageGeoAnnotation: ImageGeoAnnotation) {
        if let image = ImageLoadHelper.getImageFromCache(by: imageGeoAnnotation.markerIconURL) {
            view.image = image
        } else {
            ImageLoadHelper.loadImage(by: imageGeoAnnotation.markerIconURL) { image in
                view.image = image
            }
        }
    }
    
    private func setupCalloutBy(offset: CGPoint) {
        canShowCallout = true
        calloutOffset = offset
    }
    
    private func setupSizeOf(_ view: MKAnnotationView, with ratio: Int) {
        view.frame.size = CGSize(width: ratio, height: ratio)
    }
}
