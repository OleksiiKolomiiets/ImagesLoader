//
//  ImageVC+ImageServiceDelegate.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 9/27/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

protocol ImageServiceDelegate: class {
    func onDataLoaded(service: ImageService, data: [ImagesViewSource])
}

// =============================
// MARK: - ImageServiceDelegate:
// =============================

extension ImagesViewController: ImageServiceDelegate {
    
    func onDataLoaded(service: ImageService, data: [ImagesViewSource]) {
        dataSource = data
        imagesCollectionViewController.dataSourceCollectionView = data.first
        tableView.reloadData()
        imagesCollectionViewController.collectionView.reloadData()
    }
    
}
