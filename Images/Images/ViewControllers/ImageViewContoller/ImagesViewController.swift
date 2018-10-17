//
//  ViewController.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit
import MobileCoreServices

class ImagesViewControllerSettings {
    //MARK: - CONSTANTS
    //Uploading images constants
    static let kNumberOfUploadingImages: Int = 30
    static let kTags = ["sun", "mercury", "venus", "earth", "mars", "jupiter","saturn", "uranus", "neptune", "pluto"]
    static let kDefultTitle = "Title doesn't exist"
    static let kNumberOfTagsInOneLoad = 3
    static let kCellsImageDimension:ImageDimensionType = .small240
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
    @IBOutlet weak var proposeForDropLable: UILabel!
    
    // MARK:  - Properties:
    private var service = ImageService()
    private var reloadingTimer: Timer?
    private var randomIndices = [Int]()
    private var proccesingView: UIView?
    var imagesCollectionViewController: ImagesCollectionViewController!
    var indexOfCellBeforeDragging = 0
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
        
        coverTheScreen() // cover the screen while content is downloading
        shadowView.delegate = self
        service.delegate = self
        service.imageTags = getRandomTags()
        service.reload()
        tableView.dragDelegate = self           // didn't find its setting on Storyboard
        tableView.dragInteractionEnabled = true // didn't find its setting on Storyboard
        setCustomOpacityAnimation(for: proposeForDropLable)
        
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
            embededCV.superViewController = self
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
    
     private lazy var badSignalImageView: UIImageView = {
        let badSignalImage = UIImage(named: "badSignal")!
        let imageWidth: CGFloat = badSignalImage.size.width
        let imageHeight: CGFloat = badSignalImage.size.height
        let superViewCentr  = view.frame.centr
        let badSignalImageView = UIImageView(frame: CGRect(x: superViewCentr.x - imageWidth / 2,
                                                           y: superViewCentr.y - imageHeight / 2,
                                                           width: imageWidth,
                                                           height: imageHeight))
        badSignalImageView.image = badSignalImage
        badSignalImageView.contentMode = .scaleAspectFill
        return badSignalImageView
    }()
    
    func addBadSignalImage(at view: UIView) {
        setCustomOpacityAnimation(for: badSignalImageView)
        
        view.addSubview(badSignalImageView)
    }
    
    private func setCustomOpacityAnimation(for view: UIView) {
        // add opacity animation
        let animation = CABasicAnimation(keyPath: "opacity")
        
        animation.fromValue = 0.5
        animation.toValue = 0.7
        animation.duration = 0.7
        animation.repeatCount = .infinity
        animation.autoreverses = true
        
        view.layer.add(animation, forKey: "Propose opacity")
    }
    
}

// MARK: - ImageServiceDelegate:
extension ImagesViewController: ImageServiceDelegate {
    func onErrorCatched(service: ImageService, error: Error) {
        addBadSignalImage(at: proccesingView!)
    }
    
    func onDataLoaded(service: ImageService, data: [ImagesViewSource]) {
        badSignalImageView.removeFromSuperview()
        dataSource = data
        tableView.reloadData()
        imagesCollectionViewController.collectionView.reloadData()
    }
    
}

// MARK: - ShadowViewDelegate:
extension ImagesViewController: ShadowViewDelegate {
    
    func shadowView(_ shadowView: ShadowView, didUserTapOnHighlightedArea: Bool) {
        
        shadowView.dismissShadow(animated: true, finished: {
            shadowView.isHidden = true
            
            if didUserTapOnHighlightedArea {
                let storyboard = UIStoryboard(name: "DetailImage", bundle: Bundle.main)
                if let detailVC = storyboard.instantiateViewController(withIdentifier: "ImageDetailViewController") as? ImageDetailViewController,
                    let dataSource = self.dataSource?[self.selectedCellPath.section],
                    let data = dataSource.data?[self.selectedCellPath.row] {
                    let url = ImageService.getUrlForPhoto(using: data)
                    detailVC.imageURL = url
                    detailVC.isDoneButtonHidden = false
                    self.present(detailVC, animated: true)
                }
            }
        })
        
        
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
        
        if let data = dataSource?[section].data?[row] {
            let url = ImageService.getUrlForPhoto(using: data)
            
            if let image = ImageLoadHelper.getImageFromCache(by: url) {
                cellImage = image
            } else {
                ImageLoadHelper.getImage(by: url, completion: { image in
                    self.setTableViewCell(by: indexPath, image: image, title: title!)
                })
            }
        }
        
        cell.configure(with: cellImage, title!) // cell always should be init  cell.imageView.image = nil
        
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
    private func getCircleAreaForCell(at indexPath: IndexPath) -> CircleArea {
        let cellRect = tableView.rectForRow(at: indexPath)
        let cellGlobalPosition = tableView.convert(cellRect, to: shadowView)
        
        return CircleArea(with: cellGlobalPosition)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCellPath = indexPath
        let circleArea = getCircleAreaForCell(at: indexPath)
        shadowView.isHidden = false
        shadowView.showShadow(for: circleArea, animated: true)
    }
    
}

// MARK: - Drop interaction delegate:
extension ImagesViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSURL.self) { nsurl in
            if var imageURLs = self.imagesCollectionViewController.imageURLs {
                imageURLs.append(nsurl.first as! URL)                
            } else {
                self.imagesCollectionViewController.imageURLs = [nsurl.first as! URL]
            }
        }
        /*
         For adding dragged item to queue of tab bar controllers(max three items)
         
        session.loadObjects(ofClass: NSURL.self) { nsurl in
            self.setTabBar(with: nsurl.first as! URL)
        }
         */
    }

    
    private func setTabBar(with url: URL) {
        guard let tabBarViewControllers = self.tabBarController?.viewControllers else { return }
        
        if tabBarViewControllers.count < 4 {
            let storyboard = UIStoryboard(name: "DetailImage", bundle: Bundle.main)
            guard let detailVC = storyboard.instantiateViewController(withIdentifier: "ImageDetailViewController") as? ImageDetailViewController else { return }
            
            detailVC.imageURL = url
            detailVC.tabBarItem.title = "Item №\(self.tabBarController!.viewControllers!.endIndex)"
            self.tabBarController?.viewControllers?.append(detailVC)
        } else {
            for (viewControllerIndex, viewController) in tabBarViewControllers.enumerated() {
                guard let vc = viewController as? ImageDetailViewController else { continue }
                
                if viewControllerIndex < tabBarViewControllers.count - 1 {
                    guard let nextVC = tabBarViewControllers[viewControllerIndex + 1] as? ImageDetailViewController else { return }
                    vc.imageURL = nextVC.imageURL
                } else {
                    vc.imageURL = url
                }
                
            }
        }
    }
}

// MARK: - Drag interaction delegate:
extension ImagesViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {        
        return dragItem(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItem(at: indexPath)
    }
     
    private func dragItem(at indexPath: IndexPath) -> [UIDragItem] {
        let imageData = dataSource![indexPath.section].data![indexPath.row]
        let itemProvider = NSItemProvider(object: imageData)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
}
