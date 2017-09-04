//
//  Animation.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 16/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit

/// Animation closure which passes a view instance to configure what's being animated.
public typealias ViewAnimation<T: UIView> = (T) -> Void


/// Describer of the timing and nature of an animation.
public enum AnimationCurve {
    case easing(curve: UIViewAnimationCurve, duration: TimeInterval, additive: Bool)
    case spring(damping: CGFloat, initialVelocity: CGFloat, duration: TimeInterval, additive: Bool)
}


/// Useful constants when performing animations
public struct AnimationConstants {
    
    /// Zero for the purposes of animating a transform scale to zero without breaking the math
    static let zeroScale: CGFloat = 0.0001
}


/// Helper structure to pair the animation closure with its curve.
public struct AnimationConfig<T: UIView> {
    public let curve: AnimationCurve
    public let animations: ViewAnimation<T>
    
    public init(curve: AnimationCurve, animations: @escaping ViewAnimation<T>) {
        self.curve = curve
        self.animations = animations
    }
}


/// Behaviour rules for how animations should interrupt others.
public enum AnimationPlayoutBehaviour {
    
    /// Animation can immediately be interrupted by another animation.
    case none
    
    /// Other animations always wait for an animation to fully complete / play out.
    case full
    
    /// Other animations wait for a minimum interval to pass before potentially interrupting an animation.
    case minimum(duration: TimeInterval)
}


/// Targets which can be asked to perform "tap down" and "tap up" behaviours
public protocol TapDownUpAnimatable {
    associatedtype TargetType: UIView
    
    /// Set the animation that will run on tap down (NOTE: this overrides any previous setting)
    func animateOnTapDown(with curve: AnimationCurve, animations: @escaping ViewAnimation<TargetType>)
    
    /// Set the animation that will run on tap up (NOTE: this overrides any previous setting)
    func animateOnTapUp(with curve: AnimationCurve, animations: @escaping ViewAnimation<TargetType>)
    
    /// Add any number of secondary tap down animations that trigger alongside the primary animation but run with different curves
    func addSecondaryAnimationOnTapDown(with curve: AnimationCurve, animations: @escaping ViewAnimation<TargetType>)
    
    /// Add any number of secondary tap up animations that trigger alongside the primary animation but run with different curves
    func addSecondaryAnimationOnTapUp(with curve: AnimationCurve, animations: @escaping ViewAnimation<TargetType>)
    
    /// Set a closure to run just before tap down animations run
    func beforeTapDownAnimation(do closure: @escaping ()->())
    
    /// Set a closure to run just before tap up animations run
    func beforeTapUpAnimation(do closure: @escaping ()->())
    
    /// Set a closure to run just after tap down animations run
    func afterTapDownAnimation(do closure: @escaping ()->())
    
    /// Set a closure to run just after tap up animations run
    func afterTapUpAnimation(do closure: @escaping ()->())
}


/// Protocol for views that can perform "breathe" animations - ambient animations that are cycling or ongoing.
public protocol Breathable {
    
    /// Start the breathing animations
    func startBreathing()
    
    /// Stop the breathing animations
    func stopBreathing()
    
    /// Whether or not the view is currently breathing
    var isBreathing: Bool { get }
}


/// Protocol for views that can perform show and hide animations.
public protocol ShowHideable {
    
    /// Reveal the view with or without animation.
    func show(animate: Bool, alongside: (()->())?, completion: (()->())?)
    
    /// Make the view disappear with or without animation.
    func hide(animate: Bool, alongside: (()->())?, completion: (()->())?)
    
    /// Whether or not the view is currently showing
    var isShowing: Bool { get }
}


/// Protocol for views that can perform a brief "pulse" animation and return to normal - designed to draw attention to itself without interaction.
public protocol Pulseable {
    
    /// Perform the pulse animation.
    func pulse(completion: (()->())?)
}


