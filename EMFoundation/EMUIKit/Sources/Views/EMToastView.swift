//
//  ToastView.swift
//  ezSafe
//
//  Created by Nguyen Ngoc Tam on 15/05/2021.
//  Copyright © 2021 Logi. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import EMFoundation

public class EMToastView: UIView {

    private struct Constants {
        static let autoDismissDelay = 5.0
    }

    var contentView: UIView!
    var textLabel: UILabel!
    var closeButton: UIButton!

    private var displayWindow: UIWindow?

    /// The toast will be dismissed after this delay in seconds. Set 0 to disable autoDismiss
    var autoDismissDelay: TimeInterval = Constants.autoDismissDelay

    var onTouchHandler: (() -> Void)?

    // Allows to customize by using Appearance
    @objc dynamic var contentBackgroundColor: UIColor? {
        get { return contentView.backgroundColor }
        set { contentView.backgroundColor = newValue }
    }

    @objc dynamic var textColor: UIColor? {
        get { return textLabel.textColor }
        set { textLabel.textColor = newValue }
    }

    @objc dynamic var font: UIFont? {
        get { return textLabel.font }
        set { textLabel.font = newValue }
    }

    @objc dynamic var closeButtonTintColor: UIColor? {
        get { return closeButton.tintColor }
        set { closeButton.tintColor = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupConstraints()
        setupDefaultAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        contentView.applyLayerShadowPath(radius: 4.0)
    }

    deinit {
        DLog("ToastView deinit")

        cancelAutoDismissScheduled()

        if let window = self.displayWindow {
            window.resignKey()
            window.isHidden = true
            displayWindow = nil
        }
    }

    // MARK: Private methods

    private func setupView() {
        backgroundColor = .clear

        contentView = UIView(frame: .zero)
        contentView.layer.cornerRadius = 8.0
        addSubview(contentView)

        textLabel = UILabel(frame: .zero)
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        contentView.addSubview(textLabel)

        closeButton = UIButton(type: .system)
        closeButton.addTarget(self, action: #selector(didTouchCloseButton(sender:)), for: .touchUpInside)
        contentView.addSubview(closeButton)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTouchOnContentView(sender:)))
        contentView.addGestureRecognizer(tapGesture)
    }

    private func setupConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 20.0),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20.0),
            contentView.widthAnchor.constraint(greaterThanOrEqualToConstant: 120.0)
        ])

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.0),
            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12.0)
        ])

        textLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 10.0),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            closeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 30.0),
            closeButton.heightAnchor.constraint(equalToConstant: 30.0)
        ])
    }

    private func setupDefaultAppearance() {
        contentView.backgroundColor = .black

        textLabel.textColor = .white
        textLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)

        closeButton.setImage(
            .systemSymbol(
                name: .xmarkCircle,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 13.0)
            ),
            for: .normal
        )
        closeButton.tintColor = .white
    }

    private func addToDisplayWindowIfNeeded() {
        if displayWindow == nil {
            displayWindow = UIWindow(frame: .zero)
            displayWindow?.windowLevel = UIWindow.Level.alert + 1
        }

        if let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            displayWindow?.windowScene = currentWindowScene
        }

        removeFromSuperview()
        displayWindow?.addSubview(self)

        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: displayWindow!.topAnchor, constant: 0),
            bottomAnchor.constraint(equalTo: displayWindow!.bottomAnchor, constant: 0),
            centerXAnchor.constraint(equalTo: displayWindow!.centerXAnchor, constant: 0),
            leadingAnchor.constraint(greaterThanOrEqualTo: displayWindow!.leadingAnchor, constant: 0),
            trailingAnchor.constraint(lessThanOrEqualTo: displayWindow!.trailingAnchor, constant: 0)
        ])
    }

    // MARK: Events

    @objc private func didTouchCloseButton(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTouchOnContentView(sender: Any) {
        dismiss(animated: true, completion: nil)
        onTouchHandler?()
    }

    // MARK: Private methods for auto dismiss

    private func scheduleAutoDismiss() {
        guard self.autoDismissDelay > 0 else {
            return
        }

        cancelAutoDismissScheduled()
        self.perform(#selector(autoDismiss), with: nil, afterDelay: self.autoDismissDelay)
    }

    private func cancelAutoDismissScheduled() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }

    @objc private func autoDismiss() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: Public methods

    func show(animated: Bool = true, completion: (() -> Void)? = nil) {
        addToDisplayWindowIfNeeded()

        displayWindow?.isHidden = false
        displayWindow?.makeKeyAndVisible()

        // Calculate at set starting frame for window
        let contentSize = systemLayoutSizeFitting(
            CGSize(
                width: UIScreen.main.bounds.width,
                height: UIView.layoutFittingCompressedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
        var windowFrame = CGRect(x: (UIScreen.main.bounds.width - contentSize.width) / 2.0, y: UIScreen.main.bounds.height, width: contentSize.width, height: contentSize.height)
        displayWindow?.frame = windowFrame

        // Animating show window
        windowFrame.origin.y = UIScreen.main.bounds.height - contentSize.height - safeAreaInsets.bottom

        UIView.animate(withDuration: animated ? 0.35 : 0.0, delay: 0.0, options: .curveEaseInOut) {
            self.displayWindow?.frame = windowFrame
        } completion: { finished in
            if finished {
                // Re-calculate widh of window when the toast is smaller than screen with, the window size should be smaller and placed at center of horizontal axis
                windowFrame.size.width = self.frame.width
                windowFrame.origin.x = (UIScreen.main.bounds.width - windowFrame.width) / 2.0
                self.displayWindow?.frame = windowFrame

                // Perform autoDismissed
                self.scheduleAutoDismiss()

                completion?()
            }
        }
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let window = displayWindow else {
            completion?()
            return
        }

        cancelAutoDismissScheduled()

        var windowFrame = window.frame
        windowFrame.origin.y = UIScreen.main.bounds.height

        UIView.animate(withDuration: animated ? 0.35 : 0.0, delay: 0.0, options: .curveEaseInOut) {
            self.displayWindow?.frame = windowFrame
        } completion: { finished in
            if finished {
                self.displayWindow?.frame = windowFrame
                self.displayWindow?.resignKey()
                self.displayWindow?.isHidden = true
                self.displayWindow = nil

                completion?()
            }
        }
    }

    // MARK: Classes methods

    @discardableResult
    public class func show(
        message: String,
        animated: Bool = true,
        completion: (() -> Void)? = nil,
        onTouchHandler: (() -> Void)? = nil
    ) -> EMToastView {
        let toastView = EMToastView(frame: .zero)
        toastView.textLabel.text = message
        toastView.onTouchHandler = onTouchHandler

        toastView.show(animated: animated, completion: completion)
        return toastView
    }
}

#endif
