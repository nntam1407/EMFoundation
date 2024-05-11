//
//  UIViewExtension.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 11/22/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import UIKit
import EMFoundation

var objcAssociationPopupIsVisibleKey: UInt8 = 0
var objcAssociationPopupOverlayViewKey: UInt8 = 1

public extension UIView {

    // MARK: Methods support for snapshot view
    func takeSnapshotImage() -> UIImage {
        // Draw view in rect
        UIGraphicsBeginImageContext(self.frame.size)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)

        // We can use this methods
        //        self.drawViewHierarchyInRect(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), afterScreenUpdates: true)

        let fullImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return fullImage!
    }

    func takeSnapshotImage(_ rect: CGRect) -> UIImage {
        let fullImage = self.takeSnapshotImage()

        // Now we will crop full image to get dest rect
        return fullImage.cropImage(rect)
    }
}

public extension UIView {
    func layerCircle(_ maskToBound: Bool, forceEffectImmediately: Bool = false) {
        if forceEffectImmediately {
            layer.cornerRadius = bounds.size.width/2.0
            layer.masksToBounds = maskToBound
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.layer.cornerRadius = self.bounds.size.width/2.0
                self.layer.masksToBounds = maskToBound
            }
        }
    }

    func layerBorder(_ width: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }

    func applyLayerShadowPath(
        radius: CGFloat,
        offset: CGSize = .zero,
        color: UIColor = .black,
        opacity: Float = 0.15
    ) {
        layer.shadowRadius = radius
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }

    func removeLayerShadowPath() {
        layer.shadowPath = nil
    }
}

public extension UIView {
    // MARK: Function support for animation view

    func startFadeIn(_ duration: Double, minOpacity: CGFloat, maxOpacity: CGFloat) {
        self.alpha = minOpacity

        UIView.animate(withDuration: duration) { () -> Void in
            self.alpha = maxOpacity
        }
    }

    func startFadeReverseEffect(_ minOpacity: Double, maxOpacity: Double, durationTime: Double) {
        // First remove previous effect layer
        self.stopFadeReverseEffect()

        // Create new CABasicAnimation then add to layer
        let effectAnimation = CABasicAnimation(keyPath: "opacity")
        effectAnimation.duration = durationTime as CFTimeInterval
        effectAnimation.autoreverses = true
        effectAnimation.fromValue = NSNumber(value: minOpacity)
        effectAnimation.toValue = NSNumber(value: maxOpacity)
        effectAnimation.repeatCount = HUGE
        effectAnimation.fillMode = CAMediaTimingFillMode.both

        self.layer.add(effectAnimation, forKey: "FadeReverseAnimation")
    }

    func stopFadeReverseEffect() {
        self.layer.removeAnimation(forKey: "FadeReverseAnimation")
    }
}

public extension UIView {
    // MARK: Extension for rotate

    func rotateView(_ degree: CGFloat, anchorPoint: CGPoint, animated: Bool, duration: Double) {
        if degree == 0 {
            if animated {
                UIView.animate(withDuration: duration,
                               delay: 0,
                               options: UIView.AnimationOptions(),
                               animations: { () -> Void in
                                self.transform = CGAffineTransform.identity
                }, completion: { (_) -> Void in
                })
            } else {
                self.transform = CGAffineTransform.identity
            }
        } else {
            // Calculate radians value
            let radian = degree / 180.0 * CGFloat(Double.pi)
            self.layer.anchorPoint = anchorPoint

            if animated {
                UIView.animate(withDuration: duration,
                               delay: 0,
                               options: UIView.AnimationOptions(),
                               animations: { () -> Void in
                                self.transform = self.transform.rotated(by: radian)
                }, completion: { (_) -> Void in
                })
            } else {
                self.transform = self.transform.rotated(by: radian)
            }
        }
    }

    func startRotateAnimation(_ duration: CFTimeInterval, repeatCount: Float) {
        let linearCurve = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = NSNumber(value: Double.pi*2)
        animation.duration = duration
        animation.timingFunction = linearCurve
        animation.isRemovedOnCompletion = false
        animation.repeatCount = repeatCount
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.autoreverses = false

        self.layer.add(animation, forKey: "View.RotateAnimation")
    }

    func stopRotateAnimation() {
        self.layer.removeAnimation(forKey: "View.RotateAnimation")
    }
}

