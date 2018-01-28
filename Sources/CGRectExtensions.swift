//
//  CGRectExtensions.swift
//  KJHUIKit-iOS
//
//  Created by Kieran Harper on 28/1/18.
//  Copyright © 2018 Kieran Harper. All rights reserved.
//

import UIKit

public extension CGRect {
    
    public func resizedTo(width: CGFloat?, height: CGFloat?) -> CGRect {
        guard width != nil || height != nil else { return self }
        let insetX: CGFloat
        if let w = width {
            insetX = (self.width - w) / 2.0
        } else {
            insetX = 0.0
        }
        let insetY: CGFloat
        if let h = height {
            insetY = (self.height - h) / 2.0
        } else {
            insetY = 0.0
        }
        return self.insetBy(dx: insetX, dy: insetY)
    }
    
    public func resizedTo(size: CGSize?) -> CGRect {
        guard let s = size else { return self }
        return self.resizedTo(width: s.width, height: s.height)
    }
}
