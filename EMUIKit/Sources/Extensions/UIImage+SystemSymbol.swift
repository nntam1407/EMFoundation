//
//  UIImage+SystemSymbol.swift
//  ezSafe
//
//  Created by Tam Nguyen on 15/07/2022.
//  Copyright © 2022 Logi. All rights reserved.
//

#if canImport(UIKit)

import Foundation
import UIKit

public enum SystemSymbolName: String {
    case personCropCircleFill = "person.crop.circle.fill"
    case messageCircleFill = "message.circle.fill"
    case phoneCircleFill = "phone.circle.fill"
    case envelopeCircleFill = "envelope.circle.fill"
    case plus = "plus"
    case plusCircleFill = "plus.circle.fill"
    case xmark = "xmark"
    case xmarkCircle = "xmark.circle"
    case chevronBackward = "chevron.backward"
    case chevronRight = "chevron.right"
    case chevronDown = "chevron.down"
    case checkmark = "checkmark"
    case checkmarkCircleFill = "checkmark.circle.fill"
    case gear = "gear"
    case circleFill = "circle.fill"
    case speaker = "speaker"
    case speaker3 = "speaker.3"
    case video = "video"
    case cloudArrowDown = "icloud.and.arrow.down" // Download from the cloud
    case cloudLink = "link.icloud"
    case trash = "trash"
    case stopCicle = "stop.circle"
    case infoCicle = "info.circle"
    case moreEllipsis = "ellipsis"
    case house = "house"
    case musicList = "music.note.list"
    case share = "square.and.arrow.up"
    case link = "link"
    case play = "play"
    case textInsert = "text.insert"
    case textAppend = "text.append"
    case textBadgePlus = "text.badge.plus" // Add to list
    case textCursor = "text.cursor"
    case stopFill = "stop.fill"
    case squareAndArrowDown = "square.and.arrow.down"
    case externalDriveCloud = "externaldrive.badge.icloud"
    case goForward10Seconds = "goforward.10"
    case gobackward10Seconds = "gobackward.10"
    case number = "number" // Same as hashtag
}

public extension UIImage {
    class func systemSymbol(name: SystemSymbolName) -> UIImage? {
        return .init(systemName: name.rawValue)
    }

    class func systemSymbol(name: SystemSymbolName, withConfiguration configuration: UIImage.Configuration?) -> UIImage? {
        return .init(systemName: name.rawValue, withConfiguration: configuration)
    }

    class func systemSymbol(
        name: SystemSymbolName,
        size: CGFloat,
        weight: UIImage.SymbolWeight = .regular,
        scale: UIImage.SymbolScale = .default,
        tintColor: UIColor? = nil,
        renderingMode: RenderingMode? = nil
    ) -> UIImage? {
        var image = UIImage.systemSymbol(
            name: name,
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: size,
                weight: weight,
                scale: scale
            )
        )

        if let tintColor {
            image = image?.withTintColor(tintColor)
        }

        if let renderingMode {
            return image?.withRenderingMode(renderingMode)
        } else {
            return image?.withRenderingMode(tintColor != nil ? .alwaysOriginal : .automatic)
        }
    }
}

#endif
