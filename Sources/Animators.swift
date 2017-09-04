//
//  Animators.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 26/8/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit



/// Animator that implements ShowHideable with some default animations and curves
public class ShowHideAnimator<T: UIView>: Animator, ShowHideable {
    
    
    
    // MARK: - Properties
    
    /// Curve to use when animating to the showing state
    public var showCurve: AnimationCurve = .spring(damping: 0.7, initialVelocity: 0.0, duration: 0.3, additive: false)
    
    /// Curve to use when animating to the hidden state
    public var hideCurve: AnimationCurve = .spring(damping: 0.7, initialVelocity: 0.0, duration: 0.3, additive: false)
    
    /// Alpha value to set when in the showing state
    public var showAlpha: CGFloat = 1.0
    
    /// Alpha value to set when in the hidden state
    public var hideAlpha: CGFloat = 0.0
    
    /// Transform to apply when in the showing state
    public var showTransform = CGAffineTransform.identity
    
    /// Transform to apply when in the hidden state
    public var hideTransform = CGAffineTransform(scaleX: AnimationConstants.zeroScale, y: AnimationConstants.zeroScale)
    
    
    
    // MARK: - Private variables
    
    public private(set) weak var target: T?
    
    
    
    // MARK: - Animator
    
    public typealias TargetType = T
    
    public required init(target: T) {
        self.target = target
    }
    
    public func cancel() {
        // (nothing special to do)
    }
    
    
    
    // MARK: - ShowHideable
    
    public var isShowing: Bool {
        guard let target = self.target else { return false }
        return !target.isHidden && target.alpha > hideAlpha
    }
    
    public func show(animate: Bool, alongside: (() -> ())? = nil, completion: (() -> ())? = nil) {
        guard let target = self.target else {
            completion?()
            return
        }
        
        // Build the animation to run
        let targetTransform = showTransform
        let targetAlpha = showAlpha
        let animations: ViewAnimation<T> = { (target) in
            target.transform = targetTransform
            target.alpha = targetAlpha
            target.isHidden = false // (just in case this has been set)
            alongside?()
        }
        let config = AnimationConfig<T>(curve: showCurve, animations: animations)
        
        // Do the work, animated or not
        if animate {
            if let handler = completion {
                target.runAnimation(config) { _ in
                    handler()
                }
            } else {
                target.runAnimation(config)
            }
        } else {
            target.stopAnimations()
            config.animations(target)
        }
    }
    
    public func hide(animate: Bool, alongside: (() -> ())? = nil, completion: (() -> ())? = nil) {
        guard let target = self.target else {
            completion?()
            return
        }
        
        // Build the animation to run
        let targetTransform = hideTransform
        let targetAlpha = hideAlpha
        let animations: ViewAnimation<T> = { (target) in
            target.transform = targetTransform
            target.alpha = targetAlpha
            alongside?()
        }
        let config = AnimationConfig<T>(curve: hideCurve, animations: animations)
        
        // Do the work, animated or not
        if animate {
            if let handler = completion {
                target.runAnimation(config) { _ in
                    handler()
                }
            } else {
                target.runAnimation(config)
            }
        } else {
            target.stopAnimations()
            config.animations(target)
        }
    }
}




/** A pulse animation that scales a view to an extent and then brings it back to normal.
 This is implemented as a 2 step animation, which is controlled by properties related to either "firstStage" or "secondStage".
 */
public class BouncePulseAnimator: Animator, Pulseable {
    
    
    // MARK: - Properties
    
    /// Curve to apply for the initial part of the 2 stage animation.
    public var firstStageCurve: AnimationCurve = .easing(curve: .easeOut, duration: 0.15, additive: true)
    
    /// Curve to apply for the final part of the 2 stage animation.
    public var secondStageCurve: AnimationCurve = .spring(damping: 0.4, initialVelocity: 0.0, duration: 0.5, additive: true)
    
    /// Amount to either grow or shrink the target size.
    public var scale: CGFloat = 1.1
    
    /// The rules about how the first stage should be interrupted by the second stage. Tweaking this may help make the 2 animations feel like 1.
    public var firstStagePlayoutBehaviour: AnimationPlayoutBehaviour = .full
    
    
    
    // MARK: - Private variables
    
    public private(set) weak var target: UIView?
    private var _shouldStop = false
    
    
    
    // MARK: - Animator
    
    public typealias TargetType = UIView
    
    public required init(target: UIView) {
        self.target = target
    }
    
    public func cancel() {
        _shouldStop = true
    }
    
    
    
    // MARK: - Pulseable
    
