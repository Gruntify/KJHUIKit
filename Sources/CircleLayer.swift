//
//  CircleLayer.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 16/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit

open class CircleLayer: CALayer {
    
    
    // MARK: - Properties
    
    /// The colour to use when drawing the circle.
    open var colourToUse = UIColor.white {
        didSet  {
            self.setNeedsDisplay()
        }
    }
    
    
    
    // MARK: - Lifecycle
    
    public override init() {
        super.init()
        setupCircleLayer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCircleLayer()
    }
    
    private func setupCircleLayer() {
        self.contentsScale = UIScreen.main.scale
        self.setNeedsDisplay()
    }
    
    open override func draw(in ctx: CGContext) {
        ctx.setFillColor(self.colourToUse.cgColor)
        ctx.fillEllipse(in: self.bounds)
    }
}
