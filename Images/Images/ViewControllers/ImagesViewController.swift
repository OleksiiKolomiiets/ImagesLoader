//
//  ViewController.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ImagesViewController: UIViewController, ImageServiceDelegate {
   
    // MARK: Outlets 
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let imageTags = ["jupiter"] //, "hockey", "rock"]
    var service: ImageService?
    var dataSource: [Images]?

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = [Images]()
        service = ImageService(tags: imageTags)
        service?.delegate = self
        service?.reload()
    }
    
    // MARK: setting datasource from delegate method
    
    func onDataLoaded(service: ImageService, data: Images) {
        self.dataSource?.append(data)
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
        let identifier = ImagesViewControllerSettings.cCellIdentifierForCollectionView
        let view = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        if let imageView = view as? ImageCollectionViewCell {
            imageView.spinner.startAnimating()
            let section = indexPath.section
            let row = indexPath.row
            guard let url = dataSource?[section].data?[row].url else {
                imageView.configure(with: #imageLiteral(resourceName: "Placeholder"))
                return imageView
            }
            ImageLoadHelper.uploadImage(by: url, completion: { (image, error) in
                if let error = error {
                    self.showAlert(title: "Upload error", message: error.localizedDescription)
                } else if let image = image {
                    DispatchQueue.main.async {
                        if url == self.dataSource?[section].data?[row].url {
                            imageView.configure(with: image)
                        }
                    }
                }
            })
            return imageView
        }
        return view
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
        view?.configure(with: (dataSource?[section].tag)!)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ImagesViewControllerSettings.cHeightForHeader
    }
    
    // MARK: Configurate reusable cells
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?[section].data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = ImagesViewControllerSettings.cCellIdentifierForTableView
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        if let imageCell = cell as? ImageTableViewCell {
            imageCell.spinner.startAnimating()
            
            let section = indexPath.section
            let row = indexPath.row
            
            guard let url = dataSource?[section].data?[row].url,
            let title = dataSource?[section].data?[row].title
            else {
                imageCell.pictureImageView.image = nil
                return imageCell
            }
            DispatchQueue.global().async {
                ImageLoadHelper.uploadImage(by: url, completion: { (image, error) in
                    if let error = error {
                        self.showAlert(title: "Upload error", message: error.localizedDescription)
                    } else if let image = image {
                        DispatchQueue.main.async {
                            if url == self.dataSource?[section].data?[row].url {
                                imageCell.configure(with: image, title: title)
                            }
                        }
                    }
                })
            }
            return imageCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ImagesViewControllerSettings.cHeightForRow
    }
    
}


