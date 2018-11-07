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
    
    private var coordinates: [CLLocationCoordinate2D] = []
    
    private var defaultVisibleMapRect: MKMapRect!
    

    // MARK: - Lifecycle SearchPhotoViewController:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaultVisibleMapRect = self.mapView.visibleMapRect
        
        helper = FlickrKitHelper()
        searchTextField.delegate = self
    }
    
    
    // MARK: - UITextFieldDelegate:
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        coordinates.removeAll()
        mapView.removeAnnotations(self.mapView.annotations)
        
        if let text = textField.text,
            !text.isEmpty {
            
            helper.loadPolygonLocation(for: text, perPage: Int.random(in: 5 ... 10), completion: { imagesGeoDataDictionary in
                
                imagesGeoDataDictionary.forEach() { (imageId, imageGeoData) in
                    let pointAnnotation = MKPointAnnotation()
                    pointAnnotation.title = imageGeoData.region + ", " + imageGeoData.country
                    let coordinate = CLLocationCoordinate2D(latitude: imageGeoData.latitude, longitude: imageGeoData.longitude)
                    pointAnnotation.coordinate = coordinate
                    self.coordinates.append(coordinate)
                    self.mapView.addAnnotation(pointAnnotation)
                }
                
                let rects = self.coordinates.map { MKMapRect(origin: MKMapPoint($0), size: MKMapSize()) }
                let fittingRect = rects.reduce(MKMapRect.null) { $0.union($1) }
                let inset:CGFloat = 32
                let rectEdgePadding = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
                
                self.mapView.setVisibleMapRect(fittingRect, edgePadding: rectEdgePadding, animated: true)
            })
        } else {
            self.mapView.setVisibleMapRect(defaultVisibleMapRect, animated: true)
        }
        
        return true
    }
    
    
    
}
