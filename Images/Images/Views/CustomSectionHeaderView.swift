//
//  CustomSectionHeaderView.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/23/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class CustomSectionHeaderView: UIView {

    // MARK: - Outlet:
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - Function:
    static func instantiate(with controller: UIViewController) -> CustomSectionHeaderView {
        let bundle = Bundle(for: type(of: controller))
        let nibName = "CustomSectionHeaderView"
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! CustomSectionHeaderView
        return view
    }
    
    func setTitle(_ title: String?) {
        titleLabel.text = title?.uppercased()
    }
    
}
