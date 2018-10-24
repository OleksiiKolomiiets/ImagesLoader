//
//  ViewController.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit
import MobileCoreServices

fileprivate class ImagesViewControllerSettings {
    //MARK: - CONSTANTS
    //Uploading images constants
    static let kImagesPerPage       = 30
    static let kTags                = ["sun", "mercury", "venus", "earth", "mars", "jupiter", "saturn", "uranus", "neptune", "pluto"]
    static let kTagsCountInOneLoad  = 3
    //Reloading constant
    static let kTimeLimit           = 30.0
    // TV == TableView constants
    static let kTVHeightForRow:     CGFloat = 91
    static let kTVHeightForHeader:  CGFloat = 80
    static let kTVCellIdentifier    = "imageCell"
    static let kTVHeaderIdentifier  = "CustomSectionHeaderView"
    static let kTVCellDefaultTitle  = "Title doesn't exist"
    // CV == CollectionView constants
    static let kCVCellIdentifier    = "imageCollectionView"
}

class ImagesViewController: UIViewController {
    
    // MARK: - Outlets:
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var proposeForDropLable: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var dropZoneView: UIView! {
        didSet {
            dropZoneView.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    // MARK:  - Properties:
    private var dataLoader = FlickrImageDataLoader()
    private var reloadingTimer: Timer?
    private var proccesingView: UIView?
    private var removeImagesActionStarts = false
    private var indexOfCellBeforeDragging = 0
    private var removingLongPressGesture: UILongPressGestureRecognizer!
    private var selectedCellPath: IndexPath!
    private var isDragSessionWillBegin = false {
        didSet {
            proposeForDropLable.isHidden.toggle()
            dropZoneView.isHidden.toggle()
        }
    }
    private var collectionViewThrownedImageURLs: [URL]? {
        didSet {
            guard let imageURLs = collectionViewThrownedImageURLs else { return }
            collectionView.reloadData()
            removeImagesActionStarts = !imageURLs.isEmpty
        }
    }
    
    // MARK: - Actions:
    @objc private func longTap(_ gesture: UIGestureRecognizer){
        switch gesture.state {
        case .began:
            // check if it cenceling tap
            if removeImagesActionStarts {
                gesture.state = .cancelled
            }
            // make all cells shaking
            removeImagesActionStarts.toggle()
            self.collectionView.reloadData()
        case .ended:
            if removeImagesActionStarts {
                gesture.state = .cancelled
            }
        default:
            break
        }
    }
    
    @IBAction private func removeButtonTouch(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: collectionView)
        let hitIndex = collectionView.indexPathForItem(at: hitPoint)!
        
        // remove the image and refresh the collection view
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: [hitIndex])
            collectionViewThrownedImageURLs?.remove(at: hitIndex.row)
        })
    }
    
    // MARK: - Functions:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coverTheScreen() // cover the screen while content is downloading
        shadowView.delegate = self
        
        dataLoader.delegate = self
        dataLoader.imageTags = getRandomTags()
        dataLoader.imagesQuantity = ImagesViewControllerSettings.kImagesPerPage
        dataLoader.reload()
        
        let headerNibId = ImagesViewControllerSettings.kTVHeaderIdentifier
        tableView.register(UINib(nibName: headerNibId, bundle: nil), forHeaderFooterViewReuseIdentifier: headerNibId)
        tableView.dragDelegate = self           // didn't find its setting on Storyboard
        tableView.dragInteractionEnabled = true // didn't find its setting on Storyboard
        
        setCustomOpacityAnimation(for: proposeForDropLable)
        
        collectionViewFlowLayout.minimumLineSpacing = 0
        collectionView.dropDelegate = self
        removingLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_:)))
        collectionView.addGestureRecognizer(removingLongPressGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureCollectionViewLayoutItemSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // ending timer work when user go to anothe screen
        reloadingTimer?.invalidate()
        reloadingTimer = nil
    }
    
    // getting random tags
    private func getRandomTags() -> [String] {
        var result = [String]()
        
        let tags = ImagesViewControllerSettings.kTags
        let tagsCount = ImagesViewControllerSettings.kTagsCountInOneLoad
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
        dataLoader.imageTags = getRandomTags()
        dataLoader.reload()
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
        let superViewCentr  = CGPoint(x: view.frame.midX, y: view.frame.midY)
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
        
        animation.fromValue = 0.7
        animation.toValue = 1
        animation.duration = 0.7
        animation.repeatCount = .infinity
        animation.autoreverses = true
        
        view.layer.add(animation, forKey: "Propose opacity")
    }
    
    private func configureCollectionViewLayoutItemSize() {
        // This inset calculation is some magic so the next and the previous cells will peek from the sides
        let inset: CGFloat = calculateSectionInset()
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: inset)
        
        let width = collectionViewFlowLayout.collectionView!.frame.size.width - inset * 2
        let height = collectionViewFlowLayout.collectionView!.frame.size.height
        collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    private func calculateSectionInset() -> CGFloat {
        let deviceIsIpad = UIDevice.current.userInterfaceIdiom == .pad
        let deviceOrientationIsLandscape = UIDevice.current.orientation.isLandscape
        let cellBodyViewIsExpended = deviceIsIpad || deviceOrientationIsLandscape
        let cellBodyWidth: CGFloat = self.collectionView.frame.size.width + (cellBodyViewIsExpended ? self.collectionView.frame.size.width * 0.5 : 0)
        let buttonWidth: CGFloat = self.collectionView.frame.size.width * 0.3
        
        let inset = (collectionViewFlowLayout.collectionView!.frame.width - cellBodyWidth + buttonWidth) / 4
        return inset
    }
    
}

