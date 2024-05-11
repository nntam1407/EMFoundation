//
//  DecodeSecondsWrapper.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 14/06/2023.
//

import Foundation

@propertyWrapper public struct DecodeSeconds: CodableContainer {
    public var wrappedValue: Date

    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }
}

extension KeyedDecodingContainer {
    public func decode(_ type: DecodeSeconds.Type, forKey key: Key) throws -> DecodeSeconds {
        let seconds = try decodeFromStringIfPresent(TimeInterval.self, forKey: key) ?? 0.0
        return .init(wrappedValue: Date(timeIntervalSince1970: seconds))
    }
}

extension KeyedEncodingContainer {
    public mutating func encode(_ value: DecodeSeconds, forKey key: KeyedEncodingContainer<K>.Key) throws {
        try encode(value.wrappedValue.timeIntervalSince1970, forKey: key)
    }
}
