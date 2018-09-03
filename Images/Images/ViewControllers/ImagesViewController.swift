//
//  ViewController.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

// MARK: delegate for service

protocol ImageServiceDelegate: class {
    func onDataLoaded(service: ImageService, data: [Images])
}

class ImagesViewController: UIViewController, ImageServiceDelegate {
   
    // MARK: Outlets 
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let imageTags = ["jupiter", "hockey", "rock"]
    private var service: ImageService!
    private var dataSource: [Images]?

    override func viewDidLoad() {
        super.viewDidLoad()
        service = ImageService(tags: imageTags)
        service.delegate = self
        service.reload()
    }
    
    // MARK: setting datasource from delegate method
    
    func onDataLoaded(service: ImageService, data: [Images]) {
        self.dataSource = data
        self.tableView.reloadData()
        self.collectionView.reloadData()
    }
    
}

// MARK: Collection view delegate and data source

extension ImagesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.first?.data?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = ImagesViewControllerSettings.kCellIdentifierForCollectionView
        let view = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ImageCollectionViewCell
        
        let section = indexPath.section
        let row = indexPath.row
        let url = dataSource![section].data![row].url
        
        if url == self.dataSource?[section].data?[row].url {
            if let image = ImageLoadHelper.cache[url] {
                view?.configure(with: image)
            } else {
                ImageLoadHelper.uploadImage(by: url, completion: { image in                    
                    self.setView(by: indexPath, with: image)
                })
            }
        }
        return view ?? UICollectionViewCell()
    }
    
    
    
    private func setView(by indexPath: IndexPath, with image: UIImage?) {
        if let view = self.collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            view.configure(with: image)
        }
    }
    
}

// MARK: Table view delegate and data source

extension ImagesViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Configurate header section view
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nibName = "CustomSectionHeaderView"
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as? CustomSectionHeaderView
        view?.titleLabel.text = dataSource?[section].tag
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ImagesViewControllerSettings.kHeightForHeader
    }
    
    // MARK: Configurate reusable cells
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?[section].data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = ImagesViewControllerSettings.kCellIdentifierForTableView
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ImageTableViewCell
        
        
        let section = indexPath.section
        let row = indexPath.row
        
        let url = dataSource?[section].data?[row].url
        let title = dataSource?[section].data?[row].title
        
        if let image = ImageLoadHelper.cache[url!] {
            cell.configure(with: image, title: title!)
        } else {
            ImageLoadHelper.uploadImage(by: url!, completion: { image in
                if let image = image {
                    DispatchQueue.main.async {
                        if url == self.dataSource?[section].data?[row].url {
                            cell.configure(with: image, title: title!)
                        }
                    }
                }
            })
        }
        
        return cell
    }
    
    private func setCell(by indexPath: IndexPath, with image: UIImage, title: String) {
        if let cell = tableView.cellForRow(at: indexPath) as? ImageTableViewCell {
            cell.configure(with: image, title: title)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ImagesViewControllerSettings.kHeightForRow
    }
    
}


