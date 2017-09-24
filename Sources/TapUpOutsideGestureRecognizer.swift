//
//  TapUpOutsideGestureRecognizer.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 2/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit

@objc public class TapUpOutsideGestureRecognizer: UIGestureRecognizer {
    
    @objc public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if let v = self.view, let touch = touches.first {
            let loc = touch.location(in: v)
            let hit = v.point(inside: loc, with: event)
            if !hit {
                self.state = .recognized
            }
        }
    }
}
