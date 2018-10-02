//
//  ImageVC+ShadowView.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 9/27/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

protocol ShadowViewDelegate: class {
    func tapSubmit(isSuccess: Bool)
}

// ===========================
// MARK: - ShadowViewDelegate:
// ===========================

extension ImagesViewController: ShadowViewDelegate {
    func tapSubmit(isSuccess: Bool) {
        shadowView.isHidden.toggle()
        
        if case true = isSuccess {
            let storyboard = UIStoryboard(name: "DetailImage", bundle: Bundle.main)
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "ImageDetailViewController") as? ImageDetailViewController,
                let dataSource = self.dataSource?[selectedCellPath.section], let data = dataSource.data?[selectedCellPath.row] {
                detailVC.imageData = data
                detailVC.doneButtonisHidden = false
                self.present(detailVC, animated: true)
            }
        }
    }
}
