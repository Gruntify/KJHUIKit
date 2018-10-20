//
//  ImageOrLabelButton.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 15/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit

/** Button that can either be an image or a label.
 
 You can swap the mode on the fly but no animation is provided by default. Subclassing and overriding imageMode property should allow you to customize to your needs.
 */
@objc open class ImageOrLabelButton: Button {
    
    
    
    // MARK: - Properties
    
    /// Whether or not the button is operating in image mode, where the label will be hidden (via alpha = 0).
    @objc public var imageMode = false {
        didSet {
            if imageMode {
                label.alpha = 0.0
                imageView.alpha = 1.0
            } else {
                label.alpha = 1.0
                imageView.alpha = 0.0
            }
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /**
     The image view that is centered inside the button. Alignment is centered by default.
     */
    @objc public let imageView = CrossfadingImageView()
    
    /**
     The label that is centered inside the button. Alignment is centered by default.
     */
    @objc public let label = CrossfadingLabel()
    
    /**
     The horizontal offset of the image from a X-centered position.
     
     Positive numbers move it to the right, negative to the left.
     */
    @objc public var imageOffsetFromCenterX: CGFloat = 0.0 {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /**
     The vertical offset of the image from a Y-centered position.
     
     Positive numbers move it down, negative moves up.
     */
    @objc public var imageOffsetFromCenterY: CGFloat = 0.0 {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /**
     The horizontal offset of the label from a X-centered position.
     
     Positive numbers move it to the right, negative to the left.
     */
    @objc public var labelOffsetFromCenterX: CGFloat = 0.0 {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /**
     The vertical offset of the label from a Y-centered position.
     
     Positive numbers move it down, negative moves up.
     */
    @objc public var labelOffsetFromCenterY: CGFloat = 0.0 {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /**
     A size to constrain the image view to, independent of the button size.
     
     This is useful if your image is bigger than you expect, but you don't want it to be flush with the size of the button (or the button has constraints which shouldn't relate to the image).
     */
    public var imageViewConstrainedSize: CGSize? = nil {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    
    
    // MARK: - Private variables
    
    private var imageViewConstrainedWidth: CGFloat? {
        if let width = imageViewConstrainedSize?.width, width != UIView.noIntrinsicMetric {
            return width
        } else {
            return nil
        }
    }
    
    private var imageViewConstrainedHeight: CGFloat? {
        if let height = imageViewConstrainedSize?.height, height != UIView.noIntrinsicMetric {
            return height
        } else {
            return nil
        }
    }
    
    
    
    
    // MARK: - Lifecycle
    
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupImageOrLabelButton()
    }
    
    @objc public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupImageOrLabelButton()
    }
    
    @objc public convenience init() {
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
        
        helperSetFrames()
    }
    
    @objc open override func layoutSubviews() {
        super.layoutSubviews()
        helperSetFrames()
    }
    
    private func helperSetFrames() {
        label.frame = self.bounds.offsetBy(dx: labelOffsetFromCenterX, dy: labelOffsetFromCenterY)
        imageView.frame = self.bounds.offsetBy(dx: imageOffsetFromCenterX, dy: imageOffsetFromCenterY).resizedTo(width: imageViewConstrainedWidth, height: imageViewConstrainedHeight)
    }
    
    @objc open override var intrinsicContentSize: CGSize {
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
