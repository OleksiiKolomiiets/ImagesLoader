//
//  ImageGeoAnnotationkView.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 11/7/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation
import MapKit

fileprivate class ImageGeoAnnotationkViewSettings {
    static let kSizeOfImage   = 30
    static let kCalloutOffset = CGPoint(x: -5, y: 5)
}

class ImageGeoAnnotationkView: MKAnnotationView {
    
    // MARK: - Property:
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let imageGeoAnnotation = newValue as? ImageGeoAnnotation else {return}            
            setUpAnnotationView(with: imageGeoAnnotation)
        }
    }
    
    
    // MARK: - Functions:
    
    private func setUpAnnotationView(with imageGeoAnnotation: ImageGeoAnnotation) {
        setUpSizeOf(self, with: ImageGeoAnnotationkViewSettings.kSizeOfImage)
        
        setUpCalloutBy(offset: ImageGeoAnnotationkViewSettings.kCalloutOffset)
        
        setUpAnnotationImageFor(self, with: imageGeoAnnotation)
    }
    
    private func setUpAnnotationImageFor(_ view: MKAnnotationView, with imageGeoAnnotation: ImageGeoAnnotation) {
        if let image = ImageLoadHelper.getImageFromCache(by: imageGeoAnnotation.markerIconURL) {
            view.image = image
        } else {
            ImageLoadHelper.loadImage(by: imageGeoAnnotation.markerIconURL) { image in
                view.image = image
            }
        }
    }
    
    private func setUpCalloutBy(offset: CGPoint) {
        canShowCallout = true
        calloutOffset = offset
    }
    
    private func setUpSizeOf(_ view: MKAnnotationView, with ratio: Int) {
        view.frame.size = CGSize(width: ratio, height: ratio)
    }
}
