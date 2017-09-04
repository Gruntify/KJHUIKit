//
//  CircleView.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 1/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit

@IBDesignable
open class CircleView: UIView {
    
    
    // MARK: - Properties
    
    /// The colour to use when drawing the circle.
    open var colourToUse = UIColor.white {
        didSet  {
            self.setNeedsDisplay()
        }
    }
    
    

    // MARK: - Lifecycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Draw a circle as big as our view
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(colourToUse.cgColor)
        context.fillEllipse(in: rect)
    }
}
