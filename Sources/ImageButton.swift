//
//  ImageButton.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 1/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit
import SnapKit

/// Simple image view only button
open class ImageButton: Button {
    
    
    // MARK: - Properties
    
    /**
     The image view that is centered inside the button. Alignment is centered by default.
     */
    public let imageView = CrossfadingImageView()
    
    /**
     The horizontal offset of the image from a X-centered position.
     
     Positive numbers move it to the right, negative to the left.
     */
    public var offsetFromCenterX: CGFloat = 0.0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /**
     The vertical offset of the image from a Y-centered position.
     
     Positive numbers move it down, negative moves up.
     */
    public var offsetFromCenterY: CGFloat = 0.0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /** 
     A size to constrain the image view to, independent of the button size.
 
     This is useful if your image is bigger than you expect, but you don't want it to be flush with the size of the button (or the button has constraints which shouldn't relate to the image).
     */
    public var imageViewConstrainedSize: CGSize? = nil {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    
    
    // MARK: - Private variables
    
    private var imageViewConstrainedWidth: CGFloat? {
        if let width = imageViewConstrainedSize?.width, width != UIViewNoIntrinsicMetric {
            return width
        } else {
            return nil
        }
    }
    
    private var imageViewConstrainedHeight: CGFloat? {
        if let height = imageViewConstrainedSize?.height, height != UIViewNoIntrinsicMetric {
            return height
        } else {
            return nil
        }
    }
    
    
    
    // MARK: - Lifecycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupImageButton()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupImageButton()
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    private func setupImageButton() {
        
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        
        addSubview(imageView)
        helperSetupConstraints(isRemake: false)
    }
    
    open override func updateConstraints() {
        super.updateConstraints()
        helperSetupConstraints(isRemake: true)
    }
    
    private func helperSetupConstraints(isRemake: Bool) {
        if isRemake {
            imageView.snp.remakeConstraints { (make) in
                constraintHelper(make)
            }
        } else {
            imageView.snp.makeConstraints { (make) in
                constraintHelper(make)
            }
        }
    }
    
    private func constraintHelper(_ make: ConstraintMaker) {
        make.centerX.equalToSuperview().offset(offsetFromCenterX)
        make.centerY.equalToSuperview().offset(offsetFromCenterY)
        
        // NOTE: The 2x is to ensure that we don't cut off the content despite the offset (the offset is in one direction but view size grows in both at the same time, so it has to be double or it will be clipped).
        if let customWidth = imageViewConstrainedWidth {
            make.width.equalTo(customWidth)
        } else {
            make.width.equalToSuperview().offset(-2.0 * abs(offsetFromCenterX))
        }
        if let customHeight = imageViewConstrainedHeight {
            make.height.equalTo(customHeight)
        } else {
            make.height.equalToSuperview().offset(-2.0 * abs(offsetFromCenterY))
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        let intrinsicWidth = imageViewConstrainedWidth ?? imageView.intrinsicContentSize.width
        let intrinsicHeight = imageViewConstrainedHeight ?? imageView.intrinsicContentSize.height
        let widthAccountingForOffset = intrinsicWidth + 2.0 * abs(offsetFromCenterX)
        let heightAccountingForOffset = intrinsicHeight + 2.0 * abs(offsetFromCenterY)
        return CGSize(width: widthAccountingForOffset, height: heightAccountingForOffset)
    }
}
