//
//  FavoriteImagesViewController.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 10/25/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

fileprivate class FavoriteImagesSettings {
    static let kCellIdentifier = "favoriteImageCelIdentifier"
}

class FavoriteImagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets:
    
    @IBOutlet weak var tableView: UITableView!
    
    // Making bar content light on dark background
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: VC Lifrcycle:
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoriteManager.allFavoriteImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteImagesSettings.kCellIdentifier, for: indexPath) as! FavoriteImageTableViewCell
        
        var cellImage: UIImage?
        
        let url = FavoriteManager.allFavoriteImages[indexPath.row].urlLarge1024
        
        if let image = ImageLoadHelper.getImageFromCache(by: url) {
            cellImage = image
        } else {
            ImageLoadHelper.loadImage(by: url, completion: { image in
                if let cell = tableView.cellForRow(at: indexPath) as? FavoriteImageTableViewCell {
                    cell.setUpImageView(by: image)
                }
            })
        }
        
        cell.setUpImageView(by: cellImage)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            FavoriteManager.deleteFavoriteImage(FavoriteManager.allFavoriteImages[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let url = FavoriteManager.allFavoriteImages[indexPath.row].urlLarge1024
        let storyboard = UIStoryboard(name: "DetailImage", bundle: Bundle.main)
        let imageDetailViewController = storyboard.instantiateViewController(withIdentifier: "ImageDetailViewController") as! ImageDetailViewController
        
        imageDetailViewController.imageURL = url
        imageDetailViewController.isDoneButtonHidden = false
        
        self.present(imageDetailViewController, animated: true)
    }
    
}
