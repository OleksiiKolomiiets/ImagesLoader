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
        shadowView.isHidden = true
        
        if case true = isSuccess {
            let storyboard = UIStoryboard(name: "DetailImage", bundle: Bundle.main)
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "ImageDetailViewController") as? ImageDetailViewController {
                detailVC.imageData = self.dataSource![selectedCellPath.section].data![selectedCellPath.row]
                detailVC.doneButtonisHidden = false
                self.present(detailVC, animated: true)
            }
        }
    }
}
