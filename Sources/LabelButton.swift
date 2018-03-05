//
//  LabelButton.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 2/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit

/// Simple label only button
@objc open class LabelButton: Button {
    
    
    // MARK: - Properties
    
    /**
     The label that is centered inside the button. Alignment is centered by default.
     */
    @objc public let label = CrossfadingLabel()
    
    /**
     The horizontal offset of the label from a X-centered position.
     
     Positive numbers move it to the right, negative to the left.
     */
    @objc public var offsetFromCenterX: CGFloat = 0.0 {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /**
     The vertical offset of the label from a Y-centered position.
     
     Positive numbers move it down, negative moves up.
     */
    @objc public var offsetFromCenterY: CGFloat = 0.0 {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    
    
    
    // MARK: - Lifecycle
    
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLabelButton()
    }
    
    @objc public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupLabelButton()
    }
    
    @objc public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    private func setupLabelButton() {
        
        label.textAlignment = .center
        
        addSubview(label)
        helperSetLabelFrame()
    }
    
    @objc open override func layoutSubviews() {
        super.layoutSubviews()
        helperSetLabelFrame()
    }
    
    private func helperSetLabelFrame() {
        let size = label.intrinsicContentSize
        let width = min(size.width, self.bounds.width)
        let height = min(size.height, self.bounds.height)
        let newFrame = self.bounds.resizedTo(width: width, height: height)
        label.frame = newFrame.offsetBy(dx: offsetFromCenterX, dy: offsetFromCenterY)
    }
    
    @objc open override var intrinsicContentSize: CGSize {
        let intrinsicSize = label.intrinsicContentSize
        let widthAccountingForOffset = intrinsicSize.width + 2.0 * abs(offsetFromCenterX)
        let heightAccountingForOffset = intrinsicSize.height + 2.0 * abs(offsetFromCenterY)
        return CGSize(width: widthAccountingForOffset, height: heightAccountingForOffset)
    }
}
