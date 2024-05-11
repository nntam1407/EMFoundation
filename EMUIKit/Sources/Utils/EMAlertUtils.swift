//
//  AlertUtils.swift
//  TapmuaBusiness
//
//  Created by Tam Nguyen on 8/9/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import UIKit

public class EMAlertUtils {
    public enum EMAlertButton {
        case ok
        case cancel
        case destructive
    }

    public class func showAlert(title: String?,
                                message: String?,
                                okButton: String?,
                                cancelButton: String?,
                                completed: ((_ clickedButton: EMAlertButton) -> Void)?) {
        if (title == nil && message == nil) || (okButton == nil && cancelButton == nil) {
            return
        }

        let alert = EMAlertWindowController(title: title, message: message, preferredStyle: .alert)

        if let okButton {
            alert.addAction(UIAlertAction(title: okButton, style: .default, handler: { (_) in
                completed?(.ok)
            }))
        }

        if let cancelButton {
            alert.addAction(UIAlertAction(title: cancelButton, style: .cancel, handler: { (_) in
                completed?(.cancel)
            }))
        }

        // Present this alert
        alert.showAsAlert(animated: true, completed: nil)
    }

    public class func showAlert(title: String?,
                                message: String?,
                                okButton: String?,
                                completed: (() -> Void)?) {
        self.showAlert(title: title, message: message, okButton: okButton, cancelButton: nil) { (_) in
            completed?()
        }
    }

    public class func showAlert(title: String?,
                                message: String?,
                                okButton: String?) {
        self.showAlert(title: title, message: message, okButton: okButton, cancelButton: nil, completed: nil)
    }

    public class func showAlert(title: String?,
                                message: String?,
                                onViewController: UIViewController,
                                okButton: String?,
                                cancelButton: String?,
                                destructiveButton: String? = nil,
                                completed: ((_ clickedButton: EMAlertButton) -> Void)?) {
        if (title == nil && message == nil) || (okButton == nil && cancelButton == nil && destructiveButton == nil) {
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if let okButton {
            alert.addAction(UIAlertAction(title: okButton, style: .default, handler: { (_) in
                completed?(.ok)
            }))
        }

        if let destructiveButton {
            alert.addAction(UIAlertAction(title: destructiveButton, style: .destructive, handler: { (_) in
                completed?(.destructive)
            }))
        }

        if let cancelButton {
            alert.addAction(UIAlertAction(title: cancelButton, style: .cancel, handler: { (_) in
                completed?(.cancel)
            }))
        }

        // Present this alert
        onViewController.present(alert, animated: true, completion: nil)
    }

    public class func showAlert(title: String?,
                                message: String?,
                                onViewController: UIViewController,
                                okButton: String?,
                                completed: (() -> Void)?) {
        self.showAlert(title: title,
                       message: message,
                       onViewController: onViewController,
                       okButton: okButton,
                       cancelButton: nil,
                       destructiveButton: nil) { (_) in
            completed?()
        }
    }

    public class func showAlert(title: String?,
                                message: String?,
                                onViewController: UIViewController,
                                okButton: String?) {
        self.showAlert(title: title,
                       message: message,
                       onViewController: onViewController,
                       okButton: okButton,
                       cancelButton: nil,
                       destructiveButton: nil,
                       completed: nil)
    }
}

#endif
