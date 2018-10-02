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
    var highlightedArea: CircleArea! {
        didSet {
            setupView(for: .open)
        }
    }
    
    // MARK: - Functions:
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Adding guesture recognizer for dealing with view taps
        let touchGesture = UITapGestureRecognizer(target: self, action: #selector(viewPressed(_:)))
        touchGesture.numberOfTapsRequired = 1
        isUserInteractionEnabled = true
        addGestureRecognizer(touchGesture)
    }
    
    @objc func viewPressed(_ gestureRecognizer: UITapGestureRecognizer) {
        shadowPath.removeAllPoints()
        let highlightedAreaCirclePath = UIBezierPath(arcCenter: highlightedArea.centr,
                                                     radius: highlightedArea.radius,
                                                     startAngle: CGFloat(0),
                                                     endAngle:CGFloat(Double.pi * 2),
                                                     clockwise: true)
        // Sending centre of tapped area to vc through delegate method
        delegate.tapSubmit(isSuccess: highlightedAreaCirclePath.contains(gestureRecognizer.location(in: self)))
    }
    
    private func setupView(for state: ShadowViewState) {
        // Creating starting path with big circle inside
        let startingPath = getPath(by: highlightedArea.centr, radius: longestDistanceToTheCorner)
        let bigCircle = getPath(by: highlightedArea.centr, radius: longestDistanceToTheCorner - 1)
        startingPath.append(bigCircle)
        
        // Creating ending path with small circle inside
        let finishingPath =  getPath(by: highlightedArea.centr, radius: longestDistanceToTheCorner)
        let smallCircle = getPath(by: highlightedArea.centr, radius: highlightedArea.radius)
        finishingPath.append(smallCircle)
        
        // Setting animation layer
        setUp(layer: shadowLayer)
        
        layer.addSublayer(shadowLayer)
        
        // Adding animation
        var layerAnimation = CABasicAnimation()
        
        shadowLayer.path = finishingPath.cgPath
        layerAnimation = setUpAnimation(startingPath, finishingPath)
        shadowLayer.add(layerAnimation, forKey: "path")
        
        isHidden.toggle()
    }
    
    enum ShadowViewState {
        case open
        case close
    }
    
    private func setUpAnimation(_ from: UIBezierPath, _ to: UIBezierPath) -> CABasicAnimation {
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = from.cgPath
        maskLayerAnimation.toValue = to.cgPath
        maskLayerAnimation.delegate = self
        maskLayerAnimation.duration = 0.5
        maskLayerAnimation.fillMode = .removed
        maskLayerAnimation.isRemovedOnCompletion = false
        return maskLayerAnimation
    }
    
    private var longestDistanceToTheCorner: CGFloat {
        let firstCatet = max(highlightedArea.centr.y, frame.size.height - highlightedArea.centr.y)
        let secondCatet = max(highlightedArea.centr.x, frame.size.width - highlightedArea.centr.x)
        return 2 * sqrt(pow(firstCatet, 2.0) + pow(secondCatet, 2.0))
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
        shadowLayer.fillColor = shadowColor.cgColor
        shadowLayer.fillRule = .evenOdd
        shadowLayer.lineCap = .butt
        shadowLayer.lineDashPattern = nil
        shadowLayer.lineDashPhase = 0.0
        shadowLayer.lineJoin = .miter
        shadowLayer.lineWidth = 0.0
        shadowLayer.miterLimit = 10.0
        shadowLayer.strokeColor = shadowColor.cgColor
    }

}
