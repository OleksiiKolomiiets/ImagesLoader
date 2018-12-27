//
//  SearchPhotoViewController.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 11/6/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit
import MapKit

class SearchPhotoViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    // MARK: - Outlets:
    
    @IBOutlet private weak var searchTextField: SearchTextField!
    @IBOutlet private weak var mapView: ImagesMapView!
    
    
    // MARK: - Lifecycle SearchPhotoViewController:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.rounded()
    }
    
   
    // MARK: - Functions:
    
    private func loadImageGeoDataBySearchText(_ text: String) {
        FlickrKitHelper.loadPolygonLocation(for: text, perPage: Int.random(in: 5 ... 10)) { imagesData in
            guard let loadedData = imagesData else { return }
           
            self.mapView.setupMapView(with: loadedData)
        }
    }
    
    private func animateAlpha(to alpha: CGFloat, for view: UIView) {
        UIView.animate(withDuration: 0.5, animations: {
            view.alpha = alpha
        })
    }
    
    
    // MARK: - UITextFieldDelegate:
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateAlpha(to: 0.8, for: searchTextField)
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        animateAlpha(to: 0.2, for: searchTextField)
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
    
    
    // MARK: - MKMapViewDelegate:
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        animateAlpha(to: 1.0, for: mapView)
    }
    
}
