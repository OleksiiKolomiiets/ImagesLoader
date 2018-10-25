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
    
    
    // MARK: Properties:
    
    private var favoritesImagesURLs: [URL]?
    
    
    // MARK: Methods of view controller lifecycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesImagesURLs?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteImagesSettings.kCellIdentifier, for: indexPath) as! FavoriteImageTableViewCell
        
        if let urls = favoritesImagesURLs {
            
            let url = urls[indexPath.row]
            
            if let image = ImageLoadHelper.getImageFromCache(by: url) {
                cell.setImageView(by: image)
            } else {
                ImageLoadHelper.loadImage(by: url, completion: { image in
                    if let cell = tableView.cellForRow(at: indexPath) as? FavoriteImageTableViewCell {
                        cell.setImageView(by: image)
                    }
                })
            }
            
        }
        
        return cell
    }

}
