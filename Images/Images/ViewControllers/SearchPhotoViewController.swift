//
//  SearchPhotoViewController.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 11/6/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit
import MapKit

class SearchPhotoViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets:
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - Properties:
    
    private var helper: FlickrKitHelper!
    
    private var imagesGeoData: [ImageGeoData]!
    

    // MARK: - Lifecycle SearchPhotoViewController:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.register(ImageGeoAnnotationkView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        helper = FlickrKitHelper()
    }
    
    // MARK: - Functions:
    
    private func loadImageGeoDataBySearchText(_ text: String) {
        helper.loadPolygonLocation(for: text, perPage: Int.random(in: 5 ... 10)) { imagesGeoData in
            guard let loadedGeoData = imagesGeoData else { return }
            
            self.imagesGeoData = loadedGeoData
            let coordinates = loadedGeoData.map() { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
            
            self.setUpVisibleMapRectForMapView(self.mapView, with: coordinates)
            self.setUpAnnotationsForMapView(self.mapView, with: self.imagesGeoData)
        }
    }
    
    private func setUpAnnotationsForMapView(_ mapView: MKMapView, with imagesGeoData: [ImageGeoData]) {
        mapView.addAnnotations(imagesGeoData.map() { ImageGeoAnnotation(with: $0) })
    }
    
    private func setUpVisibleMapRectForMapView(_ mapView: MKMapView, with coordinates: [CLLocationCoordinate2D]) {
        let mapRects = coordinates.map { coordinate in
            MKMapRect(origin: MKMapPoint(coordinate), size: MKMapSize())
        }
        let fittingRect = mapRects.reduce(MKMapRect.null) { $0.union($1) }
        let inset: CGFloat = 75
        let rectEdgePadding = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
        mapView.setVisibleMapRect(fittingRect, edgePadding: rectEdgePadding, animated: true)
    }
    
    
    // MARK: - UITextFieldDelegate:
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if !mapView.annotations.isEmpty {
            mapView.removeAnnotations(mapView.annotations)
        }
        
        if let text = textField.text,
            !text.isEmpty {
            loadImageGeoDataBySearchText(text)
        }
        
        return true
    }
    
    
    
}
