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

extension MutableCollection {
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

class ImagesViewController: UIViewController, ImageServiceDelegate {
   
    @IBAction func reload(_ sender: UIButton) {
        service.reload()
    }
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let imageTags = Array(ImagesViewControllerSettings.kTags.shuffled().prefix(3))
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
    
    let helper = ImageLoadHelper()
}

// MARK: Collection view delegate and data source

extension ImagesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.first?.data?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = ImagesViewControllerSettings.kCellIdentifierForCollectionView
        let view = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ImageCollectionViewCell
        
        let url = dataSource?.first?.data![indexPath.row].url
        view?.configure(with: nil)
        
        if let image = ImageLoadHelper.getImageFromCache(by: url!) {
            view?.configure(with: image)
        } else {
            ImageLoadHelper.getImage(by: url!) { image in
                if url == self.dataSource?.first?.data?[indexPath.row].url {
                    self.setCellForCollectionView(by: indexPath, with: image)
                }
            }
        }
        
        return view ?? UICollectionViewCell()
    }
    
    private func setCellForCollectionView(by indexPath: IndexPath, with image: UIImage?) {
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
        view?.set(with: dataSource?[section].tag)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ImageTableViewCell
        
        let section = indexPath.section
        let row = indexPath.row
        
        let url = dataSource?[section].data?[row].url
        let title = dataSource?[section].data?[row].title
        
        let data = CellViewModel(image: nil, title: title!)
        cell?.configure(with: data)
        
        if let image = ImageLoadHelper.getImageFromCache(by: url!) {
            let data = CellViewModel(image: image, title: title!)
            cell?.configure(with: data)
        } else {
            ImageLoadHelper.getImage(by: url!, completion: { image in
                if url == self.dataSource?[section].data?[row].url {
                    let data = CellViewModel(image: image, title: title!)
                    self.setTableViewCell(by: indexPath, with: data)
                }
            })
        }
        // cell alway should be init  cel.imageView.image = nil
        
        return cell!
    }
    
    private func setTableViewCell(by indexPath: IndexPath, with data: CellViewModel) {
        if let cell = tableView.cellForRow(at: indexPath) as? ImageTableViewCell {
            cell.configure(with: data)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ImagesViewControllerSettings.kHeightForRow
    }
    
}