    public func pulse(completion: (() -> ())? = nil) {
        guard let target = self.target else {
            completion?()
            return
        }
        _shouldStop = false
        
        // Define the animations
        let scale = self.scale
        let firstStage = AnimationConfig<UIView>(curve: firstStageCurve) { (target) in
            target.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        let secondStage = AnimationConfig<UIView>(curve: secondStageCurve) { (target) in
            target.transform = CGAffineTransform.identity
        }
        
        // Run them while respecting the playout intent
        switch firstStagePlayoutBehaviour {
        case .full:
            target.runAnimation(firstStage) { _ in
                guard !self._shouldStop, let target = self.target else {
                    completion?()
                    return
                }
                target.runAnimation(secondStage) { _ in
                    completion?()
                }
            }
            
        case .minimum(let duration):
            
            // Start the second stage after the duration
            target.runAnimation(firstStage)
            target.runAnimation(secondStage, delay: duration) { _ in
                completion?()
            }
            
        case .none:
            
            // None doesn't really make sense in this context, but let's take it to mean skip the first stage
            target.runAnimation(secondStage) { _ in
                completion?()
            }
        }
    }
}




/// Animation for a type of breathing where the view repeatedly grows and shrinks
public class BounceDownUpBreatheAnimator: Animator, Breathable {
    
    
    
    // MARK: - Properties
    
    /// The amount to grow the target by when breathing "up".
    public var growthFactor: CGFloat = 1.07
    
    /// The amount to shrink the target by when breathing "down".
    public var shrinkFactor: CGFloat = 0.93
    
    /// Whether or not to start the cycle via the grow/up stage.
    public var startWithGrowth = false
    
    /// The curve to apply when running the "up" animation.
    public var scaleUpAnimationCurve: AnimationCurve = .easing(curve: .easeInOut, duration: 1.75, additive: true)
    
    /// The curve to apply when running the "down" animation.
    public var scaleDownAnimationCurve: AnimationCurve = .easing(curve: .easeInOut, duration: 1.75, additive: true)
    
    
    
    // MARK: - Private variables
    
    public private(set) weak var target: UIView?
    private var _isUp = false
    private var _breatheUpConfig: AnimationConfig<UIView>!
    private var _breatheDownConfig: AnimationConfig<UIView>!
    
    
    
    // MARK: - Animator
    
    public typealias TargetType = UIView
    
    public required init(target: UIView) {
        self.target = target
    }
    
    public func cancel() {
        stopBreathing()
    }
    
    
    
    // MARK: - Breathable
    
    /// Whether or not the view is currently breathing
    public private(set) var isBreathing = false
    
    /// Start the breathing animations
    public func startBreathing() {
        guard !isBreathing else { return }
        isBreathing = true
        setupConfigs()
        startWithGrowth ? breatheUp() : breatheDown()
    }
    
    /// Stop the breathing animations
    public func stopBreathing() {
        guard isBreathing else { return }
        isBreathing = false
        
        // Return to the normal position
        // NOTE: If this is undesirable the user can just cancel animations after calling this
        let returnCurve = _isUp ? scaleDownAnimationCurve : scaleUpAnimationCurve
        returnToNormal(with: returnCurve)
    }
    
    
    
    // MARK: - Private helpers
    
    private func setupConfigs() {
        _breatheUpConfig = AnimationConfig<UIView>(curve: scaleUpAnimationCurve) { [weak self] (target) in
            guard let selfRef = self else { return }
            target.transform = CGAffineTransform(scaleX: selfRef.growthFactor, y: selfRef.growthFactor)
        }
        _breatheDownConfig = AnimationConfig<UIView>(curve: scaleDownAnimationCurve) { [weak self] (target) in
            guard let selfRef = self else { return }
            target.transform = CGAffineTransform(scaleX: selfRef.shrinkFactor, y: selfRef.shrinkFactor)
        }
    }
    
    private func breatheUp() {
        guard isBreathing else { return }
        self.target?.runAnimation(_breatheUpConfig) { [weak self] _ in
            guard let selfRef = self else { return }
            selfRef._isUp = true
            selfRef.breatheDown()
        }
    }
    
    private func breatheDown() {
        guard isBreathing else { return }
        self.target?.runAnimation(_breatheDownConfig) { [weak self] _ in
            guard let selfRef = self else { return }
            selfRef._isUp = false
            selfRef.breatheUp()
        }
    }
    
    private func returnToNormal(with curve: AnimationCurve) {
        let config = AnimationConfig<UIView>(curve: curve) { (target) in
            target.transform = CGAffineTransform.identity
        }
        self.target?.runAnimation(config)
    }
}




/** Animator that is capable of scheduling one or more animations to happen in a tap down/up fashion. In particular it provides/respects tap down animation playout behaviour.
 
 NOTE: This breaks the animator guidelines because the actual animation being done is undefined / needs to be provided, but it's more handy to have this be an animator rather than wrapped up as helper of some sort.
 */
public class TapDownUpAnimator<T: UIView>: Animator {
    
    
    
    // MARK: - Private variables
    
    public typealias TargetType = T // (for Animator)
    public private(set) weak var target: T?
    
    private var _tapDownState: AnimationConfig<T>?
    private var _tapUpState: AnimationConfig<T>?
    private var _beforeTapDown: (()->())?
    private var _beforeTapUp: (()->())?
    private var _afterTapDown: (()->())?
    private var _afterTapUp: (()->())?
    
