//
//  EMDraggableToDismissController.swift
//  EMUIKit
//
//  Created by Tam Nguyen on 12/12/2023.
//
#if canImport(UIKit)

import Foundation
import UIKit

public class EMDraggableToDismissController {
    public enum DismissReason {
        case userSwipeDown
    }

    private enum SlideDirection {
        case none
        case up
        case down
    }

    private struct Constants {
        static let dismissThresholdPostionYPercentage: CGFloat = 1.0 / 3.0
        static let dismissThresholdVelocityY: CGFloat = 1400.0
        static let dismissAnimatedDuration: CGFloat = 0.4
    }

    public weak var viewController: UIViewController?

    public typealias DismissedHandler = (_ viewController: UIViewController, _ reason: DismissReason) -> Void
    public var dismissedHandler: DismissedHandler?

    private var backgroundOverlayView: UIView?
    private var panGesture: UIPanGestureRecognizer!
    private var panStartTouchPoint = CGPoint.zero
    private var panStartOriginY: CGFloat = 0
    private var slidingDirection: SlideDirection = .none

    public init() { }

    public func start(
        withViewController viewController: UIViewController,
        dismissedHandler handler: DismissedHandler?
    ) {
        guard self.viewController == nil else {
            assert(false, "Already started with another viewController")
            return
        }

        self.viewController = viewController
        dismissedHandler = handler

        setup()
    }

    private func setup() {
        guard let viewController else {
            assert(false, "Missing viewController")
            return
        }

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureEvent(panGesture:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.cancelsTouchesInView = true
        viewController.view.addGestureRecognizer(panGesture)
    }

    deinit {
        print("EMDraggableToDismissController of \(String(describing: self)) deinit")

        // Final clean up to ensure there is no miss-action
        backgroundOverlayView?.removeFromSuperview()
    }

    // MARK: Handle guesture events

    @objc private func panGestureEvent(panGesture: UIPanGestureRecognizer) {
        guard let viewController else {
            assert(false, "Missing viewController")
            return
        }

        guard viewController.isModal else {
            assert(false, "Support for Modal presented viewController only!")
            return
        }

        guard let superview = viewController.view.superview else {
            return
        }

        let currentTouchPoint = panGesture.location(in: superview)

        switch panGesture.state {
        case .began:
            panStartTouchPoint = currentTouchPoint
            panStartOriginY = viewController.view.frame.origin.y
            slidingDirection = .none
            addBackgroundOverlayView()
            addCornerRadiusAndShadowForView()
        case .changed:
            let panAmount = panStartTouchPoint.y - currentTouchPoint.y
            let newOriginY = max(panStartOriginY - panAmount, 0)

            // Detect slide direction here
            if newOriginY > viewController.view.frame.origin.y {
                slidingDirection = .down
            } else if abs(newOriginY - viewController.view.frame.origin.y) >= 1 {
                // >= 1 is 1px up, the threshold to detect that user is silding up
                slidingDirection = .up
            }

            // Set frame
            var newFrame = viewController.view.frame
            newFrame.origin.y = newOriginY
            viewController.view.frame = newFrame
        case .cancelled, .ended:
            let velocityY = panGesture.velocity(in: superview).y
            let passDismissThreshold = viewController.view.frame.origin.y >= thresholdPostionYBeforeDismissingView() || velocityY >= Constants.dismissThresholdVelocityY

            if slidingDirection == .down && passDismissThreshold {
                slideViewToDismissState(animated: true) { [weak self] in
                    guard let self = self else {
                        return
                    }

                    viewController.dismiss(animated: false) {
                        self.removeBackgroundOverlayView()
                        self.removeCornerRadiusAndShadowForView()
                        self.dismissedHandler?(viewController, .userSwipeDown)
                    }
                }
            } else {
                slideViewToNormalState(animated: true) { [weak self] in
                    guard let self = self else {
                        return
                    }

                    self.removeBackgroundOverlayView()
                    self.removeCornerRadiusAndShadowForView()
                }
            }
        default:
            slideViewToNormalState(animated: true, completion: nil)
        }
    }

    // MARK: Private methods

    private func addBackgroundOverlayView() {
        guard let viewController else {
            assert(false, "Missing viewController")
            return
        }

        guard backgroundOverlayView == nil, let superview = viewController.view.superview else {
            return
        }

        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: superview.frame.width, height: superview.frame.height))
        backgroundOverlayView = backgroundView
        backgroundOverlayView?.backgroundColor = .black
        backgroundOverlayView?.alpha = 0.3
        superview.insertSubview(backgroundView, belowSubview: viewController.view)
    }

    private func removeBackgroundOverlayView() {
        backgroundOverlayView?.removeFromSuperview()
        backgroundOverlayView = nil
    }

    private func addCornerRadiusAndShadowForView() {
        viewController?.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        viewController?.view.layer.cornerRadius = 12.0
        viewController?.view.applyLayerShadowPath(radius: 4.0)
    }

    private func removeCornerRadiusAndShadowForView() {
        viewController?.view.layer.maskedCorners = []
        viewController?.view.layer.cornerRadius = 0
        viewController?.view.removeLayerShadowPath()
    }

    private func thresholdPostionYBeforeDismissingView() -> CGFloat {
        return (viewController?.view.frame.size.height ?? 0) * Constants.dismissThresholdPostionYPercentage
    }

    private func slideViewToNormalState(animated: Bool, completion: (() -> Void)?) {
        guard let viewController else {
            assert(false, "Missing viewController")
            return
        }

        let frame = viewController.view.frame
        let duration = animated ? max(Constants.dismissAnimatedDuration * (frame.origin.y / frame.size.height), 0.15) : 0.0

        slideView(toPositionY: 0, animatedDuration: Double(duration), completion: completion)
    }

    private func slideViewToDismissState(animated: Bool, completion: (() -> Void)?) {
        guard let viewController else {
            assert(false, "Missing viewController")
            return
        }

        let frame = viewController.view.frame
        let duration = animated ? max(Constants.dismissAnimatedDuration * (frame.size.height - frame.origin.y) / frame.size.height, 0.15) : 0.0

        slideView(toPositionY: frame.size.height, animatedDuration: Double(duration), completion: completion)

        // Animation to fade in overlayView
        if let backgroundOverlayView = backgroundOverlayView {
            UIView.animate(withDuration: TimeInterval(duration)) {
                backgroundOverlayView.alpha = 0.0
            }
        }
    }

    private func slideView(toPositionY: CGFloat, animatedDuration: Double, completion: (() -> Void)?) {
        guard let viewController else {
            assert(false, "Missing viewController")
            return
        }

        var frame = viewController.view.frame
        frame.origin.y = toPositionY
        viewController.view.isUserInteractionEnabled = false

        UIView.animate(withDuration: TimeInterval(animatedDuration), delay: 0.0, options: .curveEaseInOut) {
            viewController.view.frame = frame
        } completion: { _ in
            viewController.view.frame = frame
            viewController.view.isUserInteractionEnabled = true
            completion?()
        }
    }
}

#endif
