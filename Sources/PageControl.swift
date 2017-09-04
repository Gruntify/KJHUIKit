//
//  PageControl.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 1/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit

public protocol PageControlDelegate: class {
    
    /// The page change event, triggered when tracking detects that scrolling has brought the new page more than 50% of the way into the scroll view.
    func didChange(fromPage oldPage: Int, toPage newPage: Int)
}


/// Simple UIPageControl subclass that encapsulates common logic about tracking page changes and hiding itself when there's no reason for it to be shown.
public class PageControl: UIPageControl {

    /// Object to be notified when the current page changes.
    public weak var delegate: PageControlDelegate?
    
    /// The scroll view whose page is being tracked.
    public var scrollViewToTrack: UIScrollView?

    /// Whether or not the page control should make itself hidden when there's only one page (or zero).
    public var hidesWhenNotNeeded = true {
        didSet {
            showHideSelfIfNeeded()
        }
    }
    
    /// Adjust for the scroll view's current number of pages. Will affect the hidden state as needed.
    public func updateNumberOfPages() {
        guard let scrollView = scrollViewToTrack else {
            self.numberOfPages = 0
            return
        }
        
        // Calculate the number of pages
        self.numberOfPages = Int(ceil(scrollView.contentSize.width / scrollView.bounds.size.width))
        showHideSelfIfNeeded()
    }
    
    /// Detect page changes based on the current scroll position of the scroll view.
    public func trackCurrentPage() {
        
        // Track page movement purely to update the page dots if applicable
        guard let scrollView = scrollViewToTrack else { return }
        let offsetPercentage = max(0, scrollView.contentOffset.x) / scrollView.contentSize.width
        let newPage = Int(round(offsetPercentage * CGFloat(numberOfPages)))
        if newPage != self.currentPage {
            let oldPage = self.currentPage
            self.currentPage = newPage
            delegate?.didChange(fromPage: oldPage, toPage: newPage)
        }
    }
    
    private func showHideSelfIfNeeded() {
        self.isHidden = hidesWhenNotNeeded && self.numberOfPages <= 1
    }
}
