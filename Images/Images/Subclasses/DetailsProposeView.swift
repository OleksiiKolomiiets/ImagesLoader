//
//  DetailsProposeView.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 11/26/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class DetailsProposeView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageButtonOutlet: UIButton!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBAction func imageButtonTapped(_ sender: UIButton) {
        print(11)
    }
    @IBAction func geoButtonTapped(_ sender: UIButton) {
        print(22)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("DetailsProposeView", owner: self, options: nil)
        contentView.fixInView(self)
        let cornerRadii = UIBezierPath(ovalIn: self.frame)
//        cornerRadii.append(UIBezierPath(rect: self.frame))
//        cornerRadii.add
        self.clipsToBounds = true
        let maskLayer = CAShapeLayer()
        maskLayer.path = cornerRadii.cgPath
        maskLayer.fillRule = .evenOdd
        contentView.layer.mask = maskLayer
    }
}

extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true        
    }
}
