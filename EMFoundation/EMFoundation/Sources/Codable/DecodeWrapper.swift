//
//  DecodeWrapper.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 14/06/2023.
//

import Foundation

@propertyWrapper public struct Decode<T: Codable>: CodableContainer {
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

extension KeyedDecodingContainer {
    public func decode<T>(_ type: Decode<T>.Type, forKey key: Key) throws -> Decode<T> {
        .init(wrappedValue: try decode(T.self, forKey: key))
    }

    public func decode<T: LosslessStringDecodable>(_ type: Decode<T>.Type, forKey key: Key) throws -> Decode<T> {
        .init(wrappedValue: try decodeFromString(T.self, forKey: key))
    }
}
