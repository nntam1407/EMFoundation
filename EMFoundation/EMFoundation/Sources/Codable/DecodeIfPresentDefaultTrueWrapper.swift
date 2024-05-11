//
//  DecodeIfPresentDefaultPropertyWrapper.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 14/06/2023.
//

import Foundation

@propertyWrapper public struct DecodeIfPresentDefaultTrue: CodableContainer {
    public var wrappedValue: Bool

    public init(wrappedValue: Bool) {
        self.wrappedValue = wrappedValue
    }
}

extension KeyedDecodingContainer {
    public func decode(_ type: DecodeIfPresentDefaultTrue.Type, forKey key: Key) throws -> DecodeIfPresentDefaultTrue {
        .init(wrappedValue: try decodeFromStringIfPresent(Bool.self, forKey: key) ?? true)
    }
}
