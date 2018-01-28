//
//  HorizontalImageAndLabelButton.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 15/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit


/// Button that contains an image and a label horizontally beside each other, with the choice of which one is on which side.
@objc open class HorizontalImageAndLabelButton: Button {
    
    
    
    // MARK: - Types
    
    /// Arrangement options - the button has 2 elements where one is on the left and the other is on the right.
    public enum ImageAndLabelArrangement {
        case imageLeftLabelRight
        case imageRightLabelLeft
    }
    
    
    
    // MARK: - Properties
    
    /**
     The label part of the button.
     */
    @objc public let label = CrossfadingLabel()
    
    /**
     The image view part of the button.
     */
    @objc public let imageView = CrossfadingImageView()
    
    /**
     The layout style / ordering of the elements.
     */
    public var arrangement: ImageAndLabelArrangement = .imageLeftLabelRight {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /**
     The spacing between the image and the label.
     */
    @objc public var imageToLabelSpacing: CGFloat = 0.0 {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /**
     The vertical offset of the label from a Y-centered position.
     
     Positive numbers move it down, negative moves up.
     */
    @objc public var labelCenterYOffset: CGFloat = 0.0 {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /**
     The vertical offset of the image from a Y-centered position.
     
     Positive numbers move it down, negative moves up.
     */
    @objc public var imageCenterYOffset: CGFloat = 0.0 {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /**
     The horizontal offset of the label and image combined, from an X-centered position.
     
     Positive numbers move it to the right, negative to the left.
     */
    @objc public var combinedCenterXOffset: CGFloat = 0.0 {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /**
     A size to constrain the image view to, independent of the button size.
     
     This is useful if your image is bigger than you expect, but you don't want it to be flush with the edge of the button (or the button has constraints which shouldn't relate to the image).
     */
    public var imageViewConstrainedSize: CGSize? = nil {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    
    
    // MARK: - Private variables
    
    private var _centeringGuide = UILayoutGuide()
    
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
    
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupHorizontalImageAndLabelButton()
    }
    
    @objc public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupHorizontalImageAndLabelButton()
    }
    
    @objc public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    private func setupHorizontalImageAndLabelButton() {
        
        // Setup the centering layout guide
        self.addLayoutGuide(_centeringGuide)
        
        // Setup the image view
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        
        // Setup the label
        label.textAlignment = .left
        self.addSubview(label)
        
        helperSetFrames()
    }
    
    @objc open override func layoutSubviews() {
        super.layoutSubviews()
        helperSetFrames()
    }
    
    private func helperSetFrames() {
        var imageRect: CGRect
        var labelRect: CGRect
        let labelIntrinsic = label.intrinsicContentSize
        let imageIntrinsic = imageView.intrinsicContentSize
        
        // Determine the size that things want to be
        let imageWidth: CGFloat
        let imageHeight: CGFloat
        if let custom = imageViewConstrainedWidth {
            imageWidth = custom
        } else {
            imageWidth = imageIntrinsic.width
        }
        if let custom = imageViewConstrainedHeight {
            imageHeight = custom
        } else {
            imageHeight = imageIntrinsic.height
        }
        var labelWidth = labelIntrinsic.width // var so it can truncate if too big
        let labelHeight = labelIntrinsic.height
        
        // Determine where the items sit vertically
        let mid = self.bounds.height / 2.0
        let labelY = mid + labelCenterYOffset - labelHeight / 2.0
        let imageY = mid + imageCenterYOffset - imageHeight / 2.0
        let rightEdge: CGFloat
        
        // Do the main positioning
        // NOTE: during imperfect scenarios the image is favouring being the natural size or the requested size rather than fitting into the current frame, choosing to avoid aspect problems. Label is the reverse, opting to use the available space so it benefits from truncation.
        switch arrangement {
        case .imageLeftLabelRight:
            imageRect = CGRect(x: combinedCenterXOffset, y: imageY, width: imageWidth, height: imageHeight)
            let labelX = combinedCenterXOffset + imageRect.width + imageToLabelSpacing
            let remainingSpace = max(0, self.bounds.width - labelX)
            labelWidth = (labelIntrinsic.width < remainingSpace) ? labelIntrinsic.width : remainingSpace
            labelRect = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
            rightEdge = labelRect.origin.x + labelRect.width
        case .imageRightLabelLeft:
            labelRect = CGRect(x: combinedCenterXOffset, y: labelY, width: labelWidth, height: labelHeight)
            let imageX = combinedCenterXOffset + labelRect.width + imageToLabelSpacing
            imageRect = CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
            rightEdge = imageRect.origin.x + imageRect.width
        }
        
        // Adjust horizontally if needed when there's excess space
        let excessDiv2 = max(0, (self.bounds.width - rightEdge) / 2.0)
        labelRect.origin.x += excessDiv2
        imageRect.origin.x += excessDiv2
        
        label.frame = labelRect
        imageView.frame = imageRect
    }
    
    @objc open override var intrinsicContentSize: CGSize {
        let imageIntrinsicWidth = imageViewConstrainedWidth ?? imageView.intrinsicContentSize.width
        let imageIntrinsicHeight = imageViewConstrainedHeight ?? imageView.intrinsicContentSize.height
        let imageHeightAccountingForOffset = imageIntrinsicHeight + 2.0 * abs(imageCenterYOffset)
        
        let labelIntrinsicSize = label.intrinsicContentSize
        let labelHeightAccountingForOffset = labelIntrinsicSize.height + 2.0 * abs(labelCenterYOffset)
        
        let height = imageHeightAccountingForOffset > labelHeightAccountingForOffset ? imageHeightAccountingForOffset : labelHeightAccountingForOffset
        let width = imageIntrinsicWidth + labelIntrinsicSize.width + imageToLabelSpacing + 2.0 * abs(combinedCenterXOffset)
        return CGSize(width: width, height: height)
    }
}
