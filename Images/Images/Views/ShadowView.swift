//
//  ShadowView.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 9/27/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ShadowView: UIView {

    
    weak var delegate: ImagesViewController?
    var highlightedArea: (centr:CGPoint, radius: CGFloat)? {
        didSet {
            setupView()
        }
    }
    
    let shadowColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
    let shadowPath = UIBezierPath()
    let shadowLayer = CAShapeLayer()
    
    
    // #1
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let touchGesture = UITapGestureRecognizer(target: self, action: #selector(viewPressed))
        touchGesture.numberOfTapsRequired = 1
        isUserInteractionEnabled = true
        addGestureRecognizer(touchGesture)
        //        setupView()
    }
    
    @objc func viewPressed() {
        
        shadowPath.removeAllPoints()
        isHidden = true
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
        guard let highlightedArea = highlightedArea else {
            print("highlightedArea doesn't exist.")
            return
        }
        
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
