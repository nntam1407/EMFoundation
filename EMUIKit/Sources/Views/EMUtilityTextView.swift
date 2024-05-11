//
//  UtilityTextView.swift
//  Ahacho Business
//
//  Created by Tam Nguyen on 4/29/16.
//  Copyright © 2016 Tam Nguyen. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import EMFoundation

extension UITextViewDelegate {
    func utilityTextViewDidTouchNextButton(_ textView: EMUtilityTextView) {
        // Do nothing
    }

    func utilityTextViewDidTouchBackButton(_ textView: EMUtilityTextView) {
        // Do nothing
    }
}

class EMUtilityTextView: EMRichTextView {

    private var didLayoutLayer = false

    // Show or don't show toolbar. Default value is don't show
    @IBInspectable var enableToolbar: Bool = false {
        didSet {
            if self.enableToolbar {
                self.initToolbar()
            } else {
                self.removeToolbar()
            }
        }
    }

    private var toolbar: UIToolbar?

    // Set up tool bar items. Default have 1 bar button is Done
    var toolbarItems: [UIBarButtonItem]? {
        didSet {
            toolbar?.items = toolbarItems
        }
    }

    // Private done bar button item
    private var _doneBarItem: UIBarButtonItem?

    /**
     * If we don't enable toolbar, done button will be nil
     * You can set target and action manually for this button. But default it will call resignFirstResponder and call delegate textFieldShouldReturn
     */
    var doneBarItem: UIBarButtonItem? {
        get {
            return _doneBarItem
        }
    }

    /**
     * If this been enabled, we will display next and back button on tool bar
     */
    var enableNextBackBarButtons: Bool = false {
        didSet {
            if self.enableNextBackBarButtons && self.nextButtonItem == nil && self.backButtonItem == nil {
                self.enableToolbar = true

                self.backButtonItem = UIBarButtonItem(image: .systemSymbol(name: .chevronBackward), style: .plain, target: self, action: #selector(EMUtilityTextView.didTouchBackButton))
                self.backButtonItem!.width = 44

                self.nextButtonItem = UIBarButtonItem(image: .systemSymbol(name: .chevronRight), style: .plain, target: self, action: #selector(EMUtilityTextView.didTouchNextButton))
                self.nextButtonItem!.width = 44

                let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

                if self.toolbarItems == nil {
                    self.toolbarItems = []
                }

                self.toolbarItems!.insert(flexibleItem, at: 0)
                self.toolbarItems!.insert(self.nextButtonItem!, at: 0)
                self.toolbarItems!.insert(self.backButtonItem!, at: 0)

                // Set to toolbar
                self.toolbar!.items = self.toolbarItems
            }
        }
    }

    private var nextButtonItem: UIBarButtonItem?
    private var backButtonItem: UIBarButtonItem?

    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    deinit {
        DLog("Utility textview dealloc")
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        didLayoutLayer = true

        if let toolbar {
            toolbar.applyLayerShadowPath(radius: 2.0, offset: CGSize(width: 0, height: -1.0))
        }
    }

    // MARK: Support methods

    private func initToolbar() {
        if self.toolbar == nil {
            self.toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 44))
            self.toolbar!.barStyle = .default
            self.toolbar!.backgroundColor = UIColor.white
            self.inputAccessoryView = self.toolbar

            // Create default done button
            self._doneBarItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done button title"),
                                                style: .plain,
                                                target: self,
                                                action: #selector(EMUtilityTextView.didTouchDoneBarButton(doneButton:)))

            // Create flexible item to push done button to right side
            let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

            // Should display toolbar items if have set before
            if self.toolbarItems != nil {
                self.toolbarItems!.append(flexibleItem)
                self.toolbarItems!.append(self._doneBarItem!)
            } else {
                self.toolbarItems = [flexibleItem, self._doneBarItem!]
            }

            self.toolbar!.items = self.toolbarItems
        }

        if didLayoutLayer {
            toolbar?.applyLayerShadowPath(radius: 2.0, offset: CGSize(width: 0, height: -1.0))
        }
    }

    private func removeToolbar() {
        if self.inputAccessoryView == self.toolbar {
            self.toolbar?.removeFromSuperview()
            self.toolbar = nil
            self.inputAccessoryView = nil
        }
    }

    // MARK: Handle events

    @objc func didTouchDoneBarButton(doneButton: UIBarButtonItem) {
        if self.delegate != nil && self.delegate!.responds(to: #selector(UITextViewDelegate.textViewShouldEndEditing(_:))) {
            if self.delegate!.textViewShouldEndEditing!(self) {
                self.resignFirstResponder()
            }
        } else {
            self.resignFirstResponder()
        }
    }

    @objc func didTouchNextButton() {
        self.delegate?.utilityTextViewDidTouchNextButton(self)
    }

    @objc func didTouchBackButton() {
        self.delegate?.utilityTextViewDidTouchBackButton(self)
    }

}

#endif
