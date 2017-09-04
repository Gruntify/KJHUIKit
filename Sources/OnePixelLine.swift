//
//  OnePixelLine.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 1/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit

public func onePixelInPoints() -> CGFloat {
    return 1.0 / UIScreen.main.scale
}

@IBDesignable
open class OnePixelLine: UIView {

    // MARK: - Lifecycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupOnePixelLine()
        
        // Default to white (when not from xib)
        backgroundColor = UIColor.white
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupOnePixelLine()
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    private func setupOnePixelLine() {
        
        // Hugging priority set high will prevent the line from being pulled into a thicker size because of its relationship to other views
        setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
    }

    open override var intrinsicContentSize: CGSize {
        let points = onePixelInPoints()
        return CGSize(width: points, height: points)
    }
}
