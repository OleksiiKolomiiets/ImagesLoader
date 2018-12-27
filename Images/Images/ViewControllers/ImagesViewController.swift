//
//  ViewController.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit
import MobileCoreServices


//MARK: - CONSTANTS

fileprivate class ImagesViewControllerSettings {

    //Uploading images constants
    static let kImagesPerPage       = 20
    static let kTags                = ["Greenland", "Australia", "Yellowstone", "California", "Nepal", "Ireland", "Venezuela", "Galapagos", "Peru", "Jordan"]
    static let kTagsCountInOneLoad  = 3
    static let kTabBarVScMaxCount   = 3

    //Reloading constant
    static let kTimeLimit           = 30.0
    static let kTimeLimitAfterFail  = 5.0

    // TV == TableView constants
    static let kTVHeightForRow      : CGFloat = 91
    static let kTVHeightForHeader   : CGFloat = 80
    static let kTVCellIdentifier    = "imageCell"
    static let kTVHeaderIdentifier  = "CustomSectionHeaderView"
    static let kTVCellDefaultTitle  = "Title doesn't exist"
    static let kTVTappedRadius      : CGFloat = 25

    // CV == CollectionView constants
    static let kCVCellIdentifier    = "imageCollectionView"
    
    // Animation constants
    
    static let kOpacityAnimationKey = "opacity"
}

// MARK: -
class ImagesViewController: UIViewController {

    // MARK: Outlets:

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
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


    // MARK: Properties:

    private var imageDataDictionary: [String: [ImageData]]?
    private var imageTags: [String]?

    private var reloadTimer: Timer?
    private var removeImagesActionStarts = false
    private var indexOfCellBeforeDragging = 0
    private var removingLongPressGesture: UILongPressGestureRecognizer!
    
    private var selectedCellPath: IndexPath!
    private var tappedLocation: CGPoint!
    
    private var lastTableViewContentOffset: CGFloat = 0
    private var isScrollForced = false
    private var hasNetworkProblems = false
    private var isDragSessionWillBegin: Bool! {
        didSet {
            proposeForDropLable.isHidden = !isDragSessionWillBegin
            dropZoneView.isHidden = !isDragSessionWillBegin
        }
    }
    private var collectionViewThrownedImageURLs: [URL]?

    private var randomTags: [String] {

        var result = [String]()

        let tags = ImagesViewControllerSettings.kTags
        let tagsCount = ImagesViewControllerSettings.kTagsCountInOneLoad
        let allTagsCount = tags.count
        let randomIndices = getRandomIndices(number: tagsCount, allTagsCount)

        randomIndices.forEach() { result.append(tags[$0]) }

        return result
    }

    // MARK: Actions:

