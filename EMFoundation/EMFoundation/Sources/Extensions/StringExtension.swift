//
//  StringExtension.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 11/22/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//

import Foundation
import CommonCrypto

public extension String {
    func hashMD5() -> String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))

        CC_MD5_Init(context)
        CC_MD5_Update(context, self, CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate()

        // Convert to hex string
        var hexString = ""

        for byte in digest {
            hexString += String(format: "%02x", byte)
        }

        return hexString
    }
}

public extension String {

    static var empty = ""

    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    func toJsonObject() -> NSDictionary? {
        guard let data = self.data(using: String.Encoding.utf8, allowLossyConversion: true) else {
            return nil
        }

        // Convert data to NSDictionary
        let result = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves)

        return result as? NSDictionary
    }

    func toJsonArray() -> NSArray? {
        guard let data = self.data(using: String.Encoding.utf8, allowLossyConversion: true) else {
            return nil
        }

        // Convert data to NSDictionary
        let result = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves)

        return result as? NSArray
    }

    // Method check is valid email address

    func isValidEmailAddress() -> Bool {
        let regex: NSRegularExpression?

        do {
            regex = try NSRegularExpression(pattern: "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?",
                        options: .caseInsensitive)
        } catch _ {
            regex = nil
        }

        return regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil
    }

    func isValidPhoneNumber() -> Bool {
        let regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: "^((((\\+)|(00))[0-9]{6,14})|([0-9]{6,14}))",
                options: .caseInsensitive)
        } catch _ {
            regex = nil
        }

        return regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil
    }

    func nsRangeFromRange(_ range: Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = range.lowerBound.samePosition(in: utf16view)
        let to = range.upperBound.samePosition(in: utf16view)
        return NSRange(location: utf16view.distance(from: utf16view.startIndex, to: from!), length: utf16view.distance(from: from!, to: to!))
    }

    func nsRangeOfSubString(subString: String) -> NSRange? {
        guard let range = range(of: subString) else {
            return nil
        }

        return nsRangeFromRange(range)
    }

    func rangeFromNSRange(_ nsRange: NSRange) -> Range<String.Index>? {
        let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location)
        let to16 = utf16.index(from16, offsetBy: nsRange.length)

        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
            return from ..< to
        }
        return nil
    }

    static func isEmpty(string: String?) -> Bool {
        if string == nil || string!.trim().count == 0 {
            return true
        }

        return false
    }

    func subStringAtIndex(index: Int) -> String {
        if index < 0 || self.count <= index {
            return ""
        }

        let start = self.index(self.startIndex, offsetBy: index)
        let end = self.index(self.startIndex, offsetBy: index + 1)

        return String(self[start..<end])
    }

    func subString(fromIndex: Int, toIndex: Int) -> String {
        if fromIndex < 0 || toIndex >= self.count || fromIndex > toIndex {
            return ""
        }

        let start = self.index(self.startIndex, offsetBy: fromIndex)
        let end = self.index(self.startIndex, offsetBy: toIndex)

        return String(self[start...end])
    }

    func removePrefix(_ prefix: String) -> String {
        guard !prefix.isEmpty, hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }
}

public extension String {
    static func toDecimalNumberString(number: NSNumber) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: number)

        return formattedNumber
    }
}

public extension String {
    var lastPathComponent: String {
        (self as NSString).lastPathComponent
    }

    func appendPathComponent(pathComponenent: String) -> String {
        (self as NSString).appendingPathComponent(pathComponenent)
    }

    var pathComponents: [String] {
        (self as NSString).pathComponents
    }

    var pathExtension: String {
        (self as NSString).pathExtension
    }

    func deletingPathExtension() -> String {
        (self as NSString).deletingPathExtension
    }

    var withoutPathExtension: String {
        deletingPathExtension()
    }
}

public extension String {
    func appendQueryParams(queryParams: [String: String]) -> String {
        guard !queryParams.isEmpty, var urlComponents = URLComponents(string: self) else {
            return self
        }

        let queryItems = queryParams.map {
            URLQueryItem(name: $0, value: $1)
        }

        if urlComponents.queryItems == nil {
            urlComponents.queryItems = queryItems
        } else {
            urlComponents.queryItems?.append(contentsOf: queryItems)
        }

        return urlComponents.url?.absoluteString ?? self
    }
}
