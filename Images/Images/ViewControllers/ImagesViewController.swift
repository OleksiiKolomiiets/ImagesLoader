//
//  ViewController.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImagesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let imageTags = ["nasa", "mars", "saturn"]
    
    var data: [String: [ImageViewEntity]]? {
        didSet {
            tableView.reloadData()
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        data = [String: [ImageViewEntity]]()
        imageTags.forEach() {
            let tag = $0
            ImageService.getImages(by: tag) { (data, error) in
                if let data = data {
                    self.data![tag] = data
                }
            }
        }
    }
}

extension ImagesViewController: UICollectionViewDelegate {
    
}

extension ImagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let firstTagImages = data?[imageTags.first!] {
            return firstTagImages.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let view = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCollectionView", for: indexPath)
        if let imageView = view as? ImageCollectionViewCell, let data = data, let source = data[imageTags.first!] {
            let data = ImageViewEntity(imageUrl: source[indexPath.row].imageUrl, title: "")
            imageView.configure(with: data)        
            return imageView
        }
        return view
    }
    
    
}

extension ImagesViewController: UITableViewDelegate {
    
}

extension ImagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = imageTags[section]
        return data?[sectionType]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return imageTags[section].uppercased()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = CustomSectionHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30), title: imageTags[section].uppercased())
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
        let sectionType = imageTags[indexPath.section]
        if let imageCell = cell as? ImageTableViewCell, let source = data?[sectionType]?[indexPath.row] {
            let data = ImageViewEntity(imageUrl: source.imageUrl, title: source.title)
            imageCell.configure(with: data)
            return imageCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 91
    }
    
}