    // Method to switch remove action:
    @objc private func longTap(_ gesture: UIGestureRecognizer) {

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

    @objc private func goToFavoriteImages() {
        guard let tabBarViewControllers = tabBarController?.viewControllers else { return }
        for viewController in tabBarViewControllers {
            if viewController is FavoriteImagesViewController {
                tabBarController!.selectedViewController = viewController
                break
            }
        }
    }

    // Remove elements from collection view method:
    @IBAction private func removeButtonTouch(_ sender: UIButton) {

       
    }


    // MARK: Lifecycle Methods:

    override func viewDidLoad() {
        super.viewDidLoad()

        customizeOpacityAnimation(for: logoImageView)
        
        shadowView.delegate = self

        // reload image data from helper
        reloadImages()

        // prepare table view
        let headerNibId = ImagesViewControllerSettings.kTVHeaderIdentifier
        tableView.register(UINib(nibName: headerNibId, bundle: nil), forHeaderFooterViewReuseIdentifier: headerNibId)
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true

        customizeOpacityAnimation(for: proposeForDropLable)

        // prepare collection view
        collectionViewFlowLayout.minimumLineSpacing = 0
        collectionView.dropDelegate = self
        removingLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_:)))
        collectionView.addGestureRecognizer(removingLongPressGesture)
    }
    
    // Making bar content light on dark background
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        configureCollectionViewLayoutItemSize()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        startReloadTimer(with: ImagesViewControllerSettings.kTimeLimit)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // ending timer work when user go to anothe screen

        stopReloadTimer()
        
        stopAnimateVisibleCellsIfAnimating(for: collectionView)
        
    }


    // MARK: Functions:

    // getting random indices for tags collection
    private func getRandomIndices(number: Int, _ max: Int) -> [Int] {

        var result = [Int]()

        for _ in 0 ..< number {
            var index = Int.random(in: 0 ..< max)

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

    // start to count time for reload image data
    private func startReloadTimer(with timeInterval: TimeInterval) {
        if reloadTimer == nil {
            reloadTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                  target: self,
                                                  selector: #selector(onTimerTick),
                                                  userInfo: nil,
                                                  repeats: false)
            reloadTimer?.tolerance = 1
            // reloadTimer won't fire when the UI is being used
            RunLoop.current.add(reloadTimer!, forMode: RunLoop.Mode.common)

        }
    }

    @objc private func onTimerTick() {
        reloadImages()
    }

    // stop timer for reload image data
    private func stopReloadTimer() {
        if reloadTimer != nil {
            reloadTimer?.invalidate()
            reloadTimer = nil
        }
    }

    // reloading data source
    private func reloadImages() {

        stopReloadTimer()

        let tags = randomTags

        FlickrKitHelper.load(for: tags, perPage: ImagesViewControllerSettings.kImagesPerPage) { imageDataDictionary, errors in

            if errors != nil {

                self.hasNetworkProblems = true

            } else {
                self.hasNetworkProblems = false

                self.imageTags = tags
                self.imageDataDictionary = imageDataDictionary

                self.tableView.reloadData()
            }

            self.startReloadTimer(with: self.hasNetworkProblems ? ImagesViewControllerSettings.kTimeLimitAfterFail : ImagesViewControllerSettings.kTimeLimit)
            
            UIView.animate(withDuration: 0.5, delay: 0.4, options: .curveEaseIn, animations: {
                self.headerView.alpha = 1.0
                self.logoImageView.layer.removeAllAnimations()
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseIn, animations: {
                    self.tableView.alpha = 1.0
                }, completion: { _ in
                    self.tabBarController?.tabBar.items?.enumerated().forEach() { (index, item) in
                        let tabItemType = TabBarType(rawValue: index)
                        item.image = tabItemType?.image
                        item.title = tabItemType?.title
                    }
                })
            })
            
        }
    }

    private func customizeOpacityAnimation(for view: UIView) {
        // create opacity animation
        let animation = CABasicAnimation(keyPath: ImagesViewControllerSettings.kOpacityAnimationKey)

        animation.fromValue = 0.7
        animation.toValue = 1
        animation.duration = 0.7
        animation.repeatCount = .infinity
        animation.autoreverses = true
        // create opacity animation to view
        view.layer.add(animation, forKey: ImagesViewControllerSettings.kOpacityAnimationKey)
    }

    private func configureCollectionViewLayoutItemSize() {

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

    // Getting the image data from source for current cell
    private func getImageData(by indexPath: IndexPath) -> ImageData {

        let section = indexPath.section
        let row = indexPath.row

        let imageTag = imageTags![section]
        let imageDataSource = imageDataDictionary![imageTag]

        return imageDataSource![row]
    }
    
    private func stopAnimateVisibleCellsIfAnimating(for collectionView: UICollectionView) {
        if removeImagesActionStarts {
            removeImagesActionStarts = false
            collectionView.visibleCells.forEach { collectionViewCell in
                if let cell = collectionViewCell as? ImageCollectionViewCell {
                    cell.stopAnimateCellRemoving()
                }
            }
        }
    }
    


}

// MARK: - ShadowViewDelegate:

extension ImagesViewController: ShadowViewDelegate {

