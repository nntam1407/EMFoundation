//
//  Router.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 07/10/2023.
//
#if canImport(UIKit)

import Foundation
import UIKit

public protocol RouterProtocol: AnyObject {
    func present(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)?,
        onDismissed: (() -> Void)?
    )

    func dismiss(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)?
    )

    // Dismiss entire router
    func dismissAll(animated: Bool, completion: (() -> Void)?)
}

public extension RouterProtocol {
    func present(_ viewController: UIViewController, animated: Bool, onDismissed: (() -> Void)?) {
        present(viewController, animated: animated, completion: nil, onDismissed: onDismissed)
    }

    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        present(viewController, animated: animated, completion: completion, onDismissed: nil)
    }

    func present(_ viewController: UIViewController, animated: Bool) {
        present(viewController, animated: animated, completion: nil, onDismissed: nil)
    }

    func dismiss(_ viewController: UIViewController, animated: Bool) {
        dismiss(viewController, animated: animated, completion: nil)
    }

    func dismissAll(animated: Bool) {
        dismissAll(animated: animated, completion: nil)
    }
}

public protocol NavigationRouterProtocol: RouterProtocol {
    var navigationController: UINavigationController { get }
}

#endif
