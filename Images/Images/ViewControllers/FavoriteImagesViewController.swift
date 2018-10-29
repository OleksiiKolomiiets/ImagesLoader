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
    
    private var savingManager = UserDefaultsManager()
    
    public var droppedImagesData: [Data]!  {
        didSet {
            // add to USerDefaults if hasn't already added
                // get saved data
            let savedData = savingManager.savedData(for: FavoriteImagesSettings.kUserDefultsKey)
                // encode it to ImageData
            let savedImages = getImageDataCollection(from: savedData)
                // encode images data that had just dropped to ImageData
            let draggedImages = getImageDataCollection(from: droppedImagesData)
                // check if dose not containe
            var isDataAdded = false
            for draggedImage in draggedImages {
                
                let draggedImageAlreadySaved = savedImages.contains(where: { image -> Bool in
                    image.urlLarge1024 == draggedImage.urlLarge1024
                })
                if !draggedImageAlreadySaved {
                    // append
                    savingManager.append(getData(fromImageData: draggedImage)!, for: FavoriteImagesSettings.kUserDefultsKey)
                    isDataAdded = true
                }
            }
            
            if isDataAdded {
                // refresh favorite images URL collection
                uploadFavoriteImagesURL()
            }
        }
    }
    
    // collection of favorite image urls - data source for tableView
    private var favoriteImagesURL: [URL]? {
        didSet {
            needsToReloadTableViewData = true
        }
    }
    
    private var needsToReloadTableViewData = false
    
    
    // MARK: Methods of view controller lifecycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadFavoriteImagesURL()
    }
    
    // Making bar content light on dark background
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if needsToReloadTableViewData {
            tableView.reloadData()
            needsToReloadTableViewData = false
        }
    }
    
    
    // MARK: Function:
    
    private func uploadFavoriteImagesURL() {
       
        let savedData = savingManager.savedData(for: FavoriteImagesSettings.kUserDefultsKey)
        
        var urlsFromSavedData = [URL]()
        
        for data in savedData {
            
            let imageData = getImageData(from: data)
            guard let url = imageData?.urlLarge1024 else { continue }
            
            urlsFromSavedData.append(url)
        }
        
        favoriteImagesURL = urlsFromSavedData
        
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
    
    private func getImageDataCollection(from dataCollection: [Data]) -> [ImageData] {
        
        var imagesData = [ImageData]()
        
        for data in dataCollection {            
            guard let imageData = getImageData(from: data) else { continue }
            
            imagesData.append(imageData)
        }
        
        return imagesData
    }
    
    private func getData(fromImageData: ImageData) -> Data? {
        return try? JSONEncoder().encode(fromImageData) as Data
    }
    
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteImagesURL?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteImagesSettings.kCellIdentifier, for: indexPath) as! FavoriteImageTableViewCell
        
        var cellImage: UIImage?
        
        if let urls = favoriteImagesURL {
            
            let url = urls[indexPath.row]
            
            if let image = ImageLoadHelper.getImageFromCache(by: url) {
                cellImage = image
            } else {
                ImageLoadHelper.loadImage(by: url, completion: { image in
                    if let cell = tableView.cellForRow(at: indexPath) as? FavoriteImageTableViewCell {
                        cell.setUpImageView(by: image)
                    }
                })
            }
            
        }
        
        cell.setUpImageView(by: cellImage)
        
        return cell
    }

}
