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

class ShadowView: UIView {
    
    // MARK: - Variables:
    public weak var delegate: ShadowViewDelegate!
    
    private let shadowLayer = CAShapeLayer()
    private var isOpenShadow = false
    private var touchGesture: UITapGestureRecognizer!
    private var highlightedFrame: CGRect!
    private var isTapedOnFrame: Bool!
    private var  duration: Double {
       return isOpenShadow ? 0.5 : 0.2
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
        let radius = min(highlightedFrame.size.height, highlightedFrame.size.width) * 0.9 / 2
        let centr = CGPoint(x: highlightedFrame.midX, y: highlightedFrame.midY)
        
        let tappedLocation = gestureRecognizer.location(in: self)
        let highlightedFrameCirclePath = UIBezierPath(arcCenter: centr,
                                                     radius: radius,
                                                     startAngle: CGFloat(0),
                                                     endAngle:CGFloat(Double.pi * 2),
                                                     clockwise: true)
        isTapedOnFrame = highlightedFrameCirclePath.contains(tappedLocation)
        // Signalizing delegate that view was tapped
        delegate.shadowView(self, didUserTapOnHighlightedFrame: isTapedOnFrame)
    }
    
    /// Showing shadow for selected frame
    public func showShadow(for frame: CGRect, animated: Bool) {
        
        highlightedFrame = frame
        
        isOpenShadow = true
        
        let shadowedPath = getCirclePath(by: frame, inverse: true)
        setupShadowLayer(shadowLayer, with: shadowedPath.cgPath, inside: layer)
        
        // Adding animation
        if animated {
            let unshadowedPath = getCirclePath(inverse: true)
            setupAnimation(from: unshadowedPath.cgPath, to: shadowedPath.cgPath, duration: duration)
        }
    }
    
    private func setupShadowLayer(_ shadowLayer: CAShapeLayer, with path: CGPath, inside layer: CALayer) {
        // Setting animation layer
        shadowLayer.fillRule = .evenOdd
        shadowLayer.path = path
        layer.mask = shadowLayer
    }
    
    public func dismissShadow(animated: Bool, finished: @escaping () -> Void) {
        
        isOpenShadow = false
        
        let unshadowedPath = getCirclePath(inverse: true)
        setupShadowLayer(shadowLayer, with: unshadowedPath.cgPath, inside: layer)
        
        // Adding animation
        if animated {
            let shadowedPath = getCirclePath(by: highlightedFrame, inverse: true)
            setupAnimation(from: shadowedPath.cgPath, to: unshadowedPath.cgPath, duration: duration)
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                finished()
            }
        } else {
            finished()
        }
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
    
    private func setupAnimation(from: CGPath, to: CGPath, duration: Double) {
        
        let animate = CABasicAnimation(keyPath: "path")
        
        animate.fromValue = from
        animate.toValue   = to
        animate.duration  = duration
        animate.delegate  = self
        animate.repeatCount = 0
        
        shadowLayer.add(animate, forKey: "Shadow for selected frame")
        
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
