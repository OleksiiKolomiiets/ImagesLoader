//
//  ViewController.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

//MARK: - CONSTANTS
class ImagesViewControllerSettings {
    
    //MARK: Uploading images constants
    static let kNumberOfUploadingImages: Int = 30
    static let kTags = ["sun", "mercury", "venus", "earth", "mars", "jupiter","saturn", "uranus", "neptune", "pluto"]
    static let kDefultTitle = "Title doesn't exist"
    static let kNumberOfTagsInOneLoad = 3
    static let kCellsImageDimension:ImageDimensionType = .small
    //MARK: Reloading constant
    static let kTimeLimit = 30.0
    //MARK: Table view constants
    static let kHeightForRow: CGFloat = 91
    static let kHeightForHeader: CGFloat = 80
    static let kCellIdentifierForTableView: String = "imageCell"
    //MARK: Collection view constants
    static let kCellIdentifierForCollectionView: String = "imageCollectionView"
    static let kCellPaddingQuote: CGFloat = 0.1
    static let kCellWidthQuote: CGFloat = 0.8
}

// MARK: - Delegate for service
protocol ImageServiceDelegate: class {
    func onDataLoaded(service: ImageService, data: [ImagesViewSource])
}
//
//// MARK: - Delegate for animate view cover
//protocol ImageServiceDelegate: class {
//    func onDataLoaded(service: ImageService, data: [ImagesViewSource])
//}

// MARK: - CLASS
class ImagesViewController: UIViewController, ImageServiceDelegate {
    
    // ================
    // MARK: - Outlets:
    // ================
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dropZoneView: UIView! {
        didSet {
            dropZoneView.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    // ====================
    // MARK:  - Properties:
    // ====================
    
    private var service: ImageService!
    private var reloadingTimer: Timer?
    private var randomIndices = [Int]()
    private var imagesCollectionViewController: ImagesCollectionViewController!
    private var proccesingView: UIView?
    var indexOfCellBeforeDragging = 0
    var draggedItem: IndexPath?
    var dataSource: [ImagesViewSource]? {
        willSet {
            if dataSource == nil {
                proccesingView?.removeFromSuperview()
                tabBarController?.tabBar.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coverTheScreen()
        service = ImageService()
        service.delegate = self        
        service.imageTags = getRandomTags()
        service.reload()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // ending timer work when user go to anothe screen
        reloadingTimer?.invalidate()
        reloadingTimer = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startTimer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let embededCV = segue.destination as? ImagesCollectionViewController {
            self.imagesCollectionViewController = embededCV
        }
    }
    
    // ==================
    // MARK: - Functions:
    // ==================
    
    // getting random tags
    private func getRandomTags() -> [String] {
        var result = [String]()
        
        let tags = ImagesViewControllerSettings.kTags
        let tagsCount = ImagesViewControllerSettings.kNumberOfTagsInOneLoad
        let allTagsCount = tags.count
        let randomIndices = getRandomIndices(number: tagsCount, allTagsCount)
        
        randomIndices.forEach() { result.append(tags[$0]) }        
        
        return result
    }
    
    // getting random indices for tags collection
    private func getRandomIndices(number: Int, _ max: Int) -> [Int] {
        var result = [Int]()
    
        for _ in 0 ..< number {
            var index = Int(arc4random_uniform(UInt32(max)))
            
            while result.contains(index) {
                index += 1
                if index >= max - 1 {
                    index = 0
                }
            }
            
            result.append(index)
        }
        
        return result
    }
    
    // setting datasource from delegate method
    func onDataLoaded(service: ImageService, data: [ImagesViewSource]) {
        dataSource = data
        imagesCollectionViewController.dataSourceCollectionView = data.first
        tableView.reloadData()
        imagesCollectionViewController.collectionView.reloadData()
    }
    
    // start to count time for reload
    private func startTimer() {
        let reloadTimeInterval = ImagesViewControllerSettings.kTimeLimit
        if reloadingTimer == nil {
            reloadingTimer = Timer.scheduledTimer(timeInterval: reloadTimeInterval,
                                         target: self,
                                         selector: #selector(onTimerTick),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    // reloading data source
    @objc private func onTimerTick() {
        service.imageTags = getRandomTags()
        service.reload()
    }
    
    private func coverTheScreen() {
        proccesingView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        proccesingView?.backgroundColor = .white
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        imageView.image = UIImage(named: "space")
        imageView.layer.opacity = 0.8
        imageView.contentMode = .scaleAspectFill
        tabBarController?.tabBar.isHidden = true
        proccesingView?.addSubview(imageView)
        view.addSubview(proccesingView!)
    }
    
}
