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
    var imageURLs: [URL]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // MARK: - Functions:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViewFlowLayout.minimumLineSpacing = 0
        collectionView.dropDelegate = self
//        collectionView.addInteraction(UIDropInteraction(delegate: self))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureCollectionViewLayoutItemSize()
    }
    
    private func configureCollectionViewLayoutItemSize() {
        let inset: CGFloat = calculateSectionInset() // This inset calculation is some magic so the next and the previous cells will peek from the sides. Don't worry about it
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
        superViewController.proposeForDropLable.isHidden = true
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath
        {
            destinationIndexPath = indexPath
        }
        else
        {
            // Get last index path of collection view.
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        collectionView.performBatchUpdates({
            var indexPaths = [IndexPath]()
            
            for (index, item) in coordinator.items.enumerated()
            {
                //Destination index path for each item is calculated separately using the destinationIndexPath fetched from the coordinator
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                
                if self.imageURLs != nil {
                    self.imageURLs!.append(item.dragItem.localObject as! URL)
                    let insertIndex = destinationIndexPath.row
                    let lastIndex = self.imageURLs!.endIndex
                    for i in (insertIndex + 1 ..< lastIndex).reversed() {
                        self.imageURLs?.swapAt(i, i - 1)
                    }
                    
                } else {
                    self.imageURLs = [item.dragItem.localObject as! URL]
                }
                
                indexPaths.append(indexPath)
                
            }
            collectionView.insertItems(at: indexPaths)
        })
        
//        session.loadObjects(ofClass: NSURL.self) { nsurl in
//            if var imageURLs = self.imagesCollectionViewController.imageURLs {
//                imageURLs.append(nsurl.first as! URL)
//            } else {
//                self.imagesCollectionViewController.imageURLs = [nsurl.first as! URL]
//            }
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
    {
        if session.localDragSession != nil
        {
            if collectionView.hasActiveDrag
            {
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
            else
            {
                return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
            }
        }
        else
        {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
    }
    
}

class URLListNode: Equatable {
    
    var value: URL
    var next: URLListNode?
    weak var previous: URLListNode?
    
    public init(value: URL) {
        self.value = value
    }    
    
    static func == (lhs: URLListNode, rhs: URLListNode) -> Bool {
        return lhs.value == rhs.value
    }
    
}

public class LinkedListNode<T> {
    var value: T
    var next: LinkedListNode?
    weak var previous: LinkedListNode?
    
    public init(value: T) {
        self.value = value
    }
}
