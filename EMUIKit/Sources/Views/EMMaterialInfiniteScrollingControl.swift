//
//  MaterialInfiniteScrollingControl.swift
//  AskApp
//
//  Created by Tam Nguyen on 8/7/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//
#if canImport(UIKit)

import UIKit

public class EMMaterialInfiniteScrollingControl: UIControl {

    struct Constants {
        static let defaultHeight: CGFloat = 60
    }

    // MARK: Properties

    private var originalBottomInset: CGFloat = 0

    private var loadingView: EMMaterialIndicatorView?

    public var isLoading: Bool = false
    public var canLoading: Bool = true

    public var color: UIColor? {
        didSet {
            if let color = color {
                loadingView?.color = color
            }
        }
    }

    // MARK: Override methods

    public override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: Constants.defaultHeight))

        // Should call setupInfiniteScrolling methods
        self.setupInfiniteScrolling()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        let scrollView = self.superview as? UIScrollView

        if scrollView != nil {
            // remove observer
            scrollView!.removeObserver(self, forKeyPath: "contentOffset", context: nil)
            scrollView!.removeObserver(self, forKeyPath: "contentSize", context: nil)
        }
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()

        let scrollView = self.superview as? UIScrollView

        if scrollView != nil {
            self.originalBottomInset = scrollView!.contentInset.bottom

            // Track content offset changed event
            scrollView!.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)

            scrollView!.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        if self.loadingView != nil {
            self.loadingView!.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        }
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            let scrollView = object as? UIScrollView
            let newPoint = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgPointValue

            if scrollView != nil && newPoint != nil {
                if (newPoint!.y + scrollView!.bounds.size.height) >= scrollView!.contentSize.height && scrollView!.contentSize.height > scrollView!.bounds.size.height {

                    beginLoading()
                }
            }
        } else if keyPath == "contentSize" {
            let newSize = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgSizeValue

            if newSize != nil {
                self.frame = CGRect(x: 0, y: newSize!.height, width: self.frame.width, height: self.frame.height)
            }
        }
    }

    // MARK: Private methods

    private func setupInfiniteScrolling() {
        self.backgroundColor = UIColor.clear
        self.isHidden = true

        // Init indicator view
        self.loadingView = EMMaterialIndicatorView(frame: CGRect(x: self.frame.width/2, y: self.frame.height/2, width: 24, height: 24))
        self.loadingView!.autoresizingMask = UIView.AutoresizingMask()
        self.addSubview(self.loadingView!)
    }

    // MARK: Public methods

    public func beginLoading() {
        let scrollView = self.superview as? UIScrollView

        if scrollView == nil || self.isLoading || !self.canLoading {
            return
        }

        // Start loading
        self.isLoading = true

        // Update content inset of this table view, then add self at bottom of table view
        var contentInset = scrollView!.contentInset
        contentInset.bottom += self.frame.height
        scrollView!.contentInset = contentInset

        var frame = self.frame
        frame.origin.x = 0
        frame.origin.y = scrollView!.contentSize.height
        frame.size.width = scrollView!.bounds.size.width
        self.frame = frame

        // Start animating
        self.isHidden = false
        self.loadingView!.startAnimating()

        // Call trigger method
        self.sendActions(for: UIControl.Event.valueChanged)
    }

    public func endLoading() {
        let scrollView = self.superview as? UIScrollView

        if scrollView == nil || !self.isLoading {
            return
        }

        // Stop animating
        self.loadingView!.stopAnimating()
        self.isHidden = true

        // Reset content inset
        var contentInset = scrollView!.contentInset
        contentInset.bottom -= self.frame.height

        UIView.animate(withDuration: 0.2, animations: { () -> Void in

            scrollView!.contentInset = contentInset

            }) { (_) -> Void in
                self.isLoading = false
        }
    }
}

#endif
