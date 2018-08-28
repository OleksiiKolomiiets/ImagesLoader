//
//  CustomSectionHeaderView.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/23/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class CustomSectionHeaderView: UIView {

    var colorView: UIView!
    var bgColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
    var titleLabel = UILabel()
    var headerSeparatorView: UIView!
    var footerSeparatorView: UIView!
    
    init(frame:CGRect, title: String) {
        self.titleLabel.text = title.uppercased()
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView() {
        self.backgroundColor = bgColor
        
        colorView = UIView()
        colorView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(colorView)
        let constraints:[NSLayoutConstraint] = [
            colorView.topAnchor.constraint(equalTo: self.bottomAnchor),
            colorView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            colorView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
       
        colorView.backgroundColor = bgColor
        
        let screenSize = UIScreen.main.bounds
        var separatorHeight = CGFloat(16.0)
        
        let headerSeparator = UIView.init(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: separatorHeight))
        headerSeparator.backgroundColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
        self.addSubview(headerSeparator)
        let headerSeparatorConstraints:[NSLayoutConstraint] = [
            headerSeparator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            headerSeparator.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 0),
        ]
        NSLayoutConstraint.activate(headerSeparatorConstraints)
        
        separatorHeight = CGFloat(2.0)
        let additionalSeparator = UIView.init(frame: CGRect(x: 0, y: self.frame.size.height-separatorHeight+30, width: screenSize.width, height: separatorHeight))
        additionalSeparator.backgroundColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
        self.addSubview(additionalSeparator)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        let titlesConstraints:[NSLayoutConstraint] = [
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: headerSeparator.bottomAnchor, constant: 8),
            ]
        NSLayoutConstraint.activate(titlesConstraints)
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textAlignment = .center
    }

}
