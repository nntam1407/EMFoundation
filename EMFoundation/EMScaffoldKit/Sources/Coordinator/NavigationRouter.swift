//
//  NavigationRouter.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 07/10/2023.
//
#if canImport(UIKit)

import Foundation
import UIKit
import EMUIKit

public class NavigationRouter: NSObject {
    public var navigationController: UINavigationController
    private(set) var routerRootViewController: UIViewController? // Keep track the lastViewController in navigationController when initializing this router

    private var onDismissedClosureMap = [Int: (() -> Void)]()

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController

        super.init()
        navigationController.delegate = self
        routerRootViewController = navigationController.viewControllers.last
    }

    private func performDismissedClosure(forViewController viewController: UIViewController) {
        guard let dismissedClosure = onDismissedClosureMap[viewController.hash] else {
            return
        }

        dismissedClosure()
        onDismissedClosureMap[viewController.hash] = nil
    }
}

extension NavigationRouter: NavigationRouterProtocol {
    public func present(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)?,
        onDismissed: (() -> Void)?
    ) {
        navigationController.pushViewController(viewController, animated: animated, completion: completion)
        onDismissedClosureMap[viewController.hash] = onDismissed
    }

    public func dismiss(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        navigationController.popToViewControllerBefore(viewController, animated: animated, completion: completion)
    }

    public func dismissAll(
        animated: Bool,
        completion: (() -> Void)?
    ) {
        guard let routerRootViewController else {
            navigationController.popToRootViewController(animated: animated, completion: completion)
            return
        }

        navigationController.popToViewController(routerRootViewController, animated: animated, completion: completion)
    }
}

extension NavigationRouter: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let dismissedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from), !navigationController.viewControllers.contains(dismissedViewController) else {
              return
        }

        performDismissedClosure(forViewController: dismissedViewController)
    }
}

#endif
