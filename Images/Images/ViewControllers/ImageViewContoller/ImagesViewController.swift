//
//  ViewController.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol ImageServiceDelegate: class {
    func onDataLoaded(service: ImageService, data: [ImagesViewSource])
}
protocol ShadowViewDelegate: class {
    func tapSubmit(isSuccess: Bool)
}


class ImagesViewControllerSettings {
    //MARK: - CONSTANTS
    //Uploading images constants
    static let kNumberOfUploadingImages: Int = 30
    static let kTags = ["sun", "mercury", "venus", "earth", "mars", "jupiter","saturn", "uranus", "neptune", "pluto"]
    static let kDefultTitle = "Title doesn't exist"
    static let kNumberOfTagsInOneLoad = 3
    static let kCellsImageDimension:ImageDimensionType = .small
    //Reloading constant
    static let kTimeLimit = 30.0
    //Table view constants
    static let kHeightForRow: CGFloat = 91
    static let kHeightForHeader: CGFloat = 80
    static let kCellIdentifierForTableView: String = "imageCell"
    //Collection view constants
    static let kCellIdentifierForCollectionView: String = "imageCollectionView"
    static let kCellPaddingQuote: CGFloat = 0.1
    static let kCellWidthQuote: CGFloat = 0.8
}

class ImagesViewController: UIViewController {
    
    // MARK: - Outlets:
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var dropZoneView: UIView! {
        didSet {
            dropZoneView.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    // MARK:  - Properties:
    private var service = ImageService()
    private var reloadingTimer: Timer?
    private var randomIndices = [Int]()
    private var proccesingView: UIView?    
    var imagesCollectionViewController: ImagesCollectionViewController!
    var indexOfCellBeforeDragging = 0
    var draggedCellPath: IndexPath?
    var selectedCellPath: IndexPath!
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
        shadowView.delegate = self
        service.delegate = self
        service.imageTags = getRandomTags()
        service.reload()
        tableView.dragDelegate = self           // didn't find its setting on Storyboard
        tableView.dragInteractionEnabled = true // didn't find its setting on Storyboard
        
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
    
    // MARK: - Functions:
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

// MARK: - ImageServiceDelegate:
extension ImagesViewController: ImageServiceDelegate {
    
    func onDataLoaded(service: ImageService, data: [ImagesViewSource]) {
        dataSource = data
        imagesCollectionViewController.dataSourceCollectionView = data.first
        tableView.reloadData()
        imagesCollectionViewController.collectionView.reloadData()
    }
    
}

// MARK: - ShadowViewDelegate:
extension ImagesViewController: ShadowViewDelegate {
    func tapSubmit(isSuccess: Bool) {
        shadowView.isHidden.toggle()        
        if case true = isSuccess {
            let storyboard = UIStoryboard(name: "DetailImage", bundle: Bundle.main)
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "ImageDetailViewController") as? ImageDetailViewController,
                let dataSource = self.dataSource?[selectedCellPath.section], let data = dataSource.data?[selectedCellPath.row] {
                detailVC.imageData = data
                detailVC.doneButtonisHidden = false
                self.present(detailVC, animated: true)
            }
        }
    }
}

// MARK: - Table view data source:
extension ImagesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = ImagesViewControllerSettings.kCellIdentifierForTableView
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ImageTableViewCell else {
            return UITableViewCell()
        }
        
        var cellImage: UIImage?
        let section = indexPath.section
        let row = indexPath.row
        let title = dataSource?[section].data?[row].title
        
        if let url = dataSource?[section].data?[row].url {
            if let image = ImageLoadHelper.getImageFromCache(by: url) {
                cellImage = image
            } else {
                ImageLoadHelper.getImage(by: url, completion: { image in
                    self.setTableViewCell(by: indexPath, image: image, title: title!)
                })
            }
        }
        
        cell.configure(with: cellImage, title!) // cell alway should be init  cel.imageView.image = nil
        
        return cell
    }
    
    // Configurate reusable cells
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.count ?? 0
    }
    
    private func setTableViewCell(by indexPath: IndexPath, image: UIImage?, title: String) {
        if let cell = tableView.cellForRow(at: indexPath) as? ImageTableViewCell {
            cell.configure(with: image, title)
        }
    }
    
}

// MARK: - Table view delegate:
extension ImagesViewController: UITableViewDelegate {
    
    // Configurate header section view
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CustomSectionHeaderView.instantiate(with: self)
        view.setTitle(dataSource?[section].tag)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ImagesViewControllerSettings.kHeightForHeader
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?[section].data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ImagesViewControllerSettings.kHeightForRow
    }
    
    // Send selected data to ImageDetailViewController and present it
    private func calculateCoordinatesForSelectedArea(at indexPath: IndexPath) -> CircleArea {
        let cellRect = tableView.rectForRow(at: indexPath)
        let cellGlobalPosition = tableView.convert(cellRect, to: view)
        
        let yPosition = cellGlobalPosition.origin.y
        let xPosition = cellGlobalPosition.origin.x
        let width = cellGlobalPosition.size.width
        let height = cellGlobalPosition.size.height
        
        let cellCentrPoint = CGPoint(x: xPosition + width / 2, y: yPosition + height / 2)
        let highlightedAreaRadius = height * 0.9 / 2
        
        return CircleArea(centr: cellCentrPoint, radius: highlightedAreaRadius)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCellPath = indexPath
        let circleArea = calculateCoordinatesForSelectedArea(at: indexPath)
        self.shadowView.highlightedArea = circleArea
    }
    
}

// MARK: - Drop interaction delegate:
extension ImagesViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSString.self) { nsstrings in
            // parsing sended string
            let string = nsstrings.first as! String
            let stringArray = string.split(separator: " ")
            let section = Int(String(stringArray.first!))
            let row = Int(String(stringArray.last!))
            self.draggedCellPath = IndexPath(row: row!, section: section!)
            self.enableTabBar()
            
        }
    }
    
    private func enableTabBar() {
        self.tabBarController?.viewControllers?.forEach() { viewController in
            if let vc = viewController as? ImageDetailViewController,
                let draggedItem = self.draggedCellPath {
                vc.imageData = self.dataSource![draggedItem.section].data![draggedItem.row]
            }
        }
    }
}

// MARK: - Drag interaction delegate:
extension ImagesViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItem(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        dropZoneView.isHidden.toggle()
    }
    
    func tableView(_ tableView: UITableView, dragSessionWillBegin session: UIDragSession) {
        dropZoneView.isHidden.toggle()
    }
    
    private func dragItem(at indexPath: IndexPath) -> [UIDragItem] {
        let item = "\(indexPath.section) \(indexPath.row)" // create string to send via drag
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}
