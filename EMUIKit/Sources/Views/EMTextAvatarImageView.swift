//
//  TextAvatarImageView.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 11/22/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import EMFoundation

open class EMTextAvatarImageView: UIImageView {

    private var userNameLabel: UILabel?

    /// First value is background color, second is text color
    static let textAvatarColors = [
        (0xe06055, 0xf4c7c3),
        (0xed6192, 0xf8c7d8),
        (0xba68c8, 0xe6caeb),
        (0x9575cd, 0xc5cae9),
        (0x7986cb, 0xc6dafb),
        (0x5e97f6, 0xc6dafb),
        (0x4fc3f7, 0xc1eafc),
        (0x58d0e1, 0xc4eef4),
        (0x4fb6ac, 0xc1e5e2),
        (0x57bb8a, 0xc4e7d6),
        (0x9ccc65, 0xdcedc9),
        (0xd4e157, 0xeff4c4),
        (0xfdd835, 0xfef1b8),
        (0xf6bf32, 0xfbe8b7),
        (0xf5a631, 0xfbdfb7),
        (0xf18864, 0xfad5c8),
        (0xc2c2c2, 0xf1f1f1),
        (0x90a4ae, 0xd8dfe2),
        (0xa1887f, 0xded5d2),
        (0xa3a3a3, 0xdedede),
        (0xafb6e0, 0xe8eaf6),
        (0xb39ddb, 0xe4dcf2),
        (0x80deea, 0xe9f9fb),
        (0xbcaaa4, 0xe7e1df),
        (0xaed581, 0xdcedc8)
    ]

    public var userName: String? {
        didSet {
            guard userName != oldValue else {
                return
            }

            userNameLabel!.text = ""

            if let userName = userName?.trim(), userName.count > 0 {
                let words = userName.split(separator: " ")
                var displayString = ""

                if words.count >= 1 {
                    var word = words[0]
                    displayString += String(word[word.index(word.startIndex, offsetBy: 0)]).uppercased()

                    if words.count >= 2 {
                        word = words[1]
                        displayString += String(word[word.index(word.startIndex, offsetBy: 0)]).uppercased()
                    }
                }

                userNameLabel?.text = displayString

                // Set background color and text color by calculate from total unicode scalar values then odd for total of color
                var unicodeValue = 0

                for unicode in displayString.unicodeScalars {
                    unicodeValue += Int(unicode.value)
                }

                let colorIndex = unicodeValue % EMTextAvatarImageView.textAvatarColors.count
                let colorSet = EMTextAvatarImageView.textAvatarColors[colorIndex]

                backgroundColor = .colorFromHexValue(colorSet.0, cache: true)
                userNameLabel!.textColor = .colorFromHexValue(colorSet.1, cache: true)
                userNameLabel!.setNeedsDisplay()
            }
        }
    }

    public var font: UIFont? {
        didSet {
            if font != nil && userNameLabel != nil {
                userNameLabel!.font = font
            }
        }
    }

    // Override set image
    open override var image: UIImage? {
        get {
            return super.image
        }
        set {
            userNameLabel?.isHidden = newValue != nil
            layer.masksToBounds = newValue != nil
            super.image = newValue
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    public override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)

        // Create base UI
        createBaseUI()
    }

    public override init(image: UIImage?) {
        super.init(image: image)

        // Create base UI
        createBaseUI()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        // Create base UI
        createBaseUI()
    }

    public init() {
        super.init(frame: CGRect.zero)

        // Create base UI
        createBaseUI()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Create base UI
        createBaseUI()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        // Check should clip to bound
        clipsToBounds = image != nil

        // Layout frame of label on this avatar
        var frame = bounds
        frame.size.height *= 0.7
        frame.size.width *= 0.7
        frame.origin.x = (bounds.size.width - frame.size.width) / 2.0
        frame.origin.y = (bounds.size.height - frame.size.height) / 2.0
        userNameLabel?.frame = frame
    }

    // MARK: Private methods

    private func createBaseUI() {
        if userNameLabel == nil {
            let label = UILabel(frame: self.frame)
            userNameLabel = label
            label.numberOfLines = 0
            label.backgroundColor = .clear
            label.textColor = .white
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 100)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.1

            label.autoresizingMask = [.flexibleWidth]
            addSubview(label)
        }

        // Set default color
        backgroundColor = .colorFromHexValue(0x2F5E91)
    }

    // MARK: Public methods

    public func randomBackgroundColor() {
        // Try to get random index in list color
        let randomIndex = (0 ..< EMTextAvatarImageView.textAvatarColors.count - 1).randomInt
        let colorSet = EMTextAvatarImageView.textAvatarColors[randomIndex]

        backgroundColor = .colorFromHexValue(colorSet.0, cache: true)
        tintColor = .colorFromHexValue(colorSet.1, cache: true)
        userNameLabel?.textColor = .colorFromHexValue(colorSet.1, cache: true)
    }
}

#endif