    func shadowView(_ shadowView: ShadowView, didUserTapOnHighlightedFrame: Bool) {

        shadowView.dismissShadow(animated: true, finished: {

            shadowView.isHidden = true
            self.tableView.deselectRow(at: self.selectedCellPath, animated: true)
            self.tabBarController?.tabBar.items?.forEach() { $0.isEnabled = true }
            if didUserTapOnHighlightedFrame {

                let imageData = self.getImageData(by: self.selectedCellPath)

                let imageDetailViewController = self.getImageDetailViewController(with: imageData)

                imageDetailViewController.isDoneButtonHidden = false

                self.present(imageDetailViewController, animated: true)
            }
        })


    }
}


// MARK: - ImageTableViewCellDelegate:

extension ImagesViewController: ImageTableViewCellDelegate {
    
    private func showAnimatingShadowFor(frame: CGRect) {
        
        let tapCellFrameInShadowView = tableView.convert(frame, to: shadowView)
        let shadowAnimationRect = getShadowAnimationRect(for: tappedLocation, in: tapCellFrameInShadowView)
        
        self.tabBarController?.tabBar.items?.forEach() { $0.isEnabled = false }
        
        shadowView.isHidden = false
        shadowView.showShadow(for: shadowAnimationRect, animated: true)
    }
    
    func cellTapped(by sender: UITapGestureRecognizer) {
        let tapLocationInTableView = sender.location(in: tableView)
        
        guard let indexPath = tableView.indexPathForRow(at: tapLocationInTableView) else { return }
        
        selectedCellPath = indexPath
        
        let tapCellFrameInTableView = tableView.rectForRow(at: indexPath)
        let cellsRect = getCellsRect(of: tableView)
        
        tappedLocation = sender.location(in: self.view)
        let isTappedOnCoveredCell = !cellsRect.contains(tapCellFrameInTableView)
        if isTappedOnCoveredCell {
            tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.none, animated: true)
            isScrollForced = true
        } else {
            showAnimatingShadowFor(frame:tapCellFrameInTableView)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == tableView,
            isScrollForced {
            
            isScrollForced = false
            let tapCellFrameInTableView  = tableView.rectForRow(at: selectedCellPath)
            
            showAnimatingShadowFor(frame:tapCellFrameInTableView)
        }
    }
    
    private func getCellsRect(of tableView: UITableView) -> CGRect {
        let headerHeight = ImagesViewControllerSettings.kTVHeightForHeader
        let cellsOrigin  = CGPoint(x: tableView.bounds.origin.x, y: tableView.bounds.origin.y + headerHeight)
        let cellsSize    = CGSize (width: tableView.bounds.width, height: tableView.bounds.height - headerHeight)
        
        return CGRect(origin: cellsOrigin, size: cellsSize)
    }
    
    private func getShadowAnimationRect(for point: CGPoint, in container: CGRect) -> CGRect {
        let tapRadius = ImagesViewControllerSettings.kTVTappedRadius
        
        let tapTopPointX = point.x - tapRadius
        let tapTopPointY = point.y - tapRadius
        let tapDiameter  = tapRadius * CGFloat(2)
        
        let tapSize  = CGSize(width: tapDiameter, height: tapDiameter)
        let tapPoint = CGPoint(x: tapTopPointX, y: tapTopPointY)
        
        var tapRect = CGRect(origin: tapPoint, size: tapSize)
        
        let isShadowRectOutOfCell = !container.contains(tapRect)
        
        if isShadowRectOutOfCell {
            let bottomPointX = point.x + tapRadius
            let bottomPointY = point.y + tapRadius
            let cellBottomPointX = container.origin.x + container.width
            let cellBottomPointY = container.origin.y + container.height
            
            if container.origin.x >= tapTopPointX {
                tapRect.origin.x = container.origin.x
            } else if cellBottomPointX <= bottomPointX {
                tapRect.origin.x = cellBottomPointX - tapDiameter
            }
            
            if container.origin.y >= tapTopPointY {
                tapRect.origin.y = container.origin.y
            } else if cellBottomPointY <= bottomPointY {
                tapRect.origin.y = cellBottomPointY - tapDiameter
            }
            
        }
        return tapRect
    }
}


// MARK: - Table view extension

extension ImagesViewController: UITableViewDataSource, UITableViewDelegate  {

