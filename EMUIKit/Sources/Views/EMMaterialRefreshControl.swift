//
//  MaterialRefreshControl.swift
//  AskApp
//
//  Created by Tam Nguyen on 7/28/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import EMFoundation

open class EMMaterialRefreshControl<IndicatorView>: UIRefreshControl where IndicatorView: EMCircleLoadingView {

    public lazy var indicatorView: IndicatorView = {
        let indicatorView = IndicatorView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        indicatorView.color = UIColor.colorFromHexValue(0x4286F5)
        indicatorView.strokeBehindLayerColor = UIColor.clear
        indicatorView.backgroundColor = UIColor.clear
        indicatorView.strokeWidthPercent = 0.075
        indicatorView.value = 0
        indicatorView.alpha = 0

        return indicatorView
    }()

    public var isAnimating: Bool = false

    public var color: UIColor? {
        didSet {
            if let color = color {
                indicatorView.color = color
            }
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    public override init() {
        super.init()
        setUpRefreshView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()

        // Hide default indicator view
        tintColor = UIColor.clear
        tintColorDidChange()

        // Track content offset changed event
        (superview as? UIScrollView)?.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
    }

    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        let scrollView = superview as? UIScrollView
        scrollView?.removeObserver(self, forKeyPath: "contentOffset", context: nil)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        indicatorView.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
    }

    public override func beginRefreshing() {
        super.beginRefreshing()
        startRefreshAnimated()
    }

    public override func endRefreshing() {
        super.endRefreshing()
        stopRefreshAnimated()
    }

    deinit {
        DLog("Material refresh deinit")
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentOffset" && !self.isRefreshing else {
            return
        }

        guard let scrollView = object as? UIScrollView, scrollView.isDragging else { return }

        let percent = min(1.0, abs(frame.origin.y) / (bounds.size.height*3/2))
        stopRefreshAnimated()
        indicatorView.alpha = percent
        indicatorView.value = percent
    }

    // MARK: Customize methods

    private func setUpRefreshView() {
        // Hide default indicator view
        tintColor = UIColor.clear
        tintColorDidChange()

        // Init indicator view
        addSubview(indicatorView)

        // Handle value changed event to start loading animated
        addTarget(self, action: #selector(valueChanged(_:)), for: UIControl.Event.valueChanged)
    }

    private func startRefreshAnimated() {
        guard !isAnimating else { return }

        isAnimating = true

        indicatorView.alpha = 1.0
        indicatorView.value = 0.8
        indicatorView.startRotateAnimation(1.0, repeatCount: Float.infinity)
    }

    private func stopRefreshAnimated() {
        isAnimating = false
        indicatorView.stopRotateAnimation()
        indicatorView.value = 0
    }

    // MARK: Handle events

    @objc func valueChanged(_ refreshControl: Any?) {
        startRefreshAnimated()
    }
}

#endif
