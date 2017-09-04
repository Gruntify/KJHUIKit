//
//  TapDownGestureRecognizer.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 2/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

public class TapDownGestureRecognizer: UIGestureRecognizer {

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.state == .possible {
            self.state = .recognized
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .failed
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .failed
    }
}
