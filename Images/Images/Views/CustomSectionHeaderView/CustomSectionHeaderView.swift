//
//  CustomSectionHeaderView.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/23/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class CustomSectionHeaderView: UITableViewHeaderFooterView {

    // MARK: - Outlet:
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - Function:
    public func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
}
