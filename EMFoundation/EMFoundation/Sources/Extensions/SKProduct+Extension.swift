//
//  SKProduct+Extension.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 05/02/2024.
//

import Foundation
import StoreKit

public extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price) ?? ""
    }
}
