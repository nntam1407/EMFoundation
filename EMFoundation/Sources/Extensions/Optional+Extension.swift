//
//  Optional+Extension.swift
//  EMScaffoldKit
//
//  Created by Tam Nguyen on 20/11/2023.
//

import Foundation

public extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        switch self {
        case .none:
            return true
        case .some(let wrapped):
            return wrapped.isEmpty
        }
    }
}
