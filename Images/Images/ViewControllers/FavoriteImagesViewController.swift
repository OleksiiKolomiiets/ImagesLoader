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
    static let kMaxImagesCount = 4
}

class FavoriteManager {
    
    // MARK: - Properties
    
    static let shared = FavoriteManager()
    
    // MARK: -
    
    private let userDefaults = UserDefaults.standard
    
    public var favoriteImages = [ImageData]()
    
    private var favoriteImagesKey      = FavoriteImagesSettings.kUserDefultsKey
    private var favoriteImagesMaxCount = FavoriteImagesSettings.kMaxImagesCount
    
    // Initialization
    
    private init() {}
    
    func save(_ draggedData: [Data], completion: @escaping () -> ()) {
        var savedData = userDefaults.object(forKey: favoriteImagesKey) as? [Data] ?? [Data]()
        
        if favoriteImages.count < favoriteImagesMaxCount {
            
            var draggedImages = [ImageData]()
            for data in draggedData {
                let draggedImageData = getImageData(from: data)
                draggedImages.append(draggedImageData)
            }
            
            var isDataAdded = false
            
            for draggedImage in draggedImages {
                let draggedImageAlreadySaved = favoriteImages.contains(where: { image -> Bool in
                    image.urlLarge1024 == draggedImage.urlLarge1024
                })
                if !draggedImageAlreadySaved {
                    favoriteImages.append(draggedImage)
                    let data = getData(fromImageData: draggedImage)
                    savedData.append(data)
                    isDataAdded = true
                }
            }
            
            if isDataAdded {
                userDefaults.set(savedData, forKey: favoriteImagesKey)
            }
        } else {
            completion()
        }
    }
    
    func deleteImage(at index: Int) {
        favoriteImages.remove(at: index)
        
        var userDefaultsData = userDefaults.object(forKey: favoriteImagesKey) as? [Data] ?? [Data]()
        userDefaultsData.remove(at: index)
        userDefaults.set(userDefaultsData, forKey: favoriteImagesKey)
    }
    
    func download() {
        let savedData = userDefaults.object(forKey: favoriteImagesKey) as? [Data] ?? [Data]()
        for data in savedData {
            let imageData = getImageData(from: data)
            favoriteImages.append(imageData)
        }
    }
    
    private func getImageData(from data: Data) -> ImageData {
        return try! JSONDecoder().decode(ImageData.self, from: data)
    }
    
    private func getData(fromImageData: ImageData) -> Data {
        return try! JSONEncoder().encode(fromImageData) as Data
    }
}

class FavoriteImagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets:
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties:
    
    // Favorited array of Data
    var droppedImagesData: [Data]!  {
        didSet {
            
            //addToFavoriteImages(using: getImageDataCollection(from: droppedImagesData))
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
        
        FavoriteManager.shared.download()
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
        return FavoriteManager.shared.favoriteImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteImagesSettings.kCellIdentifier, for: indexPath) as! FavoriteImageTableViewCell
        
        var cellImage: UIImage?
        
        let url = FavoriteManager.shared.favoriteImages[indexPath.row].urlLarge1024
        
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
            FavoriteManager.shared.deleteImage(at: indexPath.row)
//            deleteFavoriteImage(at: indexPath)
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
