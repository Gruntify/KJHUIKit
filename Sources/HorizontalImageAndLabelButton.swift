//
//  HorizontalImageAndLabelButton.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 15/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit
import SnapKit


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
            self.setNeedsUpdateConstraints()
        }
    }

    /**
     The spacing between the image and the label.
     */
    @objc public var imageToLabelSpacing: CGFloat = 0.0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /**
     The vertical offset of the label from a Y-centered position.
     
     Positive numbers move it down, negative moves up.
     */
    @objc public var labelCenterYOffset: CGFloat = 0.0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /**
     The vertical offset of the image from a Y-centered position.
     
     Positive numbers move it down, negative moves up.
     */
    @objc public var imageCenterYOffset: CGFloat = 0.0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /**
     The horizontal offset of the label and image combined, from an X-centered position.
     
     Positive numbers move it to the right, negative to the left.
     */
    @objc public var combinedCenterXOffset: CGFloat = 0.0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /**
     A size to constrain the image view to, independent of the button size.
     
     This is useful if your image is bigger than you expect, but you don't want it to be flush with the edge of the button (or the button has constraints which shouldn't relate to the image).
     */
    public var imageViewConstrainedSize: CGSize? = nil {
        didSet {
            self.setNeedsUpdateConstraints()
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
        label.textAlignment = .center
        self.addSubview(label)
        
        // Setup constraints
        helperSetupConstraints(isRemake: false)
    }
    
    @objc open override func updateConstraints() {
        super.updateConstraints()
        helperSetupConstraints(isRemake: true)
    }
    
    private func helperSetupConstraints(isRemake: Bool) {
        if isRemake {
            _centeringGuide.snp.remakeConstraints { (make) in
                centerConstraintHelper(make)
            }
            imageView.snp.remakeConstraints { (make) in
                imageConstraintHelper(make)
            }
            label.snp.remakeConstraints { (make) in
                labelConstraintHelper(make)
            }
        } else {
            _centeringGuide.snp.makeConstraints { (make) in
                centerConstraintHelper(make)
            }
            imageView.snp.makeConstraints { (make) in
                imageConstraintHelper(make)
            }
            label.snp.makeConstraints { (make) in
                labelConstraintHelper(make)
            }
        }
    }
    
    private func centerConstraintHelper(_ make: ConstraintMaker) {
        make.centerY.equalToSuperview()
        make.centerX.equalToSuperview().offset(combinedCenterXOffset)
    }
    
    private func imageConstraintHelper(_ make: ConstraintMaker) {
        switch arrangement {
        case .imageLeftLabelRight:
            make.leading.equalTo(_centeringGuide)
        case .imageRightLabelLeft:
            make.trailing.equalTo(_centeringGuide)
        }
        make.centerY.equalTo(_centeringGuide).offset(imageCenterYOffset)
        
        // NOTE: The 2x is to ensure that we don't cut off the content despite the offset (the offset is in one direction but view size grows in both at the same time, so it has to be double or it will be clipped).
        if let customWidth = imageViewConstrainedWidth {
            make.width.equalTo(customWidth)
        }
        if let customHeight = imageViewConstrainedHeight {
            make.height.equalTo(customHeight)
        } else {
            make.height.equalTo(_centeringGuide).offset(-2.0 * abs(imageCenterYOffset))
        }
    }
    
    private func labelConstraintHelper(_ make: ConstraintMaker) {
        switch arrangement {
        case .imageLeftLabelRight:
            make.trailing.equalTo(_centeringGuide)
            make.leading.equalTo(imageView.snp.trailing).offset(imageToLabelSpacing)
        case .imageRightLabelLeft:
            make.leading.equalTo(_centeringGuide)
            make.trailing.equalTo(imageView.snp.leading).offset(-imageToLabelSpacing)
        }
        make.centerY.equalTo(_centeringGuide).offset(labelCenterYOffset)
        
        // NOTE: The 2x is to ensure that we don't cut off the content despite the offset (the offset is in one direction but view size grows in both at the same time, so it has to be double or it will be clipped).
        make.height.equalTo(_centeringGuide).offset(-2.0 * abs(labelCenterYOffset))
        
        // NOTE: Width is floating here, so the downside is if the button has a fixed size and the content is too big the label won't be truncating it properly because the centering layout guide's width isn't fixed to anything.
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
