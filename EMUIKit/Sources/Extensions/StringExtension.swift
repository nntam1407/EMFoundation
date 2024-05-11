//
//  File.swift
//  
//
//  Created by Tam Nguyen on 11/5/24.
//

#if canImport(UIKit)

import Foundation
import UIKit

extension String {
    func textSize(_ font: UIFont, maxWidth: CGFloat) -> CGSize {

        let limitSize = CGSize(width: maxWidth, height: CGFloat(MAXFLOAT))
        let  attributes = [NSAttributedString.Key.font: font]

        var frame = (self as NSString).boundingRect(with: limitSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)

        frame.size.height = ceil(frame.size.height)
        frame.size.width = ceil(frame.size.width)

        if frame.size.width > maxWidth {
            frame.size.width = maxWidth
        }

        return frame.size
    }

    func textSize(_ font: UIFont, maxHeight: CGFloat) -> CGSize {

        let limitSize = CGSize(width: CGFloat(MAXFLOAT), height: maxHeight)
        let  attributes = [NSAttributedString.Key.font: font]

        var frame = (self as NSString).boundingRect(with: limitSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)

        frame.size.height = ceil(frame.size.height)
        frame.size.width = ceil(frame.size.width)

        if frame.size.height > maxHeight {
            frame.size.height = maxHeight
        }

        return frame.size
    }
}

#endif
