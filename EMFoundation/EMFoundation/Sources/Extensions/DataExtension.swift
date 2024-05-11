//
//  DataExtension.swift
//  ezSafe
//
//  Created by Tam Nguyen on 29/08/2022.
//  Copyright © 2022 Logi. All rights reserved.
//

import Foundation

public extension Data {
    func toJsonObject() -> NSDictionary? {
        // Convert data to NSDictionary
        let result = try? JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.mutableLeaves)

        return result as? NSDictionary
    }
}
