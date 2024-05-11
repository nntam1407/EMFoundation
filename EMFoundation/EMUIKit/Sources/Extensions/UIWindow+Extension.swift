//
//  UIWindow+Extension.swift
//  EMUIKit
//
//  Created by Tam Nguyen on 05/01/2024.
//
#if canImport(UIKit)

import Foundation
import UIKit

public extension UIWindow {
    var topMostViewController: UIViewController? {
        var topViewController: UIViewController? = rootViewController

        // Find if there is any VC which is presented on top
        if let presentedVC = topViewController?.lastPresentedViewController {
            topViewController = presentedVC
        }

        // Check if topVc is navigation or tabbar, we will find the most last child
        while (topViewController is UINavigationController) || (topViewController is UITabBarController) {
            if let navigationVC = topViewController as? UINavigationController {
                topViewController = navigationVC.topViewController
            }

            if let tabbarVC = topViewController as? UITabBarController {
                // If there is no child VCs of this tabbar VC, just exit this while-loop
                guard let childViewControllers = tabbarVC.viewControllers, childViewControllers.count > 0 else {
                    break
                }

                topViewController = tabbarVC.selectedViewController
            }
        }

        return topViewController
    }
}

#endif
