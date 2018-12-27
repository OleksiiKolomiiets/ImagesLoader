//
//  ImagesMapView.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 11/13/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit
import MapKit

fileprivate class ImagesMapViewSetings {
    static let kEdgePaddingInsets: CGFloat = 75
}

class ImagesMapView: MKMapView {
    
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        register(ImageGeoAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    
    // MARK: - Functions:
    
    public func setupMapView(with imagesData: [ImageData]) {
        
        addAnnotations(imagesData.map() { ImageGeoAnnotation(with: $0) })
        
        let cootdinates = getCoordinates(from: imagesData)
        
        if imagesData.count == 1,
            let singlePoint = cootdinates.first {
            setCenter(singlePoint, animated: true)
        } else {
            setupVisibleMapRectForMapView(with: cootdinates)
        }
    }
    
    private func setupVisibleMapRectForMapView(with coordinates: [CLLocationCoordinate2D]) {
        let mapRects = coordinates.map { coordinate in
            MKMapRect(origin: MKMapPoint(coordinate), size: MKMapSize())
        }
        let fittingRect = mapRects.reduce(MKMapRect.null) { $0.union($1) }
        let inset = ImagesMapViewSetings.kEdgePaddingInsets
        let rectEdgePadding = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
        setVisibleMapRect(fittingRect, edgePadding: rectEdgePadding, animated: true)
    }
    
    private func getCoordinates(from imageData: [ImageData]) -> [CLLocationCoordinate2D] {
        let geoData = imageData.map({ $0.geoData! })
        return geoData.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)})
    }
}

