//
//  LabelButton.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 2/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit
import SnapKit

/// Simple label only button
open class LabelButton: Button {
    
    
    // MARK: - Properties

    /**
     The label that is centered inside the button. Alignment is centered by default.
     */
    public let label = CrossfadingLabel()
    
    /**
     The horizontal offset of the label from a X-centered position.
     
     Positive numbers move it to the right, negative to the left.
     */
    public var offsetFromCenterX: CGFloat = 0.0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /**
     The vertical offset of the label from a Y-centered position.
     
     Positive numbers move it down, negative moves up.
     */
    public var offsetFromCenterY: CGFloat = 0.0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    
    
    
    // MARK: - Lifecycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLabelButton()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupLabelButton()
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    private func setupLabelButton() {
        
        label.textAlignment = .center
        
        addSubview(label)
        helperSetupConstraints(isRemake: false)
    }
    
    open override func updateConstraints() {
        super.updateConstraints()
        helperSetupConstraints(isRemake: true)
    }
    
    private func helperSetupConstraints(isRemake: Bool) {
        if isRemake {
            label.snp.remakeConstraints { (make) in
                constraintHelper(make)
            }
        } else {
            label.snp.makeConstraints { (make) in
                constraintHelper(make)
            }
        }
    }
    
    private func constraintHelper(_ make: ConstraintMaker) {
        make.centerX.equalToSuperview().offset(offsetFromCenterX)
        make.centerY.equalToSuperview().offset(offsetFromCenterY)
        
        // NOTE: The 2x is to ensure that we don't cut off the content despite the offset (the offset is in one direction but view size grows in both at the same time, so it has to be double or it will be clipped).
        make.height.equalToSuperview().offset(-2.0 * abs(offsetFromCenterY))
        
        // NOTE: Width is floating here, so the downside is if the button has a fixed size and the content is too big the label won't be truncating it properly
    }
    
    open override var intrinsicContentSize: CGSize {
        let intrinsicSize = label.intrinsicContentSize
        let widthAccountingForOffset = intrinsicSize.width + 2.0 * abs(offsetFromCenterX)
        let heightAccountingForOffset = intrinsicSize.height + 2.0 * abs(offsetFromCenterY)
        return CGSize(width: widthAccountingForOffset, height: heightAccountingForOffset)
    }
}
