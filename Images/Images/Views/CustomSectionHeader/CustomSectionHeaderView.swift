//
//  CustomSectionHeaderView.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/23/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class CustomSectionHeaderView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(with title: String) {
        titleLabel.text = title.uppercased()
    }
}