// MARK: - DataLoaderDelegate:
extension ImagesViewController: DataLoaderDelegate {
    func onErrorCatched(dataLoader: FlickrImageDataLoader, error: Error) {
        addBadSignalImage(at: proccesingView!)
    }
    
    func onDataLoaded(dataLoader: FlickrImageDataLoader) {
        proccesingView?.removeFromSuperview()
        tabBarController?.tabBar.isHidden = false
        
        tableView.reloadData()
    }
    
}

// MARK: - ShadowViewDelegate:
extension ImagesViewController: ShadowViewDelegate {
    
    func shadowView(_ shadowView: ShadowView, didUserTapOnHighlightedFrame: Bool) {
        
        shadowView.dismissShadow(animated: true, finished: {
            shadowView.isHidden = true
            
            if didUserTapOnHighlightedFrame {
                let storyboard = UIStoryboard(name: "DetailImage", bundle: Bundle.main)
                let section = self.selectedCellPath.section
                let dataSource = self.dataLoader.flickrKitImageDictionary
                let tag = self.dataLoader.imageTags[section]
                guard  let detailVC = storyboard.instantiateViewController(withIdentifier: "ImageDetailViewController") as? ImageDetailViewController,
                    let flickrDictionary = dataSource[tag] else  { return }
                    
                let row = self.selectedCellPath.row
                let data = flickrDictionary[row]
                let url = FlickrImageDataLoader.getUrlForPhoto(sizeType: .large, using: data)
                detailVC.imageURL = url
                detailVC.isDoneButtonHidden = false
                self.present(detailVC, animated: true)
                
            }
        })
        
        
    }
}

// MARK: - Table view data source:
extension ImagesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = ImagesViewControllerSettings.kTVCellIdentifier
        let section = indexPath.section
        let dataSource = self.dataLoader.flickrKitImageDictionary
        let tag = self.dataLoader.imageTags[section]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ImageTableViewCell,
            let flickrDictionary = dataSource[tag] else {
            return UITableViewCell()
        }
        
        var cellImage: UIImage?
        let row = indexPath.row
        let data = flickrDictionary[row]
        var title = data["title"] as! String
        title = title.isEmpty ? ImagesViewControllerSettings.kTVCellDefaultTitle : title
        let url = FlickrImageDataLoader.getUrlForPhoto(sizeType: .small240, using: data)
        
        if let image = ImageLoadHelper.getImageFromCache(by: url) {
            cellImage = image
        } else {
            ImageLoadHelper.getImage(by: url, completion: { image in
                self.setTableViewCell(by: indexPath, image: image, title: title)
            })
        }
        
        cell.configure(with: cellImage, title) // cell always should be init  cell.imageView.image = nil
        
        return cell
    }
    
    // Configurate reusable cells
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataLoader.flickrKitImageDictionary.count
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
        let headerNibId = ImagesViewControllerSettings.kTVHeaderIdentifier
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerNibId) as! CustomSectionHeaderView
        headerView.setTitle(dataLoader.imageTags[section])
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ImagesViewControllerSettings.kTVHeightForHeader
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTag = dataLoader.imageTags[section]
        return self.dataLoader.flickrKitImageDictionary[sectionTag]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ImagesViewControllerSettings.kTVHeightForRow
    }
    
    // Send selected data to ImageDetailViewController and present it
    private func getGlobalRectangleForCell(at indexPath: IndexPath) -> CGRect {
        let cellTablViewRectangle = tableView.rectForRow(at: indexPath)
        let cellViewRectangle = tableView.convert(cellTablViewRectangle, to: shadowView)
        
        return cellViewRectangle
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCellPath = indexPath
        let globalRectangle = getGlobalRectangleForCell(at: indexPath)
        shadowView.isHidden = false
        shadowView.showShadow(for: globalRectangle, animated: true)
    }
    
}

