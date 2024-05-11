//
//  UIViewController+Extension.swift
//  EMUIKit
//
//  Created by Tam Nguyen on 11/12/2023.
//
#if canImport(UIKit)

import Foundation
import UIKit

public extension UIViewController {
    var isModal: Bool {
        if presentingViewController != nil {
            return true
        } else if navigationController != nil && navigationController?.presentingViewController?.presentedViewController === navigationController {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        }

        return false
    }

    // Find the last viewController which is presented by this viewController or it's presented viewControllers.
    var lastPresentedViewController: UIViewController? {
        var lastPresentedViewController = presentedViewController

        while lastPresentedViewController?.presentedViewController != nil {
            lastPresentedViewController = lastPresentedViewController?.presentedViewController
        }

        return lastPresentedViewController
    }
}

#endif
