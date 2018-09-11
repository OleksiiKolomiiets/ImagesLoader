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
    func onDataLoaded(service: ImageService, data: [ImagesViewSource])
}

class ImagesViewController: UIViewController, ImageServiceDelegate {
   
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var service: ImageService!
    private var dataSource: [ImagesViewSource]?
    private var reloadingTimer: Timer?
    private var randomIndices = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        service = ImageService()
        service.delegate = self        
        service.imageTags = getRandomTags()
        service.reload()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // MARK: ending timer work when user go to anothe screen
        reloadingTimer?.invalidate()
        reloadingTimer = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // MARK: timer start to work
        startTimer()
    }
    
        
    // MARK: getting random tags
    
    private func getRandomTags() -> [String] {
        var result = [String]()
        
        let tags = ImagesViewControllerSettings.kTags
        let tagsCount = ImagesViewControllerSettings.kNumberOfTagsInOneLoad
        let allTagsCount = tags.count
        let randomIndices = getRandomIndices(number: tagsCount, allTagsCount)
        
        randomIndices.forEach() { result.append(tags[$0]) }        
        
        return result
    }
    
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
    
    // MARK: setting datasource from delegate method
    
    func onDataLoaded(service: ImageService, data: [ImagesViewSource]) {
        self.dataSource = data
        self.tableView.reloadData()
        self.collectionView.reloadData()
    }
    
    // MARK: start to count time for reload
    
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
    
    // MARK: reloading data source
    @objc private func onTimerTick() {
        service.imageTags = getRandomTags()
        service.reload()
    }
}

// MARK: Collection view delegate and data source

extension ImagesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.first?.data?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = ImagesViewControllerSettings.kCellIdentifierForCollectionView
        guard let view = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        var cellImage: UIImage?
        
        if let url = dataSource?.first?.data?[indexPath.row].url {
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
        view?.setTitle(dataSource?[section].tag)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ImageTableViewCell else {
            return UITableViewCell()
        }
        
        var cellImage: UIImage?
        let section = indexPath.section
        let row = indexPath.row
        let title = dataSource?[section].data?[row].title
        
        if let url = dataSource?[section].data?[row].url {
            if let image = ImageLoadHelper.getImageFromCache(by: url) {
                cellImage = image
            } else {
                ImageLoadHelper.getImage(by: url, completion: { image in
                    let data = CellViewModel(image: image, title: title!)
                    self.setTableViewCell(by: indexPath, with: data)
                })
            }
        }
        
        let data = CellViewModel(image: cellImage, title: title!)
        cell.configure(with: data)
        // cell alway should be init  cel.imageView.image = nil
        
        return cell
    }
    
    private func setTableViewCell(by indexPath: IndexPath, with data: CellViewModel) {
        if let cell = tableView.cellForRow(at: indexPath) as? ImageTableViewCell {
            cell.configure(with: data)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ImagesViewControllerSettings.kHeightForRow
    }
    
    // MARK: Send selected data to ImageDetailViewController and present it
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "ImageDetailViewController") as? ImageDetailViewController {            
            detailVC.imageData = self.dataSource![indexPath.section].data![indexPath.row]
            self.present(detailVC, animated: true)
        }
    }
}


