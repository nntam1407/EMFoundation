//
//  UIButton+Extension.swift
//  EMUIKit
//
//  Created by Tam Nguyen on 28/11/2023.
//

#if canImport(UIKit)

import Foundation
import UIKit

public extension UIButton {
    func centerButtonAndImage(withSpacing spacing: CGFloat) {
        let spacing = spacing / 2.0
        imageEdgeInsets = .init(top: 0, left: -spacing, bottom: 0, right: spacing)
        titleEdgeInsets = .init(top: 0, left: spacing, bottom: 0, right: -spacing)
    }
}

#endif
