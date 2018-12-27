//
//  GEOLocationViewController.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 11/5/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit
import MapKit

class GEOLocationViewController: UIViewController, MKMapViewDelegate {


    // MARK: - Outlets:

    @IBOutlet weak var mapView: ImagesMapView!

    @IBOutlet weak var doneButton: UIButton!

    // MARK: - Properties:

    public var imagesData: [ImageData]!


    // MARK: - Lifecycle methods of view cintroller

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.setupMapView(with: imagesData)
        doneButton.rounded()
    }


    // MARK: - Actions:

    @IBAction func doneButtonTouched(_ sender: UIButton) {
        self.dismiss(animated: true)
    }


    // MARK: - MKMapViewDelegate:

    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            mapView.alpha = 1.0
        })
    }
}
