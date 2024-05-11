//
//  Coordinator.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 07/10/2023.
//
#if canImport(UIKit)

import Foundation

public protocol CoordinatorProtocol: AnyObject {
    associatedtype Router: RouterProtocol

    var childCoordinators: [any CoordinatorProtocol] { get set }
    var router: Router { get }

    func present(
        animated: Bool,
        completion: (() -> Void)?,
        onDismissed: (() -> Void)?
    )

    func dismiss(animated: Bool, completion: (() -> Void)?)

    func presentChild(
        _ childCoordinator: any CoordinatorProtocol,
        animated: Bool,
        completion: (() -> Void)?,
        onDismissed: (() -> Void)?
    )
}

public extension CoordinatorProtocol {
    @discardableResult
    private func removeChildCoordinator(childCoordinator: any CoordinatorProtocol) -> Bool {
        guard let index = childCoordinators.firstIndex(where:  { $0 === childCoordinator }) else {
            return false
        }
        childCoordinators.remove(at: index)
        return true
    }

    func present(animated: Bool) {
        present(animated: animated, completion: nil, onDismissed: nil)
    }

    func presentChild(
        _ childCoordinator: any CoordinatorProtocol,
        animated: Bool,
        completion: (() -> Void)?,
        onDismissed: (() -> Void)?
    ) {
        childCoordinators.append(childCoordinator)
        childCoordinator.present(animated: animated, completion: completion) { [weak self, weak childCoordinator] in
            guard let self, let childCoordinator else {
                return
            }

            self.removeChildCoordinator(childCoordinator: childCoordinator)
            onDismissed?()
        }
    }

    func presentChild(_ childCoordinator: any CoordinatorProtocol, animated: Bool) {
        presentChild(childCoordinator, animated: animated, completion: nil, onDismissed: nil)
    }

    func presentChild(_ childCoordinator: any CoordinatorProtocol) {
        presentChild(childCoordinator, animated: false, completion: nil, onDismissed: nil)
    }

    func dismiss(animated: Bool, completion: (() -> Void)?) {
        router.dismissAll(animated: animated, completion: completion)
    }
}

#endif