public extension UIView {
    // MARK: Popup extension methods
    private var isShowAsPopupVisiable: Bool {
        get {
            let value: Any? = objc_getAssociatedObject(self, &objcAssociationPopupIsVisibleKey)

            if value == nil {
                return false
            } else {
                return (value! as AnyObject).boolValue
            }
        }
        set (value) {
            // Set assoicated to popupIsVisibleKey key
            objc_setAssociatedObject(self, &objcAssociationPopupIsVisibleKey, NSNumber(value: value), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var showAsPopupOverlayView: UIView? {
        get {
            let value = objc_getAssociatedObject(self, &objcAssociationPopupOverlayViewKey) as? UIView
            return value
        }
        set {
            objc_setAssociatedObject(self, &objcAssociationPopupOverlayViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func showAsPopup(_ mainViewOpacity: Float, overlayOpacity: Float, onWindow: UIWindow? = nil) {
        showAsPopup(mainViewOpacity, overlayOpacity: overlayOpacity, onWindow: onWindow, completion: nil)
    }

    func showAsPopup(_ mainViewOpacity: Float, overlayOpacity: Float, onWindow: UIWindow? = nil, completion: (() -> Void)?) {
        // First try to get top windows
        var topWindow: UIWindow? = onWindow

        if topWindow == nil, let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {

            for window in currentWindowScene.windows.reversed() {
                if window.windowLevel == UIWindow.Level.normal && !window.isHidden {
                    topWindow = window
                    break
                }
            }

            if topWindow == nil || UIDevice.current.userInterfaceIdiom == .pad {
                if #available(iOS 15.0, *) {
                    topWindow = currentWindowScene.keyWindow
                } else {
                    // Fallback on earlier versions
                    topWindow = currentWindowScene.windows.first(where: { $0.isKeyWindow })
                }
            }
        }

        // Now we will try to show this will on windows
        if self.isShowAsPopupVisiable {
            completion?()
            return
        }

        self.isShowAsPopupVisiable = true

        // Init overlay view
        if self.showAsPopupOverlayView == nil {
            self.showAsPopupOverlayView = UIView(frame: topWindow!.bounds)
            self.showAsPopupOverlayView?.backgroundColor = UIColor.black
            self.showAsPopupOverlayView?.layer.opacity = 0
        }

        // Show on top window
        topWindow!.addSubview(self.showAsPopupOverlayView!)
        topWindow!.addSubview(self)
        self.center = CGPoint(x: topWindow!.bounds.size.width/2, y: topWindow!.bounds.size.height/2)

        self.layer.opacity = 0
        self.showAsPopupOverlayView!.layer.opacity = 0

        // Start fade animated
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: { () -> Void in
                        self.layer.opacity = mainViewOpacity
                        self.showAsPopupOverlayView!.layer.opacity = overlayOpacity
        }) { (_) -> Void in
            completion?()
        }

        // Zoom in out effect
        self.transform = CGAffineTransform.identity.scaledBy(x: 0.94, y: 0.94)
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: UIView.AnimationOptions(),
                       animations: { () -> Void in
                        self.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
        }) { (_) -> Void in

        }
    }

    func hidePopup(_ animated: Bool, completion:(() -> Void)? = nil) {
        self.isShowAsPopupVisiable = false

        guard let _ = self.superview else {
            completion?()
            return
        }

        if animated {
            UIView.animate(withDuration: 0.3,
                           delay: 0.0,
                           options: .beginFromCurrentState,
                           animations: { () -> Void in
                            self.layer.opacity = 0

                            if self.showAsPopupOverlayView != nil {
                                self.showAsPopupOverlayView!.layer.opacity = 0
                            }
            }) { (finished) -> Void in
                if finished {
                    self.removeFromSuperview()

                    if self.showAsPopupOverlayView != nil {
                        self.showAsPopupOverlayView!.removeFromSuperview()
                    }

                    completion?()
                }
            }
        } else {
            self.removeFromSuperview()

            if self.showAsPopupOverlayView != nil {
                self.showAsPopupOverlayView!.removeFromSuperview()
            }

            completion?()
        }
    }
}

public extension UIView {
    func addTopBorder(color: UIColor, height: Double) {
        let border = UIView()
        border.backgroundColor = color
        border.frame = CGRect(x: 0, y: 0, width: frame.width, height: height)
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        addSubview(border)
    }

    func addBottomBorder(color: UIColor, height: Double) {
        let border = UIView()
        border.backgroundColor = color
        border.frame = CGRect(x: 0, y: frame.height - height, width: frame.width, height: height)
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        addSubview(border)
    }

    func addLeftBorder(color: UIColor, width: Double) {
        let border = UIView()
        border.backgroundColor = color
        border.frame = CGRect(x: 0, y: 0, width: width, height: frame.height)
        border.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        addSubview(border)
    }

    func addRightBorder(color: UIColor, width: Double) {
        let border = UIView()
        border.backgroundColor = color
        border.frame = CGRect(x: frame.width - width, y: 0, width: width, height: frame.height)
        border.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
        addSubview(border)
    }
}

public extension UIView {
    func subviews(classNamePrefix: String) -> [UIView] {
        subviews.filter { $0.className().hasPrefix(classNamePrefix) }
    }

    func removeAllSubviews() {
        subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }

    func removeAllSubviews(classNamePrefix: String) {
        subviews.forEach { subview in
            let className = subview.className()
            guard className.hasPrefix(classNamePrefix) else {
                return
            }

            subview.removeFromSuperview()
        }
    }
}

#endif
