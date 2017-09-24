//
//  CrossfadingImageView.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 1/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit

/// Simple crossfading UIImageView subclass.
@objc open class CrossfadingImageView: UIImageView {

    /// The duration to perform the crossfade over.
    @objc open var crossfadeDuration: TimeInterval = 0.25
    
    /// Master switch to disable crossfade, which is useful in situations where the code setting the image isn't aware of some other condition, or when you'd like to temporarily make it instant but can't store the current duration and apply it later.
    @objc open var disableCrossfade = false

    /// Set the image, with or without crossfading.
    @objc open func setImage(_ image: UIImage?, crossfading: Bool, completion: ((Bool) -> Void)? = nil) {
        if crossfading, !disableCrossfade, crossfadeDuration > 0.0 {
            UIView.transition(with: self, duration: crossfadeDuration, options: .transitionCrossDissolve, animations: {
                super.image = image
            }, completion: completion)
        } else {
            super.image = image
        }
    }
}