    // MARK: Table view data source:

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let tvCellIdentifier = ImagesViewControllerSettings.kTVCellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: tvCellIdentifier, for: indexPath) as! ImageTableViewCell

        let imageData = getImageData(by: indexPath)

        let title = imageData.title.isEmpty ? ImagesViewControllerSettings.kTVCellDefaultTitle : imageData.title
        let url = imageData.urlSmall240

        var cellImage: UIImage?

        if let image = ImageLoadHelper.getImageFromCache(by: url) {
            cellImage = image
        } else {
            ImageLoadHelper.loadImage(by: url, completion: { image in
                self.configureTableViewCell(by: indexPath, image: image, title: title)
            })
        }
        cell.delegate = self

        cell.configure(with: cellImage, title) // cell always should be init  cell.imageView.image = nil

        return cell
    }

    // Configure reusable cells
    private func configureTableViewCell(by indexPath: IndexPath, image: UIImage?, title: String) {

        if let cell = tableView.cellForRow(at: indexPath) as? ImageTableViewCell {
            cell.configure(with: image, title)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return imageTags?.count ?? 0
    }


    // MARK: Table view delegate:

    // Configurate header section view
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerNibId = ImagesViewControllerSettings.kTVHeaderIdentifier
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerNibId) as! CustomSectionHeaderView

        headerView.setTitle(imageTags![section].uppercased())

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ImagesViewControllerSettings.kTVHeightForHeader
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let sectionTag = imageTags![section]

        return imageDataDictionary?[sectionTag]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ImagesViewControllerSettings.kTVHeightForRow
    }

}


// MARK: - Collection view extension

extension ImagesViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: UICollectionViewDelegate:

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
        } else {
            if scrollView.contentOffset.y < 0 {
                lastTableViewContentOffset = 0
            } else {
                lastTableViewContentOffset = scrollView.contentOffset.y
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

    // MARK: UICollectionViewDataSource:
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if removeImagesActionStarts {
            let cellToDelete = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
            cellToDelete.stopAnimateCellRemoving()
            // remove the image and refresh the collection view
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseIn, animations: {
                cellToDelete.alpha = 0.5
            }) { [weak self] _ in
                collectionView.performBatchUpdates({
                    collectionView.deleteItems(at: [indexPath])
                    self?.collectionViewThrownedImageURLs?.remove(at: indexPath.row)
                })
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewThrownedImageURLs?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let identifier = ImagesViewControllerSettings.kCVCellIdentifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ImageCollectionViewCell

        var cellImage: UIImage?

        if let url = collectionViewThrownedImageURLs?[indexPath.row] {
            if let image = ImageLoadHelper.getImageFromCache(by: url) {
                cellImage = image
            } else {
                ImageLoadHelper.loadImage(by: url) { image in
                    self.configureCollectionViewCell(by: indexPath, with: image)
                }
            }
        }

        removeImagesActionStarts ? cell.startAnimateCellRemoving() : cell.stopAnimateCellRemoving()

        cell.configure(with: cellImage)

        return cell
    }

    private func configureCollectionViewCell(by indexPath: IndexPath, with image: UIImage?) {

        if let view = self.collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            view.configure(with: image)
            self.collectionView.reloadData()
        }
    }

}

// MARK: - Drag&Drop extension
extension ImagesViewController: UIDropInteractionDelegate, UICollectionViewDropDelegate, UITableViewDragDelegate {

    // MARK: UICollectionViewDropDelegate:

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {

        var indexPathes = [IndexPath]()
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
        
        removingLongPressGesture.state = .ended
        
        stopAnimateVisibleCellsIfAnimating(for: collectionView)

        coordinator.session.loadObjects(ofClass: NSString.self) { (nsstrings) in

            DispatchQueue.main.async {

                var array: [URL] = self.collectionViewThrownedImageURLs ?? []

                nsstrings.enumerated().forEach({ (index, nsstring) in

                    let imageData = self.getImageData(from: nsstring)
                    let url = imageData.urlSmall320
                    let isUrlUnique = !array.contains(url)

                    if isUrlUnique {
                        array.insert(url, at: destinationIndexPath.row)

                        let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                        indexPathes.append(indexPath)
                    }
                })

                collectionView.performBatchUpdates({
                    self.collectionViewThrownedImageURLs = array
                    collectionView.insertItems(at: indexPathes)
                })
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {

        return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
    }

    // Parsing NSItemProviderReading
    private func getImageData(from dragItem: NSItemProviderReading) -> ImageData {
        return ImageData.instance(from: getData(from: dragItem))
    }

    private func getData(from item: NSItemProviderReading) -> Data {
        return Data((item as! String).utf8)
    }


    // MARK: Drop interaction delegate:

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }


    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSString.self) { items in
            self.setTabBar(with: items)
        }
    }

