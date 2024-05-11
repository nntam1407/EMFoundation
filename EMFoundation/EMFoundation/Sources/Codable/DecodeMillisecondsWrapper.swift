//
//  DecodeMillisecondsWrapper.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 14/06/2023.
//

import Foundation

@propertyWrapper public struct DecodeMilliseconds: CodableContainer {
    public var wrappedValue: Date

    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }
}

extension KeyedDecodingContainer {
    public func decode(_ type: DecodeMilliseconds.Type, forKey key: Key) throws -> DecodeMilliseconds {
        let milliseconds = try decodeFromStringIfPresent(TimeInterval.self, forKey: key) ?? 0.0
        return .init(wrappedValue: Date(timeIntervalSince1970: milliseconds / 1000.0))
    }
}

extension KeyedEncodingContainer {
    public mutating func encode(_ value: DecodeMilliseconds, forKey key: KeyedEncodingContainer<K>.Key) throws {
        try encode(value.wrappedValue.timeIntervalSince1970 * 1000.0, forKey: key)
    }
}


