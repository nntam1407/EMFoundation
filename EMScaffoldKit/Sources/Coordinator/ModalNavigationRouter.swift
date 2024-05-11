//
//  ModalNavigationRouter.swift
//  EMScaffoldKit
//
//  Created by Tam Nguyen on 08/10/2023.
//
#if canImport(UIKit)

import Foundation
import UIKit
import EMUIKit

public class ModalNavigationRouter<NavigationController: UINavigationController>: NSObject, UINavigationControllerDelegate, UIAdaptivePresentationControllerDelegate {
    weak private(set) var parentViewController: UIViewController?
    
    /// The parentViewController may already presented another ViewController before presenting this navigationController, so in this case, the parentViewController.presentedViewController will present instead.
    /// This property will keep track the actual viewController which presents this navigationController. This could be parentViewController itself, or parentViewController.presentedViewController.
    weak private var presentingViewController: UIViewController?

    private lazy var privateNavigationController: NavigationController = {
        let navi = NavigationController()
        navi.delegate = self
        return navi
    }()

    private var onDismissedClosureMap = [Int: (() -> Void)]()

    public var modalPresentationStyle: UIModalPresentationStyle {
        get {
            privateNavigationController.modalPresentationStyle
        } set {
            privateNavigationController.modalPresentationStyle = newValue
        }
    }

    public init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
        super.init()
    }

    private func performDismissedClosure(forViewController viewController: UIViewController) {
        guard let dismissedClosure = onDismissedClosureMap[viewController.hash] else {
            return
        }

        dismissedClosure()
        onDismissedClosureMap[viewController.hash] = nil
    }

    private func navigationControllerDismissed() {
        // Reset navigationController
        let dismissingViewControllers = navigationController.viewControllers
        navigationController.viewControllers = []

        // Notify onDimissed for all viewControllers
        for dismissedViewController in dismissingViewControllers {
            performDismissedClosure(forViewController: dismissedViewController)
        }
    }

    // MARK: -
    // MARK: UINavigationControllerDelegate, UIAdaptivePresentationControllerDelegate

    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let dismissedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from), !navigationController.viewControllers.contains(dismissedViewController) else {
              return
        }

        performDismissedClosure(forViewController: dismissedViewController)
    }

    // Called when user swipe down to dismiss
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        navigationControllerDismissed()
    }

    // MARK: -
    // MARK: RouterProtocol

}

extension ModalNavigationRouter: NavigationRouterProtocol {
    public var navigationController: UINavigationController {
        privateNavigationController
    }
    
    public func present(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)?,
        onDismissed: (() -> Void)?
    ) {
        guard let parentViewController else {
            completion?()
            onDismissed?()
            return
        }

        onDismissedClosureMap[viewController.hash] = onDismissed

        if navigationController.viewControllers.isEmpty {
            // Present whole navigation controller
            navigationController.viewControllers = [viewController]

            if let lastPresentedViewController = parentViewController.lastPresentedViewController {
                lastPresentedViewController.present(navigationController, animated: animated, completion: completion)
                presentingViewController = lastPresentedViewController
            } else {
                parentViewController.present(navigationController, animated: animated, completion: completion)
                presentingViewController = parentViewController
            }

            navigationController.presentationController?.delegate = self
        } else if navigationController.viewControllers.contains(viewController) {
            navigationController.popToViewController(viewController, animated: animated, completion: completion)
        } else {
            // Just push newVC into the current stack
            navigationController.pushViewController(viewController, animated: animated, completion: completion)
        }
    }

    public func dismiss(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        if viewController === presentingViewController {
            dismissAll(animated: animated, completion: completion)
            return
        }

        if viewController === navigationController.viewControllers.first {
            dismissAll(animated: animated, completion: completion)
            return
        }

        navigationController.popToViewControllerBefore(viewController, animated: animated, completion: completion)
    }

    public func dismissAll(
        animated: Bool,
        completion: (() -> Void)?
    ) {
        guard let presentingViewController else {
            completion?()
            return
        }

        presentingViewController.dismiss(animated: animated) {
            self.navigationControllerDismissed()
            completion?()
        }
    }
}

#endif
