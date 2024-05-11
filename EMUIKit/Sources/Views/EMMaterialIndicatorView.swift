//
//  MaterialIndicatorView.swift
//  AskApp
//
//  Created by Tam Nguyen on 8/7/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//
#if canImport(UIKit)

import UIKit

open class EMMaterialIndicatorView: EMCircleLoadingView {

    @IBInspectable public var hideWhenStop: Bool = true

    public var isAnimating: Bool = false

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    public required init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        registerNotifications()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        registerNotifications()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        setupView()
        registerNotifications()
    }

    // MARK: Private methods

    private func setupView() {
        backgroundColor = UIColor.clear
        strokeBehindLayerColor = UIColor.clear
        strokeWidthPercent = 0.075
        color = UIColor.colorFromHexValue(0x4286F5)
        value = 0.8

        // Should top animating
        stopAnimating()
    }

    private func registerNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    // MARK: Animating methods

    public func startAnimating() {
        setNeedsDisplay()
        isHidden = false
        startRotateAnimation(1.0, repeatCount: Float.infinity)
        isAnimating = true
    }

    public func stopAnimating() {
        stopRotateAnimation()
        isHidden = hideWhenStop
        isAnimating = false
    }

    @objc private func applicationDidBecomeActive() {
        if isAnimating {
            startAnimating()
        }
    }
}

#endif
