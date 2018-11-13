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
    
    @IBOutlet weak var searchTextField: SearchTextField!
    @IBOutlet weak var mapView: ImagesMapView!
    
    
    // MARK: - Lifecycle SearchPhotoViewController:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.rounded()
    }
    
   
    // MARK: - Functions:
    
    private func loadImageGeoDataBySearchText(_ text: String) {
        FlickrKitHelper.loadPolygonLocation(for: text, perPage: Int.random(in: 5 ... 10)) { imagesData in
            guard let loadedData = imagesData else { return }
           
            self.mapView.setUpMapView(with: loadedData)
        }
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
