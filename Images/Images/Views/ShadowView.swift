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
    private let shadowLayer = CAShapeLayer()
    private var isOpenShadow = false
    private var touchGesture: UITapGestureRecognizer!
    private var highlightedArea: CircleArea!
    
    // MARK: - Functions:
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addTapGestureRecognizer(for: self)
    }
    
    private func addTapGestureRecognizer(for view: UIView) {
        // Adding gesture recognizer for dealing with view taps
        touchGesture = UITapGestureRecognizer(target: view, action: #selector(viewPressed(_:)))
        touchGesture.numberOfTapsRequired = 1
        addGestureRecognizer(touchGesture)
    }
    
    @objc private func viewPressed(_ gestureRecognizer: UITapGestureRecognizer) {
        shadowLayer.removeAllAnimations()
        layer.mask = nil
        let highlightedAreaCirclePath = UIBezierPath(arcCenter: highlightedArea.centr,
                                                     radius: highlightedArea.radius,
                                                     startAngle: CGFloat(0),
                                                     endAngle:CGFloat(Double.pi * 2),
                                                     clockwise: true)
        let tappedLocation = gestureRecognizer.location(in: self)
        let isTapedOnArea = highlightedAreaCirclePath.contains(tappedLocation)
        
        // Sending result of tap through delegate method
        delegate.shadowView(self, onUserConfirm: isTapedOnArea)
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
        
        highlightedArea = area
        
        isOpenShadow = true
        
        // Setting pathes by area
        let shadowedPath = getCirclePath(by: area, inverse: true)
       
        // Setting animation layer
        shadowLayer.fillRule = .evenOdd
        shadowLayer.path = shadowedPath.cgPath
        layer.mask = shadowLayer
        
        // Adding animation
        if animated {
            let unshadowedPath = getCirclePath(inverse: true)
            setUpAnimation(from: unshadowedPath.cgPath, to: shadowedPath.cgPath)
        }
    }
    
    func dismissShadow(animated: Bool) {
        isOpenShadow = false
        
        // Setting pathes by area
        let unshadowedPath = getCirclePath(inverse: true)
        
        // Setting animation layer
        shadowLayer.fillRule = .evenOdd
        shadowLayer.path = unshadowedPath.cgPath
        layer.mask = shadowLayer
        
        // Adding animation
        if animated {
            let shadowedPath = getCirclePath(by: highlightedArea, inverse: true)
            setUpAnimation(from: shadowedPath.cgPath, to: unshadowedPath.cgPath)
        }
        
    }
    
    private func getCirclePath(by area: CircleArea? = nil, inverse: Bool = false) -> UIBezierPath {
        let upperCoefficient: CGFloat = 1.5 //
        let path = UIBezierPath(arcCenter   : area != nil ? area!.centr  : self.frame.centr,
                                radius      : area != nil ? area!.radius : self.frame.height * upperCoefficient,
                                startAngle  : 0,
                                endAngle    : 2.0 * CGFloat.pi,
                                clockwise   : true)
        if inverse {
            path.append(UIBezierPath(rect: self.frame))
        }
        return path
    }
    
    private func setUpAnimation(from: CGPath, to: CGPath) {
        let animate = CABasicAnimation(keyPath: "path")
        
        animate.fromValue = from
        animate.toValue   = to
        animate.duration  = isOpenShadow ? 0.7 : 0.3
        animate.delegate  = self
        
        shadowLayer.add(animate, forKey: "Shadow for selected area")
    }
    
}