// MARK: - UICollectionViewDelegate:
extension ImagesViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            indexOfCellBeforeDragging = indexOfMajorCell()
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView == collectionView {
            guard let count = collectionViewThrownedImageURLs?.count else { return }
            // Stop scrollView sliding:
            targetContentOffset.pointee = scrollView.contentOffset
            
            // calculate where scrollView should snap to:
            let indexOfMajorCell = self.indexOfMajorCell()
            
            // calculate conditions:
            let swipeVelocityThreshold: CGFloat = 0.5
            let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < count && velocity.x > swipeVelocityThreshold
            let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
            let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
            let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
            
            if didUseSwipeToSkipCell {
                let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
                let toValue = collectionViewFlowLayout.itemSize.width * CGFloat(snapToIndex)
                
                // Damping equal 1 => no oscillations => decay animation:
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 1,
                               initialSpringVelocity: velocity.x,
                               options: .allowUserInteraction,
                               animations: {
                                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                                scrollView.layoutIfNeeded()},
                               completion: nil)
                
            } else {
                let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
                collectionViewFlowLayout.collectionView!.scrollToItem(at: indexPath, at: .left, animated: true)
            }
        }
    }
    
    private func indexOfMajorCell() -> Int {
        guard let count = collectionViewThrownedImageURLs?.count else { return 0 }
        let itemWidth = collectionViewFlowLayout.itemSize.width
        let proportionalOffset = collectionViewFlowLayout.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let safeIndex = max(0, min(count - 1, index))
        return safeIndex
    }
}

// MARK: - UICollectionViewDataSource:
extension ImagesViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewThrownedImageURLs?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = ImagesViewControllerSettings.kCVCellIdentifier
        guard let view = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        var cellImage: UIImage?
        
        if let url = collectionViewThrownedImageURLs?[indexPath.row] {
            if let image = ImageLoadHelper.getImageFromCache(by: url) {
                cellImage = image
            } else {
                ImageLoadHelper.getImage(by: url) { image in
                    self.setCellForCollectionView(by: indexPath, with: image)
                }
            }
        }
        
        if removeImagesActionStarts {
            view.startAnimateCellRemoving()
        } else {
            view.stopAnimateCellRemoving()
        }
        
        view.configure(with: cellImage)
        
        return view
    }
    
    private func setCellForCollectionView(by indexPath: IndexPath, with image: UIImage?) {
        if let view = self.collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            view.configure(with: image)
            self.collectionView.reloadData()
        }
    }
    
}

// MARK: - UICollectionViewDropDelegate:
extension ImagesViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of collection view.
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        
        for (index, item) in coordinator.items.enumerated() {
            item.dragItem.itemProvider.loadObject(ofClass: FlickrKitImageDataWrapper.self, completionHandler: { (imageData, error) in
                DispatchQueue.main.async {
                    collectionView.performBatchUpdates({ [weak self] in
                        guard let self = self else { return }
                        
                        var indexPaths = [IndexPath]()
                        let indexPath = IndexPath(row: destinationIndexPath.row + index,
                                                  section: destinationIndexPath.section)
                        if let imageData = imageData as? FlickrKitImageDataWrapper {
                            let url = FlickrImageDataLoader.getUrlForPhoto(sizeType: .small320, using: imageData)
                            
                            if let imageURLs = self.collectionViewThrownedImageURLs {
                                if !imageURLs.contains(url) {
                                    self.collectionViewThrownedImageURLs!.append(url)
                                    
                                    let insertIndex = destinationIndexPath.row
                                    let lastIndex = self.collectionViewThrownedImageURLs!.endIndex
                                    for i in (insertIndex + 1 ..< lastIndex).reversed() {
                                        self.collectionViewThrownedImageURLs?.swapAt(i, i - 1)
                                    }
                                    indexPaths.append(indexPath)
                                }
                            } else {
                                self.collectionViewThrownedImageURLs = [url]
                                indexPaths.append(indexPath)
                            }
                        }
                        self.removeImagesActionStarts = false
                        collectionView.insertItems(at: indexPaths)
                        
                    })
                }
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
       
        if session.localDragSession != nil {
            if collectionView.hasActiveDrag {
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            } else {
                return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
    }
}


// MARK: - Drop interaction delegate:
extension ImagesViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: FlickrKitImageDataWrapper.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: FlickrKitImageDataWrapper.self) { imageViewEntity in
            let url = FlickrImageDataLoader.getUrlForPhoto(sizeType: .large, using: imageViewEntity.first as! FlickrKitImageDataWrapper)
            self.setTabBar(with: url)
        }
    }

    
    private func setTabBar(with url: URL) {
        guard let tabBarViewControllers = self.tabBarController?.viewControllers else { return }
        
        if tabBarViewControllers.count < 4 {
            let storyboard = UIStoryboard(name: "DetailImage", bundle: Bundle.main)
            guard let detailVC = storyboard.instantiateViewController(withIdentifier: "ImageDetailViewController") as? ImageDetailViewController else { return }
            
            detailVC.imageURL = url
            detailVC.tabBarItem.title = "Item №\(self.tabBarController!.viewControllers!.endIndex)"
            tabBarController?.viewControllers?.append(detailVC)
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
    
    func tableView(_ tableView: UITableView, dragSessionWillBegin session: UIDragSession) {
        isDragSessionWillBegin = true
    }
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        isDragSessionWillBegin = false
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {        
        return dragItem(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItem(at: indexPath)
    }
     
    private func dragItem(at indexPath: IndexPath) -> [UIDragItem] {
        let section = indexPath.section
        let tagSection = dataLoader.imageTags[section]
        let row = indexPath.row
        let imageData = FlickrKitImageDataWrapper(from: self.dataLoader.flickrKitImageDictionary[tagSection]![row])
        let itemProvider = NSItemProvider(object: imageData)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
}