/** Protocol for objects that will do animations on behalf of a target.
 
 General guidelines for Animators:
 
 - They should be retained by something else, rather than retain themselves (ie within animation blocks etc).
 - They should not strongly retain the target.
 - Controllers wishing to interrupt animations should cancel() the animator then stopAnimations() on the target.
 - Views can encapsulate animators inside them for convenience and retention, and are encouraged to call cancel() on their animators when stopAnimations() is called.
 - Animators should not call stopAnimations() on the target during cancel(), so as to avoid infinite loops when encapsulated within views. That's why it's called cancel - just prevent further animations that may not have been set yet. In many cases an animator may have nothing to do in response to cancel().
 - Animators should contain actual animations (which may or may not be controlled by parameters) rather than just 'helper' logic. You should be able to simply apply an animator and see it working with default behaviours.
 */
public protocol Animator {
    
    /// The view subclass the animator knows how to deal with (UIView may be sufficient).
    associatedtype TargetType: UIView
    
    /// The target view to animate.
    weak var target: TargetType? { get }
    
    /// Initialise with a target view to animate.
    init(target: TargetType)
    
    /// Prevent further animations from being scheduled on the target.
    func cancel()
}


/// Handy helpers for UIView
public extension UIView {
    
    /// Interrupt any running animations, forcing them to halt as they currently appear (rather than completing instantly or returning to their initial state)
    func stopAnimations() {
        
        if let presentation = self.layer.presentation() {
            
            // Copy any animatable properties from the presentation layer to the model layer
            layer.contents = presentation.contents
            layer.contentsRect = presentation.contentsRect
            layer.contentsCenter = presentation.contentsCenter
            layer.opacity = presentation.opacity
            layer.isHidden = presentation.isHidden
            layer.masksToBounds = presentation.isHidden
            layer.isDoubleSided = presentation.isDoubleSided
            layer.cornerRadius = presentation.cornerRadius
            layer.borderWidth = presentation.borderWidth
            layer.borderColor = presentation.borderColor
            layer.backgroundColor = presentation.backgroundColor
            layer.shadowOpacity = presentation.shadowOpacity
            layer.shadowRadius = presentation.shadowRadius
            layer.shadowOffset = presentation.shadowOffset
            layer.shadowColor = presentation.shadowColor
            layer.shadowPath = presentation.shadowPath
            layer.filters = presentation.filters
            layer.compositingFilter = presentation.compositingFilter
            layer.backgroundFilters = presentation.backgroundFilters
            layer.shouldRasterize = presentation.shouldRasterize
            layer.rasterizationScale = presentation.rasterizationScale
            layer.bounds = presentation.bounds
            layer.position = presentation.position
            layer.zPosition = presentation.zPosition
            layer.anchorPointZ = presentation.anchorPointZ
            layer.anchorPoint = presentation.anchorPoint
            layer.transform = presentation.transform
            layer.sublayerTransform = presentation.sublayerTransform
        }
        self.layer.removeAllAnimations()
    }
    
    /// Apply the animations as set out in an animation config
    func runAnimation<T: UIView>(_ animationConfig: AnimationConfig<T>, delay: TimeInterval = 0.0, completion: ((Bool)->())? = nil) {
        guard let selfRef = self as? T else { return }
        let animations = {
            animationConfig.animations(selfRef)
        }
        
        switch animationConfig.curve {
        case .easing(let curve, let duration, let additive):
            
            if !additive {
                stopAnimations()
            }
            
            var translatedCurve: UIViewAnimationOptions
            switch curve {
            case .easeIn:
                translatedCurve = .curveEaseIn
            case .easeOut:
                translatedCurve = .curveEaseOut
            case .easeInOut:
                translatedCurve = .curveEaseInOut
            case .linear:
                translatedCurve = .curveLinear
            }
            translatedCurve = [translatedCurve, .allowUserInteraction, .beginFromCurrentState]
            UIView.animate(withDuration: duration, delay: delay, options: translatedCurve, animations: animations, completion: completion)
            
        case .spring(let damping, let initialVelocity, let duration, let additive):
            if !additive {
                stopAnimations()
            }
            
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: initialVelocity, options: .allowUserInteraction, animations: animations, completion: completion)
        }
    }
}
