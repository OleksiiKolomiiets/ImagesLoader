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
    
    // Favorited array of Data
    var droppedImagesData: [Data]!  {
        didSet {
            addToFavoriteImages(using: getImageDataCollection(from: droppedImagesData))
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
    
    private func addToFavoriteImages(using draggedImages: [ImageData]) {
        var savedData = UserDefaults.standard.object(forKey: FavoriteImagesSettings.kUserDefultsKey) as? [Data] ?? [Data]()
        let savedImages = getImageDataCollection(from: savedData)
        var isDataAdded = false
        
        for draggedImage in draggedImages {
            let draggedImageAlreadySaved = savedImages.contains(where: { image -> Bool in
                image.urlLarge1024 == draggedImage.urlLarge1024
            })
            if !draggedImageAlreadySaved {
                let data = getData(fromImageData: draggedImage)!
                savedData.append(data)
                UserDefaults.standard.set(savedData, forKey: FavoriteImagesSettings.kUserDefultsKey)
                
                isDataAdded = true
            }
        }
        
        if isDataAdded {
            uploadFavoriteImagesURL()
        }
    }
    
    private func deleteFavoriteImage(at indexPath: IndexPath) {
        favoriteImagesURL!.remove(at: indexPath.row)
        var userDefaultsData = UserDefaults.standard.object(forKey: FavoriteImagesSettings.kUserDefultsKey) as? [Data] ?? [Data]()
        userDefaultsData.remove(at: indexPath.row)
        UserDefaults.standard.set(userDefaultsData, forKey: FavoriteImagesSettings.kUserDefultsKey)
    }
    
    private func uploadFavoriteImagesURL() {
        let savedData = UserDefaults.standard.object(forKey: FavoriteImagesSettings.kUserDefultsKey) as? [Data] ?? [Data]()
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            deleteFavoriteImage(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    

    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let url = favoriteImagesURL![indexPath.row]
        let storyboard = UIStoryboard(name: "DetailImage", bundle: Bundle.main)
        let imageDetailViewController = storyboard.instantiateViewController(withIdentifier: "ImageDetailViewController") as! ImageDetailViewController
        
        imageDetailViewController.imageURL = url
        imageDetailViewController.isDoneButtonHidden = false
        
        self.present(imageDetailViewController, animated: true)
    }
    
}
