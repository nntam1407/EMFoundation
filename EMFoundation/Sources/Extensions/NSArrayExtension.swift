//
//  NSArrayExtension.swift
//  MySpace
//
//  Created by Nguyen Ngoc Tam on 14/9/20.
//  Copyright © 2020 Logi. All rights reserved.
//

import Foundation

public extension NSArray {
    // Convert to Json string
    func toJsonString() -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions()) else {
            return nil
        }

        return NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String?
    }
}
