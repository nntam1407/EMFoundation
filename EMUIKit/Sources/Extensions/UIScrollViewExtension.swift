//
//  UIScrollViewExtension.swift
//  Ahacho Business
//
//  Created by Tam Nguyen on 2/3/16.
//  Copyright © 2016 Tam Nguyen. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import UIKit

public extension UIScrollView {

    enum Constants {
        static var objcAssociationFocusControlKey: UInt8 = 0
        static var objcAssociationOrigionOffsetKey: UInt8 = 1
        static var objcAssociationOriginalContentInsetKey: UInt8 = 2
        static var objcAssociationOriginalScrollIndicatorInsetsKey: UInt8 = 3
        static var objcAssociationIsKeyboardWillShowKey: UInt8 = 4
        static var objcAssociationTapGestureKey: UInt8 = 5
        static var objcAssociationKeyboardTopMarginKey: UInt8 = 6
        static var objcAssociationContentTopMarginKey: UInt8 = 7
        static var objcAssociationPerformSelectorTimerKey: UInt8 = 8
        static var objcAssociationCloseKeyboardWhenTouchOutsideKey: UInt8 = 9
        static var objcAssociationKeepScrollPositionAfterDismissedKey: UInt8 = 10
    }

    // MARK: Properties

    private var focusControl: UIView? {
        get {
            let value = objc_getAssociatedObject(self, &Constants.objcAssociationFocusControlKey)

            return (value as? UIView)
        } set(newValue) {
            objc_setAssociatedObject(self, &Constants.objcAssociationFocusControlKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var origionOffset: CGPoint {
        get {
            let value = objc_getAssociatedObject(self, &Constants.objcAssociationOrigionOffsetKey) as? NSValue
            let pointValue = value?.cgPointValue

            if pointValue == nil {
                return CGPoint.zero
            }

            return pointValue!

        } set(newValue) {
            let value = NSValue(cgPoint: newValue)

            objc_setAssociatedObject(self, &Constants.objcAssociationOrigionOffsetKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var originalContentInset: UIEdgeInsets {
        get {
            let value = objc_getAssociatedObject(self, &Constants.objcAssociationOriginalContentInsetKey) as? NSValue
            let insets = value?.uiEdgeInsetsValue

            if insets == nil {
                return UIEdgeInsets.zero
            }

            return insets!

        } set(newValue) {
            let value = NSValue(uiEdgeInsets: newValue)

            objc_setAssociatedObject(self, &Constants.objcAssociationOriginalContentInsetKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var originalScrollIndicatorInsets: UIEdgeInsets {
        get {
            let value = objc_getAssociatedObject(self, &Constants.objcAssociationOriginalScrollIndicatorInsetsKey) as? NSValue
            let insets = value?.uiEdgeInsetsValue

            if insets == nil {
                return UIEdgeInsets.zero
            }

            return insets!

        } set(newValue) {
            let value = NSValue(uiEdgeInsets: newValue)

            objc_setAssociatedObject(self, &Constants.objcAssociationOriginalScrollIndicatorInsetsKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var isKeyboardWillShow: Bool {
        get {
            let object = objc_getAssociatedObject(self, &Constants.objcAssociationIsKeyboardWillShowKey) as? NSNumber
            let value = object?.boolValue

            if value == nil {
                return false
            }

            return value!

        } set(newValue) {
            let value = NSNumber(value: newValue)

            objc_setAssociatedObject(self, &Constants.objcAssociationIsKeyboardWillShowKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var tapGesture: UITapGestureRecognizer? {
        get {
            let value = objc_getAssociatedObject(self, &Constants.objcAssociationTapGestureKey)

            return (value as? UITapGestureRecognizer)
        } set(newValue) {
            objc_setAssociatedObject(self, &Constants.objcAssociationTapGestureKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var keyboardTopMargin: Double {
        get {
            let object = objc_getAssociatedObject(self, &Constants.objcAssociationKeyboardTopMarginKey) as? NSNumber
            let value = object?.doubleValue

            if value == nil {
                return 10
            }

            return value!

        } set(newValue) {
            let value = NSNumber(value: newValue)

            objc_setAssociatedObject(self, &Constants.objcAssociationKeyboardTopMarginKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var contentTopMargin: Double {
        get {
            let object = objc_getAssociatedObject(self, &Constants.objcAssociationContentTopMarginKey) as? NSNumber
            let value = object?.doubleValue

            if value == nil {
                return 10
            }

            return value!

        } set(newValue) {
            let value = NSNumber(value: newValue)

            objc_setAssociatedObject(self, &Constants.objcAssociationContentTopMarginKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var performSelectorTimer: Timer? {
        get {
            let value = objc_getAssociatedObject(self, &Constants.objcAssociationPerformSelectorTimerKey)

            return (value as? Timer)
        } set(newValue) {
            objc_setAssociatedObject(self, &Constants.objcAssociationPerformSelectorTimerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var dismissKeyboardWhenTouchOutside: Bool {
        get {
            let object = objc_getAssociatedObject(self, &Constants.objcAssociationCloseKeyboardWhenTouchOutsideKey) as? NSNumber
            let value = object?.boolValue

            if value == nil {
                return false
            }

            return value!
        } set (newValue) {
            let value = NSNumber(value: newValue)

            objc_setAssociatedObject(self, &Constants.objcAssociationCloseKeyboardWhenTouchOutsideKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            if newValue {
                // Add tap gesture
                self.addTapGesture()
            } else {
                // Remove tap gesture
                if self.tapGesture != nil {
                    self.removeGestureRecognizer(self.tapGesture!)
                    self.tapGesture = nil
                }
            }
        }
    }

    var keepScrollPositionAfterDismissed: Bool {
        get {
            let object = objc_getAssociatedObject(self, &Constants.objcAssociationKeepScrollPositionAfterDismissedKey) as? NSNumber
            let value = object?.boolValue

            if value == nil {
                return false
            }

            return value!

        } set(newValue) {
            let value = NSNumber(value: newValue)

            objc_setAssociatedObject(self, &Constants.objcAssociationKeepScrollPositionAfterDismissedKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // MARK: Private Methods

    private func addTapGesture() {
        if self.tapGesture == nil {
            self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(UIScrollView.handleTapGesture(_:)))
            self.tapGesture?.numberOfTapsRequired = 1
            self.tapGesture?.cancelsTouchesInView = false

            // Add tap gesture on this view
            self.addGestureRecognizer(self.tapGesture!)
        }
    }

    private func isChildOfView(_ parentView: UIView?, childView: UIView?) -> Bool {
        if parentView == nil || childView == nil {
            return false
        }

        let parentOfView = childView?.superview

        if parentOfView == parentView {
            return true
        } else {
            return self.isChildOfView(parentView, childView: parentOfView)
        }
    }

    @objc func handleKeyboardWillShowEvent(_ timer: Timer) {
        if focusControl == nil {
            return
        }

        isKeyboardWillShow = true

        // swiftlint:disable force_cast
        let keyboardInfo = ((timer.userInfo as! Notification) as NSNotification).userInfo
        let duration = keyboardInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let options = keyboardInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt

        var keyboardFrameInWindow = CGRect.zero
        (keyboardInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).getValue(&keyboardFrameInWindow)
        keyboardFrameInWindow.size.height += CGFloat(keyboardTopMargin)
        keyboardFrameInWindow.origin.y -= CGFloat(keyboardTopMargin)

        // the keyboard frame is specified in window-level coordinates. this calculates the frame as if it were a subview of our view, making it a sibling of the scroll view
        let keyboardFrameInView = self.superview?.convert(keyboardFrameInWindow, from: nil)

        let scrollViewKeyboardIntersection = self.frame.intersection(keyboardFrameInView!)
        let newContentInsets = UIEdgeInsets.init(top: CGFloat(self.contentTopMargin) + self.contentInset.top, left: 0, bottom: scrollViewKeyboardIntersection.size.height, right: 0)

        UIView.animate(withDuration: duration,
                                   delay: 0,
                                   options: UIView.AnimationOptions(rawValue: options),
                                   animations: {
                                    /*
                                     * Depending on visual layout, _focusedControl should either be the input field (UITextField,..) or another element
                                     * that should be visible, e.g. a purchase button below an amount text field
                                     * it makes sense to set _focusedControl in delegates like -textFieldShouldBeginEditing: if you have multiple input fields
                                     */
                                    if self.focusControl != nil {
                                        if self.origionOffset.x == -1 && self.origionOffset.y == -1 {
                                            self.origionOffset = self.contentOffset
                                            self.originalContentInset = self.contentInset
                                            self.originalScrollIndicatorInsets = self.scrollIndicatorInsets
                                        }

                                        self.contentInset = newContentInsets
                                        self.scrollIndicatorInsets = newContentInsets

                                        var controlFrameInScrollView = self.convert(self.focusControl!.bounds, from: self.focusControl)

                                        // if the control is a deep in the hierarchy below the scroll view, this will calculate the frame as if it were a direct subview
                                        controlFrameInScrollView = controlFrameInScrollView.insetBy(dx: 0, dy: 0)

                                        let controlVisualOffsetToTopOfScrollview = controlFrameInScrollView.origin.y - self.contentOffset.y
                                        let controlVisualBottom = controlVisualOffsetToTopOfScrollview + controlFrameInScrollView.size.height

                                        // this is the visible part of the scroll view that is not hidden by the keyboard
                                        let scrollViewVisibleHeight = self.frame.size.height - scrollViewKeyboardIntersection.size.height

                                        if controlVisualBottom > scrollViewVisibleHeight {
                                            // scroll up until the control is in place
                                            var newContentOffset = self.contentOffset
                                            newContentOffset.y += (controlVisualBottom - scrollViewVisibleHeight)

                                            // make sure we don't set an impossible offset caused by the "nice visual offset"
                                            // if a control is at the bottom of the scroll view, it will end up just above the keyboard to eliminate scrolling inconsistencies
                                            newContentOffset.y = min(newContentOffset.y, self.contentSize.height - scrollViewVisibleHeight)

                                            // animated:NO because we have created our own animation context around this code
                                            self.setContentOffset(newContentOffset, animated: false)

                                        } else if controlFrameInScrollView.origin.y < self.contentOffset.y {
                                            var newContentOffset = self.contentOffset
                                            newContentOffset.y = controlFrameInScrollView.origin.y

                                            // animated:NO because we have created our own animation context around this code
                                            self.setContentOffset(newContentOffset, animated: false)
                                        }

                                    }
            }, completion: { _ in
        })

        if performSelectorTimer != nil {
            performSelectorTimer?.invalidate()
            performSelectorTimer = nil
        }
    }

    @objc func animatedHideKeyboard(_ timer: Timer) {
        let userInfo = ((timer.userInfo as! Notification) as NSNotification).userInfo
        let duration = userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let options = userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt

        if isKeyboardWillShow || self.focusControl == nil {
            return
        }

        if self.origionOffset.x == -1 && self.origionOffset.y == -1 {
            return
        }

        UIView.animate(withDuration: duration,
                                   delay: 0,
                                   options: UIView.AnimationOptions(rawValue: options),
                                   animations: {
                                    self.contentInset = self.originalContentInset
                                    self.scrollIndicatorInsets = self.originalScrollIndicatorInsets

                                    if !self.keepScrollPositionAfterDismissed {
                                        self.setContentOffset(self.origionOffset, animated: true)
                                    }

            }, completion: { finished in
                if finished {
                    if self.focusControl != nil && !self.focusControl!.isFirstResponder {
                        self.focusControl = nil
                    }

                    self.origionOffset = CGPoint(x: -1, y: -1)
                    self.isKeyboardWillShow = false

                    self.contentInset = self.originalContentInset
                    self.scrollIndicatorInsets = self.originalScrollIndicatorInsets
                }
        })
    }

    // MARK: Methods

    func addAutoScrolling() {
        // Register keyboard notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIScrollView.keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIScrollView.keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)

        // Register notification when textField is focused
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIScrollView.textViewDidBeginEditNotif(_:)),
            name: UITextField.textDidBeginEditingNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIScrollView.textViewDidBeginEditNotif(_:)),
            name: UITextView.textDidBeginEditingNotification,
            object: nil
        )

        origionOffset = CGPoint(x: -1, y: -1)
        isKeyboardWillShow = false
        self.originalContentInset = self.contentInset
        self.originalScrollIndicatorInsets = self.scrollIndicatorInsets

        self.keyboardTopMargin = 0
        self.contentTopMargin = 0
    }

    func removeAutoScrolling() {
        NotificationCenter.default.removeObserver(self)

        if self.performSelectorTimer != nil {
            self.performSelectorTimer?.invalidate()
            self.performSelectorTimer = nil
        }

        // Remove all association data
        objc_removeAssociatedObjects(self)
    }

    // MARK: Handle notifications

    @objc func keyboardWillShow(_ notification: Notification) {
        if performSelectorTimer != nil {
            performSelectorTimer?.invalidate()
            performSelectorTimer = nil
        }

        // Perform handle event
        // performSelectorTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "handleKeyboardWillShowEvent:", userInfo: notification, repeats: false)
        performSelectorTimer = Timer(timeInterval: 0.05, target: self, selector: #selector(UIScrollView.handleKeyboardWillShowEvent(_:)), userInfo: notification, repeats: false)
        RunLoop.current.add(performSelectorTimer!, forMode: RunLoop.Mode.default)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        isKeyboardWillShow = false

        if performSelectorTimer != nil {
            performSelectorTimer?.invalidate()
            performSelectorTimer = nil
        }

        // Perform handle event
        performSelectorTimer = Timer(timeInterval: 0.01, target: self, selector: #selector(UIScrollView.animatedHideKeyboard(_:)), userInfo: notification, repeats: false)
        RunLoop.current.add(performSelectorTimer!, forMode: RunLoop.Mode.default)
    }

    @objc func textViewDidBeginEditNotif(_ notification: Notification) {
        let focusView: UIView = notification.object as! UIView

        if self.isChildOfView(self, childView: focusView) {
            focusControl = focusView
        } else {
            focusControl = nil
        }
    }

    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        if focusControl != nil {
            if (focusControl as? UITextField) != nil {
                (focusControl as! UITextField).resignFirstResponder()
            } else if (focusControl as? UITextView) != nil {
                (focusControl as! UITextView).resignFirstResponder()
            }
        }
    }
}

#endif
