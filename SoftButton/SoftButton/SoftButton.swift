//
//  SoftButton.swift
//  SoftButtonExample
//
//  Copyright © 2018 ideil. All rights reserved.
//

import UIKit

@IBDesignable
open class SoftButton: UIButton, UIGestureRecognizerDelegate {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var bgColor: UIColor? {
        didSet {
            backgroundColor = bgColor
        }
    }
    
    @IBInspectable var highlightedBgColor: UIColor = UIColor.white
    
    @IBInspectable var gradientStartColor: UIColor? = nil
    @IBInspectable var gradientEndColor: UIColor? = nil
    @IBInspectable var isGradientHorizontal: Bool = false
    
    @IBInspectable var shadowOffset: Double = 0 {
        didSet {
            layer.shadowOffset = CGSize(width: 0, height: shadowOffset)
        }
    }
    
    @IBInspectable var activeShadowOffset: Double = 0
    
    
    @IBInspectable var shadowRadius: Double = 0 {
        didSet {
            layer.shadowRadius = CGFloat(shadowRadius)
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        }
    }
    @IBInspectable var activeShadowRadius: Double = 1 {
        didSet {
            if activeShadowRadius < 1 { activeShadowRadius = 1 }
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }
    @IBInspectable var shadowOpacity: CGFloat = 0 {
        didSet {
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }
    
    private let gradientLayer = CAGradientLayer()
    private var animator: UIViewPropertyAnimator!
    private var pressRecognizer: UILongPressGestureRecognizer!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupGradient()
        
        animator = UIViewPropertyAnimator(duration: 5, timingParameters: UISpringTimingParameters())
        animator.scrubsLinearly = true
        
        pressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SoftButton.handleTapGesture(_:)))
        pressRecognizer.delegate = self
        pressRecognizer.minimumPressDuration = 0
        pressRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(pressRecognizer)
    }
    
    private func setupGradient() {
        guard let gradientStartColor = gradientStartColor,
            let gradientEndColor = gradientEndColor else { return }
        
        gradientLayer.frame = bounds
        
        let colors = [gradientStartColor.cgColor, gradientEndColor.cgColor]
        gradientLayer.colors = colors
        gradientLayer.cornerRadius = cornerRadius
        
        if isGradientHorizontal {
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        } else {
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        }
        
        layer.insertSublayer(gradientLayer, at: 0)
        setNeedsDisplay()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        if layer == self.layer {
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            setupGradient()
        }
    }
    
    private var caFraction: Double = 0
    private var caLength: Double = 1
    
    @objc
    func handleTapGesture(_ sender: UILongPressGestureRecognizer) {
        var fractionComplete: Double?
        
        if animator.isRunning && sender.state != .changed {
            fractionComplete = Double(animator.fractionComplete)
            
            animator.stopAnimation(false)
            animator.finishAnimation(at: .current)
            
            layer.removeAnimation(forKey: "buttonPush")
        }
        
        switch sender.state {
        case .began:
            let feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator.selectionChanged()
            
            animator.addAnimations {
                self.backgroundColor = self.highlightedBgColor
                self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            }
            
            if let fractionComplete = fractionComplete {
                caFraction = caFraction - caLength * fractionComplete
                caLength = 1 - caFraction
            } else {
                caFraction = 0
                caLength = 1
            }

            self.layer.shadowRadius = CGFloat(activeShadowRadius)
            let animRadius = CABasicAnimation(keyPath: "shadowRadius")
            if fractionComplete != nil {
                animRadius.fromValue = NSNumber(floatLiteral: shadowRadius - (shadowRadius - activeShadowRadius) * caFraction)
            } else {
                animRadius.fromValue = NSNumber(floatLiteral: shadowRadius)
            }
            animRadius.toValue = NSNumber(floatLiteral: activeShadowRadius)

            layer.shadowOffset = CGSize(width: 0, height: activeShadowOffset)
            let animOffset = CABasicAnimation(keyPath: "shadowOffset.height")

            if fractionComplete != nil {
                animOffset.fromValue = NSNumber(floatLiteral: shadowOffset - (shadowOffset - activeShadowOffset) * caFraction)
            } else {
                animOffset.fromValue = NSNumber(floatLiteral: shadowOffset)
            }

            animOffset.toValue = NSNumber(floatLiteral: activeShadowOffset)

            let animGroup = CAAnimationGroup()
            animGroup.duration = animator.duration
            animGroup.timingFunction = CAMediaTimingFunction(controlPoints: 0.0, 0.0, 0.25, 1.0)
            animGroup.animations = [animRadius, animOffset]

            layer.add(animGroup, forKey: "buttonPush")
            layer.speed = 1.6
            
        case .ended, .cancelled:
            animator.addAnimations {
                self.backgroundColor = self.bgColor
                self.transform = CGAffineTransform.identity
            }
            
            if let fractionComplete = fractionComplete {
                caFraction = caLength * fractionComplete + caFraction
                caLength = caFraction
            } else {
                caFraction = 1
                caLength = 1
            }
            
            self.layer.shadowRadius = CGFloat(shadowRadius)
            let animRadius = CABasicAnimation(keyPath: "shadowRadius")
            if let fractionComplete = fractionComplete {
                animRadius.fromValue = NSNumber(floatLiteral: activeShadowRadius + (shadowRadius - activeShadowRadius) * (activeShadowRadius - fractionComplete))
            } else {
                animRadius.fromValue = NSNumber(floatLiteral: activeShadowRadius)
            }
            animRadius.toValue = NSNumber(floatLiteral: shadowRadius)
            
            layer.shadowOffset.height = CGFloat(shadowOffset)
            let animOffset = CABasicAnimation(keyPath: "shadowOffset.height")
            
            if fractionComplete != nil {
                animOffset.fromValue = NSNumber(floatLiteral: activeShadowOffset + (shadowOffset - activeShadowOffset) * (1 - caFraction))
            } else {
                animOffset.fromValue = NSNumber(floatLiteral: activeShadowOffset)
            }
            animOffset.toValue = NSNumber(floatLiteral: shadowOffset)
            
            let animGroup = CAAnimationGroup()
            animGroup.duration = animator.duration
            animGroup.timingFunction = CAMediaTimingFunction(controlPoints: 0.0, 0.75, 1.0, 1.0)
            animGroup.animations = [animRadius, animOffset]
            
            layer.add(animGroup, forKey: "buttonPush")
            layer.speed = 1
            
        default:
            return
        }
        
        if !animator.isRunning {
            animator.startAnimation()
        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
