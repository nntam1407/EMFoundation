//
//  ModalRouter.swift
//  EMScaffoldKit
//
//  Created by Tam Nguyen on 19/11/2023.
//
#if canImport(UIKit)

import Foundation
import UIKit
import EMUIKit

public class ModalRouter: NSObject, UIAdaptivePresentationControllerDelegate {
    weak public private(set) var parentViewController: UIViewController?
    weak private var firstPresentedViewController: UIViewController?

    private var onDismissedClosureMap = [Int: (() -> Void)]()

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

    private func performDismissedClosureForAll() {
        onDismissedClosureMap.values.forEach { closure in
            closure()
        }
        onDismissedClosureMap.removeAll()
    }

    // Called when user swipe down to dismiss
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        performDismissedClosure(forViewController: presentationController.presentedViewController)
    }

    // MARK: -
    // MARK: RouterProtocol

}

extension ModalRouter: RouterProtocol {
    public func present(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)?,
        onDismissed: (() -> Void)?
    ) {
        guard let parentViewController else {
            completion?()
            return
        }

        onDismissedClosureMap[viewController.hash] = onDismissed

        if let presentedViewController = parentViewController.presentedViewController, !presentedViewController.isBeingDismissed {
            presentedViewController.present(viewController, animated: animated, completion: completion)
        } else {
            parentViewController.present(viewController, animated: animated, completion: completion)
        }

        viewController.presentationController?.delegate = self

        if firstPresentedViewController == nil {
            firstPresentedViewController = viewController
        }
    }

    public func dismiss(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        if viewController === parentViewController {
            dismissAll(animated: animated, completion: completion)
            return
        }

        viewController.dismiss(animated: animated) {
            self.performDismissedClosure(forViewController: viewController)
            completion?()
        }
    }

    public func dismissAll(
        animated: Bool,
        completion: (() -> Void)?
    ) {
        if let firstPresentedViewController {
            firstPresentedViewController.dismiss(animated: animated) {
                self.performDismissedClosureForAll()
                completion?()
            }

            return
        }

        guard let parentViewController else {
            completion?()
            return
        }

        parentViewController.dismiss(animated: animated) {
            self.performDismissedClosureForAll()
            completion?()
        }
    }
}

#endif
