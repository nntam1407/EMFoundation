//
//  UINavigation+Extensions.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 07/10/2023.
//
#if canImport(UIKit)

import Foundation
import UIKit

public extension UINavigationController {
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if animated {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            pushViewController(viewController, animated: true)
            CATransaction.commit()
        } else {
            pushViewController(viewController, animated: false)
            completion?()
        }
    }

    @discardableResult
    func popViewController(animated: Bool, completion: (() -> Void)?) -> UIViewController? {
        var viewController: UIViewController?

        if animated {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            viewController = popViewController(animated: true)
            CATransaction.commit()
        } else {
            viewController = popViewController(animated: false)
            completion?()
        }

        return viewController
    }

    @discardableResult
    func popToViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) -> [UIViewController]? {
        var popViewControllers: [UIViewController]?

        if animated {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            popViewControllers = popToViewController(viewController, animated: true)
            CATransaction.commit()
        } else {
            popViewControllers = popToViewController(viewController, animated: false)
            completion?()
        }

        return popViewControllers
    }

    @discardableResult
    func popToViewControllerBefore(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) -> [UIViewController]? {
        guard let index = viewControllers.firstIndex(of: viewController) else {
            completion?()
            return nil
        }

        if index == 0 {
            return popToRootViewController(animated: animated, completion: completion)
        }

        return popToViewController(viewControllers[index - 1], animated: animated, completion: completion)
    }

    @discardableResult
    func popToRootViewController(animated: Bool, completion: (() -> Void)?) -> [UIViewController]? {
        var popViewControllers: [UIViewController]?

        if animated {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            popViewControllers = popToRootViewController(animated: true)
            CATransaction.commit()
        } else {
            popViewControllers = popToRootViewController(animated: false)
            completion?()
        }

        return popViewControllers
    }
}

#endif
