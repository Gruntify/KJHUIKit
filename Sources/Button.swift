//
//  Button.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 1/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit


/// Base class for buttons that come with some animation capabilities and nifty features.
@objc open class Button: UIControl {
    public typealias TargetType = Button
    
    
    // MARK: - Types
    
    /// Behaviour parameters for tap hold mechanics.
    public enum TapHoldBehaviour {
        case none
        case enabled(delay: TimeInterval, interval: TimeInterval)
    }
    
    
    
    // MARK: - Properties
    
    /// The animator in charge of stuff related to button pressing
    public var tapAnimator: TapDownUpAnimator<UIView>?
    
    /// Whether or not to round the sides into a pill shaped button.
    @objc public var roundedSides = false {
        didSet {
            if roundedSides {
                self.clipsToBounds = true
            } else {
                self.layer.cornerRadius = 0
                
                // NOTE: Not setting clipsToBounds back to false in case they wanted that
            }
            self.setNeedsLayout()
        }
    }
    
    /// The behaviour mechanics of tap hold detection, if desired.
    public var tapHoldBehaviour: TapHoldBehaviour = .none
    
    
    
    // MARK: - Lifecycle
    
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupButton()
    }
    
    @objc public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupButton()
    }
    
    @objc public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    private func setupButton() {
        self.clipsToBounds = true
    }
    
    @objc open override func layoutSubviews() {
        super.layoutSubviews()
        if roundedSides {
            self.layer.cornerRadius = self.bounds.size.height / 2.0
        }
    }
    
    @objc open override var intrinsicContentSize: CGSize {
        get {
            
            // Just return something that matches our touch size (subclasses will override)
            // NOTE: This is just visual - touches will always use at least this size even when overriden or constrained to be smaller
            let minTouchSize: CGFloat = 44.0
            return CGSize(width: minTouchSize, height: minTouchSize)
        }
    }
    
    
    
    
    // MARK: - Animation control
    
    @objc public override func stopAnimations() {
        tapAnimator?.cancel()
        super.stopAnimations()
    }
    
    
    
    
    // MARK: - Touch handling
    
    private enum TrackingState {
        case tracking(isInside: Bool)
        case notTracking
    }
    private var _trackingTouch: TrackingState = .notTracking
    private var _tapHoldTimer: Timer?
    private var _tapHoldIsFiring = false
    
    
    @objc open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch _trackingTouch {
        case .notTracking:
            _trackingTouch = .tracking(isInside: true)
            tapAnimator?.doTapDownAnimation()
            self.sendActions(for: .touchDown)
            
            // Start tracking for repeat touches if needed
            scheduleTapHold()
        default:
            return
        }
    }
    
    @objc open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else { return }
        switch _trackingTouch {
        case .tracking(let wasInside):
            let isInside = self.point(inside: firstTouch.location(in: self), with: event)
            if isInside && !wasInside {
                tapAnimator?.doTapDownAnimation()
                self.sendActions(for: .touchDragEnter)
            } else if !isInside && wasInside {
                tapAnimator?.doTapUpAnimation()
                self.sendActions(for: .touchDragExit)
            }
            _trackingTouch = .tracking(isInside: isInside)
        default:
            return
        }
        
    }
    
    @objc open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch _trackingTouch {
        case .tracking(let isInside):
            tapAnimator?.doTapUpAnimation()
            if !_tapHoldIsFiring {
                if isInside {
                    self.sendActions(for: .touchUpInside)
                } else {
                    self.sendActions(for: .touchUpOutside)
                }
            }
            clearTapHoldTimer()
            _trackingTouch = .notTracking
        default:
            return
        }
    }
    
    @objc open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        _trackingTouch = .notTracking
        tapAnimator?.doTapUpAnimation()
        self.sendActions(for: .touchCancel)
        clearTapHoldTimer()
    }
    
    @objc open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        // Handle normal case (inside the visible control)
        let actuallyInside = super.point(inside: point, with: event)
        if actuallyInside { return true }
        
        // Account for scale in the point we're given
        let scaleX = self.transform.a
        let scaleY = self.transform.d
        let scaleCompensate = CGAffineTransform(scaleX: scaleX, y: scaleY)
        let transformedPoint = point.applying(scaleCompensate)
        
        // Inflate the bounds to the minimum and see if it's inside
        let minWidth: CGFloat = 44.0
        let minHeight: CGFloat = 44.0
        let extraWidth = max(0, minWidth - self.bounds.size.width)
        let extraHeight = max(0, minHeight - self.bounds.size.height)
        let area = self.bounds.insetBy(dx: -extraWidth/2, dy: -extraHeight/2)
        return area.contains(transformedPoint)
    }
    
    private func clearTapHoldTimer() {
        _tapHoldTimer?.invalidate()
        _tapHoldTimer = nil
        _tapHoldIsFiring = false
    }
    
    private func scheduleTapHold() {
        clearTapHoldTimer()
        switch tapHoldBehaviour {
        case .enabled(let delay, _):
            _tapHoldTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(self.handleInitialTapHold), userInfo: nil, repeats: false)
            _tapHoldTimer?.tolerance = 0.01
        default:
            return
        }
    }
    
    @objc private func handleInitialTapHold() {
        
        // Clear initial delay and fire first repeat event
        clearTapHoldTimer()
        tapHoldFired()
        
        // Start repeating with the intended interval
        switch tapHoldBehaviour {
        case .enabled(_, let interval):
            _tapHoldTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.handleInitialTapHold), userInfo: nil, repeats: true)
            _tapHoldTimer?.tolerance = 0.01
        default:
            return
        }
    }
    
    private func tapHoldFired() {
        _tapHoldIsFiring = true
        self.sendActions(for: .touchUpInside)
    }
}

