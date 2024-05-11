//
//  UIAlertViewControllerExtension.swift
//  ezSafe
//
//  Created by Nguyen Ngoc Tam on 23/05/2021.
//  Copyright © 2021 Logi. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import UIKit

public extension UIAlertController {
    func presentActionSheet(
        onViewController vc: UIViewController,
        sender: Any?,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        assert(preferredStyle == .actionSheet, "preferredStyle must be ActionSheet")

        if UIDevice.current.userInterfaceIdiom == .pad {
            modalPresentationStyle = .popover
            popoverPresentationController?.permittedArrowDirections = .any

            if let barButtonItem = sender as? UIBarButtonItem {
                popoverPresentationController?.barButtonItem = barButtonItem
            } else if let view = sender as? UIView {
                let sourceRect = vc.view.convert(view.frame, from: view.superview)
                popoverPresentationController?.sourceView = vc.view
                popoverPresentationController?.sourceRect = sourceRect
            } else {
                // Unsupport
                assert(false, "Missing sourceView & sourceRect or barButtonItem for popover action on iPad.")
                return
            }
        }

        vc.present(self, animated: animated) {
            completion?()
        }
    }
}

#endif
