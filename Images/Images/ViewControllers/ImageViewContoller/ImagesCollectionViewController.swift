//
//  ImagesCollectionViewController.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 9/21/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImagesCollectionViewController: UICollectionViewController {
    
    // MARK: - Outlet:
    @IBOutlet private weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    // MARK: - Properties:
    var superViewController: ImagesViewController!
    private var indexOfCellBeforeDragging = 0
    var longPressGesture: UILongPressGestureRecognizer!
    var longPressedEnabled = false 
    var imageURLs: [URL]? {
        didSet {
            if let imageURLs = imageURLs {
                superViewController.proposeForDropLable.isHidden = !imageURLs.isEmpty                
                collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Functions:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViewFlowLayout.minimumLineSpacing = 0
        collectionView.dropDelegate = self
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func longTap(_ gesture: UIGestureRecognizer){
        switch gesture.state {
        case .began:
            if longPressedEnabled {
                gesture.state = .cancelled
                longPressedEnabled = false
            }
            self.collectionView.reloadData()
        case .changed:
            if longPressedEnabled {
                gesture.state = .cancelled
                longPressedEnabled = false
            }
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
            longPressedEnabled = true
            self.collectionView.reloadData()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    @IBAction func removeButtonTouch(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: collectionView)
        let hitIndex = collectionView.indexPathForItem(at: hitPoint)
        
        //remove the image and refresh the collection view
        imageURLs?.remove(at: (hitIndex?.row)!)
        longPressedEnabled = false
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureCollectionViewLayoutItemSize()
    }
    
    private func configureCollectionViewLayoutItemSize() {
        // This inset calculation is some magic so the next and the previous cells will peek from the sides
        let inset: CGFloat = calculateSectionInset()
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: inset)
        
        collectionViewFlowLayout.itemSize = CGSize(width: collectionViewLayout.collectionView!.frame.size.width - inset * 2,
                                                   height: collectionViewLayout.collectionView!.frame.size.height)
    }
    
    private func calculateSectionInset() -> CGFloat {
        let deviceIsIpad = UIDevice.current.userInterfaceIdiom == .pad
        let deviceOrientationIsLandscape = UIDevice.current.orientation.isLandscape
        let cellBodyViewIsExpended = deviceIsIpad || deviceOrientationIsLandscape
        let cellBodyWidth: CGFloat = self.collectionView.frame.size.width + (cellBodyViewIsExpended ? self.collectionView.frame.size.width * 0.5 : 0)
        let buttonWidth: CGFloat = self.collectionView.frame.size.width * 0.3
        
        let inset = (collectionViewLayout.collectionView!.frame.width - cellBodyWidth + buttonWidth) / 4
        return inset
    }
    
    // MARK: UICollectionViewDataSource:
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = ImagesViewControllerSettings.kCellIdentifierForCollectionView
        guard let view = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        var cellImage: UIImage?
        
        if let url = imageURLs?[indexPath.row] {
            if let image = ImageLoadHelper.getImageFromCache(by: url) {
                cellImage = image
            } else {
                ImageLoadHelper.getImage(by: url) { image in
                    self.setCellForCollectionView(by: indexPath, with: image)
                }
            }
        }
        
        if longPressedEnabled {
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
    
    // MARK: UICollectionViewDelegate:
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        guard let count = imageURLs?.count else { return }
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
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                scrollView.layoutIfNeeded()
            }, completion: nil)
            
        } else {
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }
    
    private func indexOfMajorCell() -> Int {
        guard let count = imageURLs?.count else { return 0 }
        let itemWidth = collectionViewFlowLayout.itemSize.width
        let proportionalOffset = collectionViewFlowLayout.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let safeIndex = max(0, min(count - 1, index))
        return safeIndex
    }
}


extension ImagesCollectionViewController: UICollectionViewDropDelegate {   
    
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
        
        collectionView.performBatchUpdates({
            var indexPaths = [IndexPath]()
            
            for (index, item) in coordinator.items.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                
                item.dragItem.itemProvider.loadObject(ofClass: ImageViewEntity.self, completionHandler: { (imageData, error) in
                    if let imageData = imageData as? ImageViewEntity {
                        let url = ImageService.getUrlForPhoto(sizeType: .small320, using: imageData)
                        
                        if let imageURLs = self.imageURLs {
                            if !imageURLs.contains(url) {
                                DispatchQueue.main.async {
                                    self.imageURLs!.append(url)
                                    let insertIndex = destinationIndexPath.row
                                    let lastIndex = self.imageURLs!.endIndex
                                    for i in (insertIndex + 1 ..< lastIndex).reversed() {
                                        self.imageURLs?.swapAt(i, i - 1)
                                    }
                                }
                                indexPaths.append(indexPath)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.imageURLs = [url]
                            }
                            indexPaths.append(indexPath)
                        }
                    }
                })
            }
            
            collectionView.insertItems(at: indexPaths)
        })
//
//        collectionView.performBatchUpdates({
//            var indexPaths = [IndexPath]()
//
//            for (index, item) in coordinator.items.enumerated() {
//                // Destination index path for each item is calculated separately using the destinationIndexPath fetched from the coordinator
//                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
//
//                item.dragItem.itemProvider.loadObject(ofClass: ImageViewEntity.self, completionHandler: { (imageData, error) in
//                    if let imageData = imageData as? ImageViewEntity {
//
//                        let url = ImageService.getUrlForPhoto(sizeType: .small320, using: imageData)
//
//                        DispatchQueue.main.async {
//                            if let imageURLs = self.imageURLs {
//                                if !imageURLs.contains(url) {
//                                    self.imageURLs!.append(url)
//
//                                    let insertIndex = destinationIndexPath.row
//                                    let lastIndex = self.imageURLs!.endIndex
//                                    for i in (insertIndex + 1 ..< lastIndex).reversed() {
//                                        self.imageURLs?.swapAt(i, i - 1)
//                                    }
//                                    indexPaths.append(indexPath)
//                                }
//                            } else {
//                                self.imageURLs = [url]
//                                indexPaths.append(indexPath)
//                            }
//                        }
//
//                    }
//                })
//            }
//            collectionView.insertItems(at: indexPaths)
//        })
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
