//
//  LoadingPopupView.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 11/23/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import EMFoundation

public class EMLoadingPopupView: NSObject {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    // Properties

    var mainView: UIView?
    var displayWindow: UIWindow?
    var loadingIndicatorView: EMMaterialIndicatorView?

    private var completedShowLoading = false

    // MARK: Class methods

    static let sharedInstance: EMLoadingPopupView = {
        let instance = EMLoadingPopupView()

        return instance
    }()

    public class func showLoading() {
        EMLoadingPopupView.sharedInstance.showLoading()
    }

    public class func hideLoading() {
        EMLoadingPopupView.sharedInstance.hideLoading()
    }

    // MARK: Override methods

    override init() {
        super.init()

        // Create base UI
        self.createBaseUI()
    }

    // MARK: Private methods

    private func createBaseUI() {
        if mainView == nil {
            mainView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            mainView!.backgroundColor = UIColor.white
            mainView!.layer.cornerRadius = 4.0
            mainView!.alpha = 0
        }

        if loadingIndicatorView == nil {
            loadingIndicatorView = EMMaterialIndicatorView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            loadingIndicatorView!.hideWhenStop = true
            loadingIndicatorView!.startAnimating()

            // Add on main view
            mainView!.addSubview(loadingIndicatorView!)
            loadingIndicatorView!.center = CGPoint(x: mainView!.frame.size.width/2, y: mainView!.frame.size.height/2)
        }
    }

    // MARK: Public methods

    func showLoading() {
        // Now display on window
        if displayWindow == nil {
            displayWindow = UIWindow(frame: UIScreen.main.bounds)
            displayWindow?.windowLevel = UIWindow.Level.alert + 1
        }

        if let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            displayWindow?.windowScene = currentWindowScene
        }

        displayWindow?.isHidden = false
        displayWindow?.makeKeyAndVisible()

        mainView?.showAsPopup(1.0, overlayOpacity: 0.5, onWindow: displayWindow, completion: { [weak self] in
            self?.completedShowLoading = true
        })
    }

    func hideLoading() {
        self.mainView?.hidePopup(self.completedShowLoading) {
            self.displayWindow?.resignKey()
            self.displayWindow?.isHidden = true
            self.displayWindow = nil
            self.completedShowLoading = false

            DLog("LoadingPopupView hidden, displayWindow = nil")
        }
    }
}

#endif
