//
//  NSNumberExtension.swift
//  Ahacho Business
//
//  Created by Tam Nguyen on 4/24/16.
//  Copyright © 2016 Tam Nguyen. All rights reserved.
//

import Foundation

public extension NSNumber {
    func localizedCurrencyWithCurrencySymbol(_ symbol: String?) -> String {
        let formater = NumberFormatter()
        formater.formatterBehavior = .behavior10_4
        formater.numberStyle = .currency
        formater.locale = Locale.current
        formater.maximumFractionDigits = 2
        formater.currencySymbol = symbol != nil ? symbol! : Locale.current.currencySymbol

        return formater.string(from: self)!
    }

    func localizedCurrencyWithCurrencyCode(_ code: String?) -> String {
        let formater = NumberFormatter()
        formater.formatterBehavior = .behavior10_4
        formater.numberStyle = .currency
        formater.locale = Locale.current
        formater.maximumFractionDigits = 2
        formater.currencyCode = code != nil ? code! : Locale.current.currencyCode

        return formater.string(from: self)!
    }
}
