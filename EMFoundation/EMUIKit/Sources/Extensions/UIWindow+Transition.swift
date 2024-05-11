//
//  UIWindow+Transition.swift
//  MySpace
//
//  Created by Nguyen Ngoc Tam on 18/4/20.
//  Copyright © 2020 Logi. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import UIKit

public extension UIWindow {
    enum WindowSetRootTransition {
        case none
        case push
        case present
        case dismissCurrent
        case popCurrent
    }

    func setRootViewController(newViewController: UIViewController,
                               animated: Bool,
                               transition: WindowSetRootTransition,
                               completion: (() -> Void)?) {
        guard let currentRootVC = self.rootViewController, let currentView = currentRootVC.view, let newView = newViewController.view, currentRootVC != newViewController else {
            self.rootViewController = newViewController
            completion?()
            return
        }

        if !animated || transition == .none {
            currentRootVC.viewWillDisappear(animated)
            self.rootViewController = newViewController
            currentRootVC.viewDidDisappear(animated)

            completion?()
            return
        }

        // Disable all touches
        self.isUserInteractionEnabled = false

        // Calculate frame for next VC
        let windowFrame = self.frame
        var viewFrame = newViewController.view.frame
        viewFrame.origin.x = 0
        viewFrame.origin.y = 0
        viewFrame.size.width = windowFrame.size.width
        viewFrame.size.height = windowFrame.size.height

        newViewController.view.removeFromSuperview()
        self.rootViewController = newViewController
        self.addSubview(currentView)

        // Force call viewWillDisapear for current VC
        currentRootVC.viewWillDisappear(animated)

        switch transition {
        case .dismissCurrent:

            self.sendSubviewToBack(newView)

            viewFrame = currentView.frame
            viewFrame.origin.y = windowFrame.size.height

            UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveEaseInOut, animations: {
                currentView.frame = viewFrame
            }, completion: { [weak self] (_) in
                currentRootVC.view.removeFromSuperview()
                currentRootVC.viewDidDisappear(animated)
                self?.isUserInteractionEnabled = true
                completion?()
            })

        case .present:

            self.bringSubviewToFront(newView)
            viewFrame.origin.y = windowFrame.size.height
            newView.frame = viewFrame

            viewFrame.origin.y = 0

            UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveEaseInOut, animations: {
                newView.frame = viewFrame
            }, completion: { [weak self] (_) in
                currentRootVC.view.removeFromSuperview()
                currentRootVC.viewDidDisappear(animated)
                self?.isUserInteractionEnabled = true
                completion?()
            })

        case .push:

            self.bringSubviewToFront(newView)
            viewFrame.origin.x = windowFrame.size.width
            newView.frame = viewFrame

            viewFrame.origin.x = 0

            UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveEaseInOut, animations: {
                newView.frame = viewFrame
            }, completion: { [weak self] (_) in
                currentRootVC.view.removeFromSuperview()
                currentRootVC.viewDidDisappear(animated)
                self?.isUserInteractionEnabled = true
                completion?()
            })

        case .popCurrent:

            self.bringSubviewToFront(currentView)
            newView.frame = viewFrame
            currentView.frame = viewFrame
            viewFrame.origin.x = windowFrame.size.width

            UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveEaseInOut, animations: {
                currentView.frame = viewFrame
            }, completion: { [weak self] (_) in
                currentRootVC.view.removeFromSuperview()
                currentRootVC.viewDidDisappear(animated)
                self?.isUserInteractionEnabled = true
                completion?()
            })

        default:
            currentRootVC.view.removeFromSuperview()
            currentRootVC.viewDidDisappear(animated)
            self.isUserInteractionEnabled = true
            completion?()
        }
    }
}

#endif
