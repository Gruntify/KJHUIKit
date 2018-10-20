//
//  ImageButton.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 1/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit

/// Simple image view only button
@objc open class ImageButton: Button {
    
    
    // MARK: - Properties
    
    /**
     The image view that is centered inside the button. Alignment is centered by default.
     */
    @objc public let imageView = CrossfadingImageView()
    
    /**
     The horizontal offset of the image from a X-centered position.
     
     Positive numbers move it to the right, negative to the left.
     */
    @objc public var offsetFromCenterX: CGFloat = 0.0 {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /**
     The vertical offset of the image from a Y-centered position.
     
     Positive numbers move it down, negative moves up.
     */
    @objc public var offsetFromCenterY: CGFloat = 0.0 {
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
        self.setupImageButton()
    }
    
    @objc public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupImageButton()
    }
    
    @objc public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    private func setupImageButton() {
        
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        
        addSubview(imageView)
        helperSetImageViewFrame()
    }
    
    @objc open override func layoutSubviews() {
        super.layoutSubviews()
        helperSetImageViewFrame()
    }
    
    private func helperSetImageViewFrame() {
        imageView.frame = self.bounds.offsetBy(dx: offsetFromCenterX, dy: offsetFromCenterY).resizedTo(width: imageViewConstrainedWidth, height: imageViewConstrainedHeight)
    }
    
    @objc open override var intrinsicContentSize: CGSize {
        let intrinsicWidth = imageViewConstrainedWidth ?? imageView.intrinsicContentSize.width
        let intrinsicHeight = imageViewConstrainedHeight ?? imageView.intrinsicContentSize.height
        let widthAccountingForOffset = intrinsicWidth + 2.0 * abs(offsetFromCenterX)
        let heightAccountingForOffset = intrinsicHeight + 2.0 * abs(offsetFromCenterY)
        return CGSize(width: widthAccountingForOffset, height: heightAccountingForOffset)
    }
}
