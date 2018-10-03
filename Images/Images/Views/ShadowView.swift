//
//  ShadowView.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 9/27/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class ShadowView: UIView, CAAnimationDelegate {
    
    // MARK: - Variables:
    weak var delegate: ShadowViewDelegate!
    private let shadowColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
    private let shadowPath = UIBezierPath()
    private let shadowLayer = CAShapeLayer()
    private let maskLayerAnimation = CABasicAnimation(keyPath: "path")
    private var isOpenShadow = false
    private var touchGesture: UITapGestureRecognizer!
    private var startingPath = UIBezierPath()
    private var finishingPath = UIBezierPath()
    private var highlightedArea: CircleArea!
    private var tappedPoint: CGPoint!
    
    // MARK: - Functions:
    private func addTapGestureRecognizer(for view: UIView) {
        // Adding gesture recognizer for dealing with view taps
        touchGesture = UITapGestureRecognizer(target: view, action: #selector(viewPressed(_:)))
        touchGesture.numberOfTapsRequired = 1
        addGestureRecognizer(touchGesture)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addTapGestureRecognizer(for: self)
    }
    
    @objc func viewPressed(_ gestureRecognizer: UITapGestureRecognizer) {
        shadowPath.removeAllPoints()
        startingPath.removeAllPoints()
        finishingPath.removeAllPoints()
        shadowLayer.removeAllAnimations()
        shadowLayer.removeFromSuperlayer()
        
        let highlightedAreaCirclePath = UIBezierPath(arcCenter: highlightedArea.centr,
                                                     radius: highlightedArea.radius,
                                                     startAngle: CGFloat(0),
                                                     endAngle:CGFloat(Double.pi * 2),
                                                     clockwise: true)
        // Sending centre of tapped area to vc through delegate method
        delegate.tapSubmit(isSuccess: highlightedAreaCirclePath.contains(gestureRecognizer.location(in: self))) {
            
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        touchGesture.isEnabled = true
        if !isOpenShadow {
            self.isHidden.toggle()
        }
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        touchGesture.isEnabled = false
    }
    
    /// Showing shadow for selected area
    func showShadow(for area: CircleArea, animated: Bool) {
        isOpenShadow = true
        highlightedArea = area
        
         // Setting pathes by area
        let startingArea = CircleArea.init(centr: area.centr, radius: longestDistanceToTheCorner)
        setStartingPath(by: startingArea)
        setFinishingPath(by: area)
        
        // Setting animation layer
        setUp(layer: shadowLayer)
        
        // Adding animation
        if animated {
            setUpAnimation(from: startingPath.cgPath, to: finishingPath.cgPath)
            shadowLayer.add(maskLayerAnimation, forKey: "path")
        }
    }
    
    func dismissShadow(animated: Bool) {
        isOpenShadow = false
        
         // Setting pathes by area
        let finishingArea = CircleArea.init(centr: highlightedArea.centr, radius: longestDistanceToTheCorner)
        setStartingPath(by: highlightedArea)
        setFinishingPath(by: finishingArea)
        
        // Setting animation layer
        setUp(layer: shadowLayer)
        
        // Adding animation
        if animated {
            setUpAnimation(from: startingPath.cgPath, to: finishingPath.cgPath)
            shadowLayer.add(maskLayerAnimation, forKey: "path")
        }
        
    }
    
    private func setStartingPath(by area: CircleArea) {
        let circle = getPath(by: area.centr, radius: area.radius)
        startingPath = getPath(by: area.centr, radius: longestDistanceToTheCorner)
        startingPath.append(circle)
        
    }
    
    private func setFinishingPath(by area: CircleArea) {
        let smallCircle = getPath(by: area.centr, radius: area.radius)
        finishingPath = getPath(by: area.centr, radius: longestDistanceToTheCorner)
        finishingPath.append(smallCircle)
    }
    
    
    private func setUpAnimation(from: CGPath, to: CGPath) {
        maskLayerAnimation.fromValue = from
        maskLayerAnimation.toValue = to
        maskLayerAnimation.delegate = self
        maskLayerAnimation.duration = isOpenShadow ? 0.7 : 0.3
        maskLayerAnimation.fillMode = .both
        maskLayerAnimation.isRemovedOnCompletion = true
    }
    
    private var longestDistanceToTheCorner: CGFloat {
        let firstCatet = max(highlightedArea.centr.y, frame.size.height - highlightedArea.centr.y)
        let secondCatet = max(highlightedArea.centr.x, frame.size.width - highlightedArea.centr.x)
        return sqrt(pow(firstCatet, 2.0) + pow(secondCatet, 2.0))
    }
    
    private func getPath(by centr: CGPoint, radius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: centr)
        path.addArc(withCenter: centr,
                    radius    : radius,
                    startAngle: 0,
                    endAngle  : 2.0 * CGFloat.pi,
                    clockwise : true)
        path.close()
        return path
    }
    
    private func setUp(layer shadowLayer: CAShapeLayer) {
        shadowLayer.path = finishingPath.cgPath
        shadowLayer.fillColor = shadowColor.cgColor
        shadowLayer.fillRule = .evenOdd
        shadowLayer.lineCap = .butt
        shadowLayer.lineDashPattern = nil
        shadowLayer.lineDashPhase = 0.0
        shadowLayer.lineJoin = .miter
        shadowLayer.lineWidth = 0.0
        shadowLayer.miterLimit = 10.0
        shadowLayer.strokeColor = shadowColor.cgColor
        layer.addSublayer(shadowLayer)
    }

}
