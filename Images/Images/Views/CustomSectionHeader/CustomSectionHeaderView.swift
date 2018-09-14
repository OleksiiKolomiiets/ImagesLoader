//
//  CustomSectionHeaderView.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/23/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class CustomSectionHeaderView: UIView {

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - Outlets
    func setTitle(_ title: String?) {
        titleLabel.text = title?.uppercased()
    }
    
}
