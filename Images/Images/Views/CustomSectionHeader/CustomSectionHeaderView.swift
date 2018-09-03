//
//  CustomSectionHeaderView.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/23/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class CustomSectionHeaderView: UIView {

    @IBOutlet private weak var titleLabel: UILabel!
    
    func set(with title: String?) {
        if let title = title {
            titleLabel.text = title.uppercased()
        }
    }
    
}
