//
//  UIColorExtension.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 12/17/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//
#if canImport(UIKit)

import UIKit

public extension UIColor {

    private static var UIColorNSCache: NSCache<AnyObject, AnyObject> {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = 100 // Only cache 100 color to reduce memory
        return cache
    }

    class func colorFromHexValue(_ hexValue: Int) -> UIColor {
        return UIColor(red: ((CGFloat)((hexValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((hexValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)((hexValue & 0xFF)))/255.0, alpha: 1.0)
    }

    class func colorFromHexValue(_ hexValue: Int, alpha: CGFloat) -> UIColor {
        return UIColor(red: ((CGFloat)((hexValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((hexValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)((hexValue & 0xFF)))/255.0, alpha: alpha)
    }

    class func colorFromHexValue(_ hexValue: Int, cache: Bool) -> UIColor {
        // Try to get from cache first, with hexValue is key
        if cache, let color = UIColorNSCache.object(forKey: ("\(hexValue)" as AnyObject)) as? UIColor {
            return color
        }

        let color = UIColor.colorFromHexValue(hexValue)

        if cache {
            UIColorNSCache.setObject(color, forKey: ("\(hexValue)" as AnyObject))
        }

        return color
    }

    var hexString: String {
        guard let colorRef = self.cgColor.components else { return "" }

        let red: CGFloat = colorRef[0]
        let green: CGFloat = colorRef[1]
        let blue: CGFloat = colorRef[2]

        return NSString(format: "#%02lX%02lX%02lX",
                        lroundf(Float(red * 255)),
                        lroundf(Float(green * 255)),
                        lroundf(Float(blue * 255))) as String
    }

    // swiftlint:disable large_tuple
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}

#endif
