//
//  ShadowView.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 9/27/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    
    //===================
    // MARK: - Variables:
    //===================
    
    weak var delegate: ImagesViewController!
    private let shadowColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
    private let shadowPath = UIBezierPath()
    private let shadowLayer = CAShapeLayer()
    var highlightedArea: (centr:CGPoint, radius: CGFloat)! {
        didSet {
            setupView()
        }
    }
    
    //===================
    // MARK: - Functions:
    //===================
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let touchGesture = UITapGestureRecognizer(target: self, action: #selector(viewPressed(_:)))
        touchGesture.numberOfTapsRequired = 1
        isUserInteractionEnabled = true
        addGestureRecognizer(touchGesture)
    }
    
    @objc func viewPressed(_ gestureRecognizer: UITapGestureRecognizer) {
        shadowPath.removeAllPoints()
        let circlePath = UIBezierPath(arcCenter: highlightedArea.centr,
                                      radius: highlightedArea.radius,
                                      startAngle: CGFloat(0),
                                      endAngle:CGFloat(Double.pi * 2),
                                      clockwise: true)
        
        delegate.tapSubmit(isSuccess: circlePath.contains(gestureRecognizer.location(in: self)))
    }
    
    private func setupView() {
        setFullScreenPath()
        setArcPath()
        setUpShadowLayer()
        layer.addSublayer(shadowLayer)
        isHidden = false
    }
    
    private func setFullScreenPath() {
        let startX: CGFloat = 0
        let startY: CGFloat = 0
        
        let width = frame.size.width
        let height = frame.size.height
        
        shadowPath.move(to: CGPoint(x: startX, y: startY))
        
        shadowPath.addLine(to: CGPoint(x: width, y: startY))
        shadowPath.addLine(to: CGPoint(x: width, y: height))
        shadowPath.addLine(to: CGPoint(x: startX, y: height))
        shadowPath.addLine(to: CGPoint(x: startX, y: startY))
        
        shadowPath.close()
    }
    
    private func setArcPath() {        
        shadowPath.move(to: highlightedArea.centr)
        
        shadowPath.addArc(withCenter: highlightedArea.centr,
                          radius    : highlightedArea.radius,
                          startAngle: 0,
                          endAngle  : 2.0 * CGFloat.pi,
                          clockwise : true)
        
        shadowPath.close()
    }
    
    private func setUpShadowLayer() {
        shadowLayer.path = shadowPath.cgPath
        shadowLayer.fillColor = shadowColor.cgColor
        shadowLayer.fillRule = CAShapeLayerFillRule.evenOdd
        shadowLayer.lineCap = CAShapeLayerLineCap.butt
        shadowLayer.lineDashPattern = nil
        shadowLayer.lineDashPhase = 0.0
        shadowLayer.lineJoin = CAShapeLayerLineJoin.miter
        shadowLayer.lineWidth = 0.0
        shadowLayer.miterLimit = 10.0
        shadowLayer.strokeColor = shadowColor.cgColor
    }

}
