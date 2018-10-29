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
    static let kUserDefultsKey = "SavedFavoriteImagesDataArray"
}

class FavoriteImagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: Outlets:
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: Properties:
    
    private var savingHelper: UserDefaultsManager!
    
    public var favoritedImagesData: [Data]! {
        didSet {            
            updateFavoriteImagesData()
        }
    }
    
    private var favoritesImagesURLs: [URL]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    // MARK: Methods of view controller lifecycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        savingHelper = UserDefaultsManager(key: FavoriteImagesSettings.kUserDefultsKey)
        
        updateFavoriteImagesData()
    }
    
    // Making bar content light on dark background
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: Function:
    
    private func updateFavoriteImagesData() {
       
        var resultArray: [URL]?
        
        let savedData = UserDefaults.standard.object(forKey: FavoriteImagesSettings.kUserDefultsKey) as? [Data] ?? [Data]()
        
        for data in savedData {
            
            let imageData = getImageData(from: data)
            
            guard let url = imageData?.urlLarge1024 else { break }
            
            if resultArray != nil {
                resultArray!.append(url)
            } else {
                resultArray = [url]
            }
        }
        
        favoritesImagesURLs = resultArray
        
        guard let favoritedImagesData = favoritedImagesData else { return }
        
        for imageData in favoritedImagesData {
            self.savingHelper.append(imageData)
        }
        
    }
    
    private func getImageData(from data: Data) -> ImageData? {
        
        var imageData: ImageData?
        
        do {
            imageData = try JSONDecoder().decode(ImageData.self, from: data)
        } catch {
            print(ImageDataError.invalidData.localizedDescription)
        }
        
        return imageData
    }
    
    private func getData(from imageData: ImageData) -> Data? {
        return try? JSONEncoder().encode(imageData) as Data
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
                cell.setUpImageView(by: image)
            } else {
                ImageLoadHelper.loadImage(by: url, completion: { image in
                    if let cell = tableView.cellForRow(at: indexPath) as? FavoriteImageTableViewCell {
                        cell.setUpImageView(by: image)
                    }
                })
            }
            
        }
        
        return cell
    }

}
