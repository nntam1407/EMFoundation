//
//  StringFormatters.swift
//  ezSafe
//
//  Created by Tam Nguyen on 20/07/2022.
//  Copyright © 2022 Logi. All rights reserved.
//

import Foundation

public protocol EMFileSizeFormatterProtocol {
    func displayedString(bytes: UInt64) -> String
}

public class EMFileSizeFormatter: EMFileSizeFormatterProtocol {
    
    public init() {}

    public static let shared = EMFileSizeFormatter()

    public func displayedString(bytes: UInt64) -> String {
        if bytes < 1000 { return "\(bytes) B" }

        let exp = Int(log2(Double(bytes)) / log2(1000.0))
        let unit = ["KB", "MB", "GB", "TB", "PB", "EB"][exp - 1]
        let number = Double(bytes) / pow(1000, Double(exp))

        if exp <= 1 || number >= 100 {
            return String(format: "%.0f %@", number, unit)
        } else {
            return String(format: "%.1f %@", number, unit)
                .replacingOccurrences(of: ".0", with: "")
        }
    }

    public static func displayedString(bytes: UInt64) -> String {
        shared.displayedString(bytes: bytes)
    }
}
