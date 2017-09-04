//
//  ImageOrLabelButton.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 15/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit
import SnapKit

/** Button that can either be an image or a label.
 
 You can swap the mode on the fly but no animation is provided by default. Subclassing and overriding imageMode property should allow you to customize to your needs.
 */
open class ImageOrLabelButton: Button {

    
    
    // MARK: - Properties
    
    /// Whether or not the button is operating in image mode, where the label will be hidden (via alpha = 0).
    public var imageMode = false {
        didSet {
            if imageMode {
                label.alpha = 0.0
                imageView.alpha = 1.0
            } else {
                label.alpha = 1.0
                imageView.alpha = 0.0
            }
            self.setNeedsUpdateConstraints()
        }
    }
    
    /**
     The image view that is centered inside the button. Alignment is centered by default.
     */
    public let imageView = CrossfadingImageView()
    
    /**
     The label that is centered inside the button. Alignment is centered by default.
     */
    public let label = CrossfadingLabel()
    
    /**
     The horizontal offset of the image from a X-centered position.
     
     Positive numbers move it to the right, negative to the left.
     */
    public var imageOffsetFromCenterX: CGFloat = 0.0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /**
     The vertical offset of the image from a Y-centered position.
     
     Positive numbers move it down, negative moves up.
     */
    public var imageOffsetFromCenterY: CGFloat = 0.0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /**
     The horizontal offset of the label from a X-centered position.
     
     Positive numbers move it to the right, negative to the left.
     */
    public var labelOffsetFromCenterX: CGFloat = 0.0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /**
     The vertical offset of the label from a Y-centered position.
     
     Positive numbers move it down, negative moves up.
     */
    public var labelOffsetFromCenterY: CGFloat = 0.0 {
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
        self.setupImageOrLabelButton()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupImageOrLabelButton()
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    private func setupImageOrLabelButton() {
        
        imageMode = false
        
        // Setup the image view
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        
        // Setup the label
        label.textAlignment = .center
        self.addSubview(label)
        
        // Setup constraints
        helperSetupConstraints(isRemake: false)
    }
    
    open override func updateConstraints() {
        super.updateConstraints()
        helperSetupConstraints(isRemake: true)
    }
    
    private func helperSetupConstraints(isRemake: Bool) {
        
        if isRemake {
            imageView.snp.removeConstraints()
            label.snp.removeConstraints()
        }
        if imageMode {
            imageView.snp.makeConstraints { (make) in
                imageConstraintHelper(make)
            }
        } else {
            label.snp.makeConstraints { (make) in
                labelConstraintHelper(make)
            }
        }
    }
    
    private func imageConstraintHelper(_ make: ConstraintMaker) {
        make.centerX.equalToSuperview().offset(imageOffsetFromCenterX)
        make.centerY.equalToSuperview().offset(imageOffsetFromCenterY)
        
        // NOTE: The 2x is to ensure that we don't cut off the content despite the offset (the offset is in one direction but view size grows in both at the same time, so it has to be double or it will be clipped).
        if let customWidth = imageViewConstrainedWidth {
            make.width.equalTo(customWidth)
        } else {
            make.width.equalToSuperview().offset(-2.0 * abs(imageOffsetFromCenterX))
        }
        if let customHeight = imageViewConstrainedHeight {
            make.height.equalTo(customHeight)
        } else {
            make.height.equalToSuperview().offset(-2.0 * abs(imageOffsetFromCenterY))
        }
    }
    
    private func labelConstraintHelper(_ make: ConstraintMaker) {
        make.centerX.equalToSuperview().offset(labelOffsetFromCenterX)
        make.centerY.equalToSuperview().offset(labelOffsetFromCenterY)
        
        // NOTE: The 2x is to ensure that we don't cut off the content despite the offset (the offset is in one direction but view size grows in both at the same time, so it has to be double or it will be clipped).
        make.width.equalToSuperview().offset(-2.0 * abs(labelOffsetFromCenterX))
        make.height.equalToSuperview().offset(-2.0 * abs(labelOffsetFromCenterY))
    }
    
    open override var intrinsicContentSize: CGSize {
        if imageMode {
            let intrinsicWidth = imageViewConstrainedWidth ?? imageView.intrinsicContentSize.width
            let intrinsicHeight = imageViewConstrainedHeight ?? imageView.intrinsicContentSize.height
            let widthAccountingForOffset = intrinsicWidth + 2.0 * abs(imageOffsetFromCenterX)
            let heightAccountingForOffset = intrinsicHeight + 2.0 * abs(imageOffsetFromCenterY)
            return CGSize(width: widthAccountingForOffset, height: heightAccountingForOffset)
        } else {
            let intrinsicSize = label.intrinsicContentSize
            let widthAccountingForOffset = intrinsicSize.width + 2.0 * abs(labelOffsetFromCenterX)
            let heightAccountingForOffset = intrinsicSize.height + 2.0 * abs(labelOffsetFromCenterY)
            return CGSize(width: widthAccountingForOffset, height: heightAccountingForOffset)
        }
    }
}
