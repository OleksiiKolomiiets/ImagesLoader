//
//  ShadowView.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 9/27/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

protocol ShadowViewDelegate: class {
    func shadowView(_ shadowView: ShadowView, didUserTapOnHighlightedFrame: Bool)
}

fileprivate class ShadowViewSettings {
    static var kAnimationKey = "Shadow"
}

class ShadowView: UIView, CAAnimationDelegate {
    
    // MARK: - Variables:
    
    public weak var delegate: ShadowViewDelegate!
    
    
    private let shadowLayer = CAShapeLayer()
    
    private var isOpenShadow = false
    
    private var isAnimationDidStop = true
    
    private var touchGesture: UITapGestureRecognizer!
    
    private var highlightedFrame: CGRect!
    private var isTapedOnFrame = false
    
    private var duration: Double {
       return isOpenShadow ? 0.5 : 0.2
    }
    
    private var animationLength: CGFloat {
        return CGFloat(abs(superview!.frame.height - highlightedFrame.origin.x))
    }
    
    private var highlightedFrameCirclePath: UIBezierPath {
        let radius = min(highlightedFrame.size.height, highlightedFrame.size.width) * 0.9 / 2
        let centr = CGPoint(x: highlightedFrame.midX, y: highlightedFrame.midY)
        return UIBezierPath(arcCenter: centr, radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
    }
    
    
    // MARK: - Actions:
    
    @objc private func viewPressed(_ gestureRecognizer: UITapGestureRecognizer) {
        if isAnimationDidStop {
            let tappedLocation = gestureRecognizer.location(in: self)
            isTapedOnFrame = highlightedFrameCirclePath.contains(tappedLocation)
        } else {
            cancelAnimationFor(layer)
        }
        
        shadowLayer.removeAllAnimations()
        layer.mask = nil
        
        // Signalizing delegate that view was pressed
        delegate.shadowView(self, didUserTapOnHighlightedFrame: isTapedOnFrame)
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
   
    /// Showing shadow for selected frame
    public func showShadow(for frame: CGRect, animated: Bool) {
        
        touchGesture.isEnabled = true
        
        highlightedFrame = frame
        
        isOpenShadow = true
        
        let shadowedPath = getCirclePath(by: frame, inverse: true)
        setUpShadowLayer(shadowLayer, with: shadowedPath.cgPath, inside: layer)
        
        // Adding animation
        if animated {
            let unshadowedPath = getCirclePath(inverse: true)
            setUpAnimation(from: unshadowedPath.cgPath, to: shadowedPath.cgPath, duration: duration)
        }
    }
    
    /// Dismissing shadow for highlighted frame
    public func dismissShadow(animated: Bool, finished: @escaping () -> Void) {
        
        touchGesture.isEnabled = false
        
        isOpenShadow = false
        
        let unshadowedPath = getCirclePath(inverse: true)
        setUpShadowLayer(shadowLayer, with: unshadowedPath.cgPath, inside: layer)
        
        // Adding animation
        if animated {
            let shadowedPath = getCirclePath(by: highlightedFrame, inverse: true)
            setUpAnimation(from: shadowedPath.cgPath, to: unshadowedPath.cgPath, duration: duration)
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                finished()
            }
        } else {
            finished()
        }
    }
    
    /// Canceling shadow animation
    private func cancelAnimationFor(_ layer: CALayer) {
        
        guard let shadowAnimation = layer.mask?.animation(forKey: ShadowViewSettings.kAnimationKey) as? CABasicAnimation else { return }
        
        let currentTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.beginTime = currentTime
        
        let timeSinceCancellation = CGFloat(currentTime - shadowAnimation.beginTime)
        let animationDuration = CGFloat(shadowAnimation.duration)
        let shadowAnimationVelocity = getVelocityOfAnimation(by: animationDuration)
        
        let passedLengthBeforeCancelation = shadowAnimationVelocity * timeSinceCancellation
        
        let increasingLength = animationLength - passedLengthBeforeCancelation
        
        highlightedFrame = getIncreasedRect(using: increasingLength)
        
    }
    
    private func getCirclePath(by frame: CGRect? = nil, inverse: Bool = false) -> UIBezierPath {
        
        let rectCentr: CGPoint!
        let radius: CGFloat!
        
        if let rect = frame {
            rectCentr = CGPoint(x: rect.midX, y: rect.midY)
            radius = min(rect.height, rect.width) * 0.9 / 2
        } else {
            rectCentr = CGPoint(x: superview!.frame.midX, y: superview!.frame.midY)
            radius = superview!.frame.height
        }
        
        let path = UIBezierPath(arcCenter   : rectCentr,
                                radius      : radius,
                                startAngle  : 0,
                                endAngle    : 2.0 * CGFloat.pi,
                                clockwise   : true)
        if inverse {
            path.append(UIBezierPath(rect: superview!.frame))
        }
        
        return path
    }
    
    private func setUpShadowLayer(_ shadowLayer: CAShapeLayer, with path: CGPath, inside layer: CALayer) {
        // Setting animation layer
        shadowLayer.fillRule = .evenOdd
        shadowLayer.path = path
        layer.mask = shadowLayer
    }
    
    private func setUpAnimation(from: CGPath, to: CGPath, duration: Double) {
        
        let animate = CABasicAnimation(keyPath: "path")
        
        animate.fromValue = from
        animate.toValue   = to
        animate.duration  = duration
        animate.delegate  = self
        animate.repeatCount = 0
        animate.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        
        shadowLayer.add(animate, forKey: ShadowViewSettings.kAnimationKey)
    }
    
    // Rectangle for cancelation
    private func getIncreasedRect(using distance: CGFloat ) -> CGRect {
        let width  = highlightedFrame.width    + CGFloat(2) * distance
        let height = highlightedFrame.height   + CGFloat(2) * distance
        let rectX  = highlightedFrame.origin.x - distance
        let rectY  = highlightedFrame.origin.y - distance
        
        let size  = CGSize(width: width, height: height)
        let point = CGPoint(x: rectX, y: rectY)
        
        return CGRect(origin: point, size: size)
    }
    
    private func getVelocityOfAnimation(by duration: CGFloat) -> CGFloat {
        return animationLength / duration
    }
    
    
    // MARK: - CAAnimationDelegate:
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        isAnimationDidStop = true
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        isAnimationDidStop = false
    }
}
