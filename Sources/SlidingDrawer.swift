//
//  SlidingDrawer.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 3/9/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit

/** View that can be shown/hidden in a drawer fashion.
 
 Here are the steps to using this:
 1. Decide on the direction it should move.
 2. Decide how much room you want in your drawer (via the size parameter).
 3. Constrain the drawer in your canvas like you normally would, except do not define the size/pin along the direction it needs to move. Eg if using fromBottom, do not give it a height or a top constraint. This is because opening and closing depends upon intrinsicContentSize.
 4. Add the contents of the drawer to the contentView.
 5. Expect the contentView's size to be 1.5x the size parameter. The reason for that is to allow overflow room for the show animation in case you want to use a spring curve. If this wasn't the case, you'd see gaps at the bottom when showing fromBottom at the moment where it overshoots/bounces. Adjust your content's constraints accordingly.
 */
open class SlidingDrawer: UIView, ShowHideable {

    /// The directional options for which way a sliding drawer is going to show. The opposite occurs when hiding.
    public enum ShowDirection {
        case fromTop
        case fromBottom
        case fromLeft
        case fromRight
    }
    
    /// View which is inside the drawer - this is where your content needs to be added.
    public private(set) var contentView: UIView!
    
    /// The direction that the drawer will move when showing. The reverse plays out when it hides.
    public var direction: ShowDirection = .fromBottom {
        didSet {
            setupDrawerConstraints()
        }
    }
    
    /// Size to use for the drawer's height or width. Expect the contentView's size to be 1.5x this value for animation overshoot reasons.
    public var size: CGFloat = 44.0 {
        didSet {
            setupDrawerConstraints()
        }
    }
    
    /// Animation curve to use when opening the drawer.
    public var showCurve: AnimationCurve = .spring(damping: 0.5, initialVelocity: 0.0, duration: 0.5, additive: true)
    
    /// Animation curve to use when closing the drawer.
    public var hideCurve: AnimationCurve = .spring(damping: 0.7, initialVelocity: 0.0, duration: 0.35, additive: true)
    
    
    
    // MARK: - Lifecycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSlidingDrawer()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupSlidingDrawer()
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    private func setupSlidingDrawer() {
        
        // Setup the content view
        contentView = UIView()
        self.addSubview(contentView)
        self.backgroundColor = UIColor.white
        self.clipsToBounds = true
        setupDrawerConstraints()
        
        // Show by default
        show(animate: false)
    }
    
    open override var intrinsicContentSize: CGSize {
        switch direction {
        case .fromBottom, .fromTop:
            if isShowing {
                return CGSize(width: UIViewNoIntrinsicMetric, height: size)
            } else {
                return CGSize(width: UIViewNoIntrinsicMetric, height: 0.0)
            }
            
        case .fromLeft, .fromRight:
            if isShowing {
                return CGSize(width: size, height: UIViewNoIntrinsicMetric)
            } else {
                return CGSize(width: 0.0, height: UIViewNoIntrinsicMetric)
            }
        }
    }
    
    
    
    // MARK: - ShowHideable
    
    public private(set) var isShowing: Bool = true
    
    public func show(animate: Bool, alongside: (() -> ())? = nil, completion: (() -> ())? = nil) {
        
        // Define animation work
        isShowing = true
        let animation: ViewAnimation = { (target) in
            target.invalidateIntrinsicContentSize()
            target.superview?.layoutIfNeeded()
            alongside?()
        }
        
        // Run it with or without animation
        if animate {
            let config = AnimationConfig(curve: showCurve, animations: animation)
            self.runAnimation(config, delay: 0.0) { _ in
                completion?()
            }
        } else {
            animation(self)
            completion?()
        }
    }
    
    public func hide(animate: Bool, alongside: (() -> ())? = nil, completion: (() -> ())? = nil) {
        
        // Define animation work
        isShowing = false
        let animation: ViewAnimation = { (target) in
            target.invalidateIntrinsicContentSize()
            target.superview?.layoutIfNeeded()
            alongside?()
        }
        
        // Run it with or without animation
        if animate {
            let config = AnimationConfig(curve: hideCurve, animations: animation)
            self.runAnimation(config, delay: 0.0) { _ in
                completion?()
            }
        } else {
            animation(self)
            completion?()
        }
    }
    
    
    
    // MARK: - Private methods
    
    private func setupDrawerConstraints() {
        let bounceLeeway: CGFloat = 1.5
        let sizeWithLeeway = bounceLeeway * size
        contentView.snp.remakeConstraints { (make) in
            switch direction {
            case .fromBottom:
                make.leading.trailing.top.equalToSuperview()
                make.height.equalTo(sizeWithLeeway)
            case .fromTop:
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalTo(sizeWithLeeway)
            case .fromLeft:
                make.trailing.top.bottom.equalToSuperview()
                make.width.equalTo(sizeWithLeeway)
            case .fromRight:
                make.leading.top.bottom.equalToSuperview()
                make.width.equalTo(sizeWithLeeway)
            }
        }
        self.invalidateIntrinsicContentSize()
    }
}
