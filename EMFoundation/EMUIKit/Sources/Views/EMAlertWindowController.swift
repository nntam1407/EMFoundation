//
//  AlertWindowController.swift
//  TapmuaBusiness
//
//  Created by Tam Nguyen on 8/9/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import EMFoundation

public class EMAlertWindowController: UIAlertController {

    private var displayWindow: UIWindow?

    deinit {
        DLog("Alert window deinit")

        if self.displayWindow != nil {
            self.displayWindow?.resignKey()
            self.displayWindow?.isHidden = true
            self.displayWindow = nil
        }
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if self.displayWindow != nil {
            self.displayWindow?.resignKey()
            self.displayWindow?.isHidden = true
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: 
    // MARK: Alert functions

    public func showAsAlert(completed: (() -> Void)?) {
        self.showAsAlert(animated: false, completed: completed)
    }

    public func showAsAlert(animated: Bool, completed: (() -> Void)?) {
        if presentingViewController != nil {
            dismiss(animated: false, completion: nil)
        }

        // Now display on window
        if displayWindow == nil {
            displayWindow = UIWindow(frame: UIScreen.main.bounds)
            displayWindow?.rootViewController = UIViewController()
            displayWindow?.windowLevel = UIWindow.Level.alert + 1

            if let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                displayWindow?.windowScene = currentWindowScene
            }
        }

        if let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            displayWindow?.windowScene = currentWindowScene
        }

        displayWindow?.isHidden = false
        displayWindow?.makeKeyAndVisible()
        displayWindow?.rootViewController?.present(
            self,
            animated: animated,
            completion: {
                completed?()
            }
        )
    }
}

#endif