    private func setTabBar(with droppedItems: [NSItemProviderReading]) {

        guard let tabBarViewControllers = self.tabBarController?.viewControllers else { return }

        setupFavoriteImagesViewController(with: droppedItems, in: tabBarViewControllers)

        /*
         Freez
        addDetailImagesViewControllers(with: getImageData(from: droppedItems.first!).urlLarge1024, to: tabBarViewControllers)
        */

    }

    /// Functionality for adding favorite images
    private func setupFavoriteImagesViewController(with droppedItems: [NSItemProviderReading], in tabBarViewControllers: [UIViewController]) {
        var dataArray = [Data]()
        for droppedItem in droppedItems {
             dataArray.append(getData(from: droppedItem))
        }

        for data in dataArray {
            if FavoriteManager.isOverlapTheLimit {
                let alert = UIAlertController(title: "Favorite Image Alert", message: "Favorite images limit(\(FavoriteManager.maxImagesCount)) is overlaped. Please click 'OK' and delete some.", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in self.goToFavoriteImages() } ))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

                self.present(alert, animated: true)
                break
            } else {
                FavoriteManager.addFavoriteImage(ImageData.instance(from: data))
            }
        }
    }



    /// Functionality to add not more than three detail image vcs more to tab bar
   private func addDetailImagesViewControllers(with imageData: ImageData, to tabBarViewControllers: [UIViewController]) {
        let isTabVCsLessThanMax = tabBarViewControllers.count <= ImagesViewControllerSettings.kTabBarVScMaxCount

        if isTabVCsLessThanMax {

            let imageDetailViewController = getImageDetailViewController(with: imageData)
            imageDetailViewController.tabBarItem.title = "Item №\(self.tabBarController!.viewControllers!.endIndex)"

            tabBarController?.viewControllers?.append(imageDetailViewController)

        } else {
            insertDetailImageViewController(with: imageData, toTheEndOf: tabBarViewControllers)
        }
    }

    private func insertDetailImageViewController(with imageData: ImageData, toTheEndOf tabBarViewControllers: [UIViewController]) {

        for (viewControllerIndex, viewController) in tabBarViewControllers.enumerated() {

            guard let imageDetailViewController = viewController as? ImageDetailViewController else { continue }

            let isTabBarNextVCExist = viewControllerIndex < tabBarViewControllers.count - 1

            if isTabBarNextVCExist {
                let nextVC = tabBarViewControllers[viewControllerIndex + 1] as! ImageDetailViewController
                imageDetailViewController.imageData = nextVC.imageData
            } else {
                imageDetailViewController.imageData = imageData
            }
        }
    }

    private func getImageDetailViewController(with imageData: ImageData) -> ImageDetailViewController {

        let storyboard = UIStoryboard(name: "DetailImage", bundle: Bundle.main)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "ImageDetailViewController") as! ImageDetailViewController

        detailVC.imageData = imageData

        return detailVC
    }


    // MARK: Drag interaction delegate:


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
        let dragImageTag  = imageTags![indexPath.section]
        let dragImageData = imageDataDictionary?[dragImageTag]?[indexPath.row]

        guard let data = try? JSONEncoder().encode(dragImageData) as NSData else { return [] }

        let itemProvider = NSItemProvider(item: data, typeIdentifier: kUTTypePlainText as String)
        let dragItem = UIDragItem(itemProvider: itemProvider)

        return [dragItem]
    }
}
