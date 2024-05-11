//
//  SimpleTextInputPopupController.swift
//  MySpace
//
//  Created by Nguyen Ngoc Tam on 14/5/20.
//  Copyright © 2020 Logi. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import EMFoundation
import UIKit

public protocol EMSimpleTextInputPopupControllerDelegate: AnyObject {
    func simpleTextInputPopupController(
        controller: EMSimpleTextInputPopupController,
        textFieldValueUpdated value: String,
        textField: UITextField,
        textFieldIndex: Int
    )

    func simpleTextInputPopupControllerDidTouchOKButton(
        controller: EMSimpleTextInputPopupController
    )

    func simpleTextInputPopupControllerDidTouchCancelButton(
        controller: EMSimpleTextInputPopupController
    )
}

public protocol EMSimpleTextInputPopupControllerDatasource: AnyObject {
    func simpleTextInputPopupController(
        numberOfTextField controller: EMSimpleTextInputPopupController
    ) -> Int

    func simpleTextInputPopupController(
        controller: EMSimpleTextInputPopupController,
        configTextField textField: UITextField,
        textFieldIndex: Int
    )
}

public class EMSimpleTextInputPopupController: NSObject {

    public weak var delegate: EMSimpleTextInputPopupControllerDelegate?
    public weak var datasource: EMSimpleTextInputPopupControllerDatasource?

    public var popupTag: Int?
    public var object: Any?

    private var alertController: UIAlertController!
    private weak var okAction: UIAlertAction?
    private weak var cancelAction: UIAlertAction?

    public var cancelButtonTitle: String
    public var okButtonTitle: String

    public var title: String? {
        didSet {
            guard let alert = alertController else {
                return
            }

            alert.title = title
        }
    }

    public var message: String? {
        didSet {
            guard let alert = alertController else {
                return
            }

            alert.message = message
        }
    }

    public var isCancelButtonEnabled: Bool = true {
        didSet {
            cancelAction?.isEnabled = isCancelButtonEnabled
        }
    }

    public var isOKButtonEnabled: Bool = true {
        didSet {
            okAction?.isEnabled = isOKButtonEnabled
        }
    }

    public var textFields: [UITextField] {
        get {
            return alertController.textFields ?? []
        }
    }

    public init(title: String?, message: String?, okButton: String, cancelButton: String) {
        self.okButtonTitle = okButton
        self.cancelButtonTitle = cancelButton
        self.title = title
        self.message = message

        super.init()
    }

    deinit {
        DLog("%@ deinit", String(describing: type(of: self)))
    }

    // MARK: Private methods

    private func buildAlertController() {
        if let currentAlert = alertController {
            currentAlert.dismiss(animated: false, completion: nil)
            alertController = nil
        }

        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // Cacel actions
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { [weak self] (_) in
            guard let self = self else {
                return
            }

            self.alertController.dismiss(animated: true) {
                self.delegate?.simpleTextInputPopupControllerDidTouchCancelButton(controller: self)
            }
        })

        cancelAction.isEnabled = isCancelButtonEnabled
        self.cancelAction = cancelAction

        // OK action
        let okAction = UIAlertAction(title: okButtonTitle, style: .default, handler: { [weak self] (_) in
            guard let self = self else {
                return
            }

            self.alertController.dismiss(animated: true) {
                self.delegate?.simpleTextInputPopupControllerDidTouchOKButton(controller: self)
            }
        })

        okAction.isEnabled = isOKButtonEnabled
        self.okAction = okAction

        // Build textfield
        if let datasource = datasource {
            let numberOfTextFields = datasource.simpleTextInputPopupController(numberOfTextField: self)

            assert(numberOfTextFields >= 0, "Number of textFields should be >= 0")

            for index in 0 ..< numberOfTextFields {
                alertController.addTextField { [weak self] (textField) in
                    guard let self = self else {
                        return
                    }

                    textField.addTarget(self, action: #selector(self.textFieldValueChanged(textField:)), for: .editingChanged)

                    self.datasource?.simpleTextInputPopupController(controller: self, configTextField: textField, textFieldIndex: index)
                }
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
    }

    // MARK: Events

    @objc private func textFieldValueChanged(textField: UITextField) {
        guard let index = alertController.textFields?.firstIndex(of: textField) else {
            return
        }

        let value = textField.text ?? ""

        delegate?.simpleTextInputPopupController(controller: self, textFieldValueUpdated: value, textField: textField, textFieldIndex: index)
    }

    // MARK: Public methods

    func present(onViewController viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        // Build new alert controller
        buildAlertController()

        viewController.present(alertController, animated: animated) {
            completion?()
        }
    }

    func dismiss(animated: Bool, completion: (() -> Void)?) {
        guard let alertVC = alertController else {
            completion?()
            return
        }

        alertVC.dismiss(animated: animated) {
            completion?()
        }
    }
}

#endif
