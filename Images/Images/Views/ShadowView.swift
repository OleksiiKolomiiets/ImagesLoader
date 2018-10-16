//
//  ShadowView.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 9/27/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

protocol ShadowViewDelegate: class {
    func shadowView(_ shadowView: ShadowView, didUserTapOnHighlightedArea: Bool)
}

class ShadowView: UIView {
    
    // MARK: - Variables:
    weak var delegate: ShadowViewDelegate!
    private let shadowLayer = CAShapeLayer()
    private var isOpenShadow = false
    private var touchGesture: UITapGestureRecognizer!
    private var highlightedArea: CircleArea!
    private var isTapedOnArea: Bool!
    private var  duration: Double {
       return isOpenShadow ? 0.7 : 0.3
    }
    
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
        
        let tappedLocation = gestureRecognizer.location(in: self)
        let highlightedAreaCirclePath = UIBezierPath(arcCenter: highlightedArea.centr,
                                                     radius: highlightedArea.radius,
                                                     startAngle: CGFloat(0),
                                                     endAngle:CGFloat(Double.pi * 2),
                                                     clockwise: true)
        isTapedOnArea = highlightedAreaCirclePath.contains(tappedLocation)
        
        // Signalizing delegate that view was tapped
        delegate.shadowView(self, didUserTapOnHighlightedArea: isTapedOnArea)
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
            setUpAnimation(from: unshadowedPath.cgPath, to: shadowedPath.cgPath, duration: duration)
        }
    }
    
    func dismissShadow(animated: Bool, finished: @escaping () -> Void) {
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
            setUpAnimation(from: shadowedPath.cgPath, to: unshadowedPath.cgPath, duration: duration)
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                finished()
            }
        } else {
            finished()
        }
    }
    
    private func getCirclePath(by area: CircleArea? = nil, inverse: Bool = false) -> UIBezierPath {
        let path = UIBezierPath(arcCenter   : area != nil ? area!.centr  : superview!.frame.centr,
                                radius      : area != nil ? area!.radius : superview!.frame.height,
                                startAngle  : 0,
                                endAngle    : 2.0 * CGFloat.pi,
                                clockwise   : true)
        if inverse {
            path.append(UIBezierPath(rect: superview!.frame))
        }
        return path
    }
    
    private func setUpAnimation(from: CGPath, to: CGPath, duration: Double) {
        let animate = CABasicAnimation(keyPath: "path")
        
        animate.fromValue = from
        animate.toValue   = to
        animate.duration  = duration
        animate.delegate  = self
        animate.repeatCount = 0
        
        shadowLayer.add(animate, forKey: "Shadow for selected area")
        
    }
    
}

extension ShadowView: CAAnimationDelegate {
    
    // MARK: - Animation delegate:
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        touchGesture.isEnabled = true
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        touchGesture.isEnabled = false
    }
}
