//
//  ImagesViewController+TableView.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 9/17/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

// ========================================
// MARK: - Table view data source extension
// ========================================

extension ImagesViewController: UITableViewDataSource {
    
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
        cell.configure(with: data) // cell alway should be init  cel.imageView.image = nil
        
        return cell
    }
    
    // Configurate reusable cells
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.count ?? 0
    }
    
    private func setTableViewCell(by indexPath: IndexPath, with data: CellViewModel) {
        if let cell = tableView.cellForRow(at: indexPath) as? ImageTableViewCell {
            cell.configure(with: data)
        }
    }
    
}

// =====================================
// MARK: - Table view delegate extension
// =====================================

extension ImagesViewController: UITableViewDelegate {
    
    // Configurate header section view
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?[section].data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ImagesViewControllerSettings.kHeightForRow
    }
    
    // Send selected data to ImageDetailViewController and present it
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "DetailImage", bundle: Bundle.main)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "ImageDetailViewController") as? ImageDetailViewController {
            detailVC.imageData = self.dataSource![indexPath.section].data![indexPath.row]
            self.present(detailVC, animated: true)
        }
    }
}
