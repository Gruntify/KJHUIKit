//
//  VerticalImageAndLabelButton.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 12/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit
import SnapKit


/// Button that contains an image and a label vertically stacked, with the choice of which one is on top.
@objc open class VerticalImageAndLabelButton: Button {
    
    
    
    // MARK: - Types
    
    /// Arrangement options - the button has 2 elements where one is on top and the other is below it.
    public enum ImageAndLabelArrangement {
        case imageTopLabelBottom
        case imageBottomLabelTop
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
    public var arrangement: ImageAndLabelArrangement = .imageTopLabelBottom {
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
     The horizontal offset of the label from a X-centered position.
     
     Positive numbers move it to the right, negative to the left.
     */
    @objc public var labelCenterXOffset: CGFloat = 0.0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /**
     The horizontal offset of the image from a X-centered position.
     
     Positive numbers move it to the right, negative to the left.
     */
    @objc public var imageCenterXOffset: CGFloat = 0.0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /**
     The vertical offset of the label and image combined, from a Y-centered position.
     
     Positive numbers move it down, negative moves up.
     */
    @objc public var combinedCenterYOffset: CGFloat = 0.0 {
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
        self.setupVerticalImageAndLabelButton()
    }
    
    @objc public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupVerticalImageAndLabelButton()
    }
    
    @objc public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    private func setupVerticalImageAndLabelButton() {
        
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
        make.centerX.equalToSuperview()
        make.centerY.equalToSuperview().offset(combinedCenterYOffset)
    }
    
    private func imageConstraintHelper(_ make: ConstraintMaker) {
        switch arrangement {
        case .imageTopLabelBottom:
            make.top.equalTo(_centeringGuide)
        case .imageBottomLabelTop:
            make.bottom.equalTo(_centeringGuide)
        }
        make.centerX.equalTo(_centeringGuide).offset(imageCenterXOffset)
        
        // NOTE: The 2x is to ensure that we don't cut off the content despite the offset (the offset is in one direction but view size grows in both at the same time, so it has to be double or it will be clipped).
        if let customWidth = imageViewConstrainedWidth {
            make.width.equalTo(customWidth)
        } else {
            make.width.equalTo(_centeringGuide).offset(-2.0 * abs(imageCenterXOffset))
        }
        if let customHeight = imageViewConstrainedHeight {
            make.height.equalTo(customHeight)
        }
    }
    
    private func labelConstraintHelper(_ make: ConstraintMaker) {
        switch arrangement {
        case .imageTopLabelBottom:
            make.bottom.equalTo(_centeringGuide)
            make.top.equalTo(imageView.snp.bottom).offset(imageToLabelSpacing)
        case .imageBottomLabelTop:
            make.top.equalTo(_centeringGuide)
            make.bottom.equalTo(imageView.snp.top).offset(-imageToLabelSpacing)
        }
        make.centerX.equalTo(_centeringGuide).offset(labelCenterXOffset)
        
        // NOTE: The 2x is to ensure that we don't cut off the content despite the offset (the offset is in one direction but view size grows in both at the same time, so it has to be double or it will be clipped).
        make.width.equalTo(_centeringGuide).offset(-2.0 * abs(labelCenterXOffset))
    }
    
    @objc open override var intrinsicContentSize: CGSize {
        let imageIntrinsicWidth = imageViewConstrainedWidth ?? imageView.intrinsicContentSize.width
        let imageIntrinsicHeight = imageViewConstrainedHeight ?? imageView.intrinsicContentSize.height
        let imageWidthAccountingForOffset = imageIntrinsicWidth + 2.0 * abs(imageCenterXOffset)
        
        let labelIntrinsicSize = label.intrinsicContentSize
        let labelWidthAccountingForOffset = labelIntrinsicSize.width + 2.0 * abs(labelCenterXOffset)
        
        let width = imageWidthAccountingForOffset > labelWidthAccountingForOffset ? imageWidthAccountingForOffset : labelWidthAccountingForOffset
        let height = imageIntrinsicHeight + labelIntrinsicSize.height + imageToLabelSpacing + 2.0 * abs(combinedCenterYOffset)
        return CGSize(width: width, height: height)
    }
}