    private lazy var _secondaryTapDownStates = [AnimationConfig<T>]()
    private lazy var _secondaryTapUpStates = [AnimationConfig<T>]()
    
    private var _tapDownTimestamp: Date?
    private var _waitingToPerformTapUp = false
    private var _tapDownAnimationRunning = false
    private var _doTapUpAnimationAfterTapDown = false
    
    
    
    // MARK: - Animator
    
    public required init(target: T) {
        self.target = target
    }
    
    public func cancel() {
        preventDelayedTapUpAnimationIfApplicable()
    }
    
    private func preventDelayedTapUpAnimationIfApplicable() {
        _doTapUpAnimationAfterTapDown = false
        _waitingToPerformTapUp = false
    }
    
    
    
    // MARK: - Public methods
    
    /// The rules about how tap down animations should be interrupted by tap up animation.
    public var tapDownAnimationPlayoutBehaviour: AnimationPlayoutBehaviour = .full
    
    public func animateOnTapDown(with curve: AnimationCurve, animations: @escaping ViewAnimation<T>) {
        _tapDownState = AnimationConfig(curve: curve, animations: animations)
    }
    
    public func animateOnTapUp(with curve: AnimationCurve, animations: @escaping ViewAnimation<T>) {
        _tapUpState = AnimationConfig(curve: curve, animations: animations)
    }
    
    public func addSecondaryAnimationOnTapDown(with curve: AnimationCurve, animations: @escaping ViewAnimation<T>) {
        _secondaryTapDownStates.append(AnimationConfig(curve: curve, animations: animations))
    }
    
    public func addSecondaryAnimationOnTapUp(with curve: AnimationCurve, animations: @escaping ViewAnimation<T>) {
        _secondaryTapUpStates.append(AnimationConfig(curve: curve, animations: animations))
    }
    
    public func beforeTapDownAnimation(do closure: @escaping ()->()) {
        _beforeTapDown = closure
    }
    
    public func beforeTapUpAnimation(do closure: @escaping ()->()) {
        _beforeTapUp = closure
    }
    
    public func afterTapDownAnimation(do closure: @escaping ()->()) {
        _afterTapDown = closure
    }
    
    public func afterTapUpAnimation(do closure: @escaping ()->()) {
        _afterTapUp = closure
    }
    
    public func doTapDownAnimation() {
        guard !_tapDownAnimationRunning, let target = self.target else { return }
        _beforeTapDown?()
        preventDelayedTapUpAnimationIfApplicable()
        guard let animationConfig = _tapDownState else { return }
        
        // Run the animation
        _tapDownAnimationRunning = true
        _tapDownTimestamp = Date()
        target.runAnimation(animationConfig) { [weak self] _ in
            guard let selfRef = self else { return }
            
            selfRef._tapDownAnimationRunning = false
            selfRef._afterTapDown?()
            if selfRef._doTapUpAnimationAfterTapDown {
                selfRef.doTapUpAnimation()
            }
        }
        
        // Do any secondary animations
        for secondary in _secondaryTapDownStates {
            target.runAnimation(secondary)
        }
    }
    
    @objc public func doTapUpAnimation() {
        preventDelayedTapUpAnimationIfApplicable()
        guard let animationConfig = _tapUpState else { return }
        
        // Define the animation to do, which is a combination of the main one and any secondary ones
        let animate = { [weak self] in
            guard let selfRef = self, let target = selfRef.target else { return }
            
            // Primary
            selfRef._tapDownAnimationRunning = false
            target.runAnimation(animationConfig) { [weak self] _ in
                self?._afterTapUp?()
            }
            
            // Do any secondary animations
            for secondary in selfRef._secondaryTapUpStates {
                target.runAnimation(secondary)
            }
        }
        
        // If we're supposed to wait for a tap down animation to complete, delay this for the remaining part of the minimum interval
        switch tapDownAnimationPlayoutBehaviour {
        case .minimum(let minimumInterval):
            
            // NOTE: Because the delay calls this method again when it fires, we account for the worst case of tolerance to avoid it being scheduled again after firing...
            
            let tolerance = 0.01
            let timeSinceTapDown = fabs(_tapDownTimestamp!.timeIntervalSinceNow)
            if timeSinceTapDown < (minimumInterval - tolerance) {
                
                // Schedule the tap up to happen later
                let timeToDelayBy = minimumInterval - timeSinceTapDown
                _waitingToPerformTapUp = true
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(timeToDelayBy * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), qos: .userInteractive) {
                    if self._waitingToPerformTapUp {
                        self._waitingToPerformTapUp = false
                        self.doTapUpAnimation()
                    }
                }
            } else {
                _beforeTapUp?()
                animate()
            }
            
        case .full:
            if _tapDownAnimationRunning {
                _doTapUpAnimationAfterTapDown = true
            } else {
                _beforeTapUp?()
                animate()
            }
        case .none:
            _beforeTapUp?()
            animate()
        }
    }
}
