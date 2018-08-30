//
//  ViewController.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImagesViewController: UIViewController {
    
    // MARK: Outlets 
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let imageTags = ["nasa"] //, "mars", "saturn"]
    var service: ImageService?
    var data: [ImageViewEntity]? {
        didSet {
            self.tableView.reloadData()
            self.collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        data = [ImageViewEntity]()
        service = ImageService(tags: imageTags)
        service?.reload()
//        ImageService.getImages(imagesQuantity, by: imageTags) { (data, error) in
//            if let data = data {
//                self.data = data
//            }
//        }
    }
    
    private func filterData(by title: String) -> [ImageViewEntity]? {
        if let data = data {
            return data.filter() { $0.title == title }
        }
        return nil
    }
}

// MARK: Collection view delegate and data source

extension ImagesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let firstTagImages = data {
            return firstTagImages.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = ImagesViewControllerSettings.cCellIdentifierForCollectionView
        let view = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        if let imageView = view as? ImageCollectionViewCell,
            let source = self.filterData(by: imageTags.first!) {
            imageView.configure(with: source[indexPath.row])
            return imageView
        }
        return view
    }
    
}

// MARK: Table view delegate and data source

extension ImagesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let sectionType = imageTags[section]
//        let count = filterData(by: sectionType)?.count
        return service?.imageArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return imageTags[section].uppercased()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
               
        let bundle = Bundle(for: type(of: self))
        let nibName = "CustomSectionHeaderView"
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        let view = nib.instantiate(withOwner: self, options: nil).first as? CustomSectionHeaderView
        view?.configure(with: imageTags[section])
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ImagesViewControllerSettings.cHeightForHeader
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return imageTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = ImagesViewControllerSettings.cCellIdentifierForTableView
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let sectionType = imageTags[indexPath.section]
        let dataByTag = filterData(by: sectionType)
        cell.textLabel?.text = service?.imageArray![indexPath.row].title
//        if let imageCell = cell as? ImageTableViewCell {
//            let source: ImageViewEntity? = dataByTag?[indexPath.row]
//            imageCell.configure(with: source)
//            return imageCell
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ImagesViewControllerSettings.cHeightForRow
    }
    
}


